import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/theme.dart';
import '../data/payment_provider.dart';

class MpesaPaymentScreen extends ConsumerStatefulWidget {
  final String invoiceId;
  final String patientId;
  final double amount;
  final String? patientPhone;

  const MpesaPaymentScreen({
    Key? key,
    required this.invoiceId,
    required this.patientId,
    required this.amount,
    this.patientPhone,
  }) : super(key: key);

  @override
  ConsumerState<MpesaPaymentScreen> createState() => _MpesaPaymentScreenState();
}

class _MpesaPaymentScreenState extends ConsumerState<MpesaPaymentScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  bool _isPolling = false;
  MpesaPaymentResult? _paymentResult;
  Timer? _pollingTimer;
  int _pollCount = 0;
  static const _maxPolls = 60;

  @override
  void initState() {
    super.initState();
    if (widget.patientPhone != null) {
      _phoneController.text = widget.patientPhone!.replaceAll('+', '');
      if (_phoneController.text.startsWith('0')) {
        _phoneController.text = _phoneController.text.substring(1);
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _initiatePayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
      _paymentResult = null;
    });

    final phone = _phoneController.text.trim();
    final fullPhone = phone.startsWith('0') ? phone : '0$phone';

    final result = await ref.read(paymentProvider.notifier).initiateMpesaPayment(
          invoiceId: widget.invoiceId,
          phoneNumber: fullPhone,
          amount: widget.amount,
        );

    setState(() {
      _isProcessing = false;
      _paymentResult = result;
    });

    if (result.success && result.checkoutRequestId != null) {
      _startPolling(result.checkoutRequestId!);
    }
  }

  void _startPolling(String checkoutRequestId) {
    setState(() => _isPolling = true);
    _pollCount = 0;

    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      final status = await ref.read(paymentProvider.notifier).checkMpesaStatus(checkoutRequestId);

      if (status.isCompleted) {
        timer.cancel();
        setState(() => _isPolling = false);
        _showSuccessDialog(status.receiptNumber ?? 'N/A');
      } else if (status.isFailed) {
        timer.cancel();
        setState(() => _isPolling = false);
        _showFailureDialog(status.resultDesc ?? 'Payment failed');
      } else if (status.error != null) {
        timer.cancel();
        setState(() => _isPolling = false);
        _showFailureDialog(status.error!);
      } else {
        _pollCount++;
        if (_pollCount >= _maxPolls) {
          timer.cancel();
          setState(() => _isPolling = false);
          _showTimeoutDialog();
        }
      }
    });
  }

  void _showSuccessDialog(String receiptNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Payment Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your payment has been received.'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Receipt No:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(receiptNumber),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(true);
            },
            child: Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showFailureDialog(String reason) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Payment Failed'),
          ],
        ),
        content: Text(reason),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(false);
            },
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _retryPayment();
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Payment Timeout'),
        content: Text('The payment request has expired. Please try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(false);
            },
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _retryPayment();
            },
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _retryPayment() {
    setState(() {
      _paymentResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('M-Pesa Payment'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAmountCard(),
              SizedBox(height: 24),
              _buildPhoneInput(),
              SizedBox(height: 24),
              _buildPayButton(),
              if (_isPolling) ...[
                SizedBox(height: 24),
                _buildPollingIndicator(),
              ],
              if (_paymentResult != null && !_paymentResult!.success) ...[
                SizedBox(height: 16),
                _buildErrorMessage(),
              ],
              SizedBox(height: 24),
              _buildInstructions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Amount to Pay',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'KES ${widget.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Invoice: ${widget.invoiceId.substring(0, 8)}...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'M-Pesa Phone Number',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: '07XX XXX XXX',
            prefixText: '+254 ',
            prefixStyle: TextStyle(fontWeight: FontWeight.bold),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter phone number';
            }
            final cleaned = value.replaceAll(RegExp(r'\D'), '');
            if (cleaned.length < 9) {
              return 'Invalid phone number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isProcessing || _isPolling ? null : _initiatePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFF6100),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isProcessing
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send),
                  SizedBox(width: 8),
                  Text(
                    'Pay with M-Pesa',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPollingIndicator() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue[700],
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Waiting for payment confirmation...',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Please check your phone and enter your M-Pesa PIN',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[600],
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Waiting: ${_pollCount * 2} seconds',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700]),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                _paymentResult!.error ?? 'Payment initiation failed',
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Card(
      color: Colors.grey[100],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to Pay',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 12),
            _buildInstructionStep(1, 'Enter your M-Pesa registered phone number'),
            _buildInstructionStep(2, 'Tap "Pay with M-Pesa" button'),
            _buildInstructionStep(3, 'Check your phone for a payment prompt'),
            _buildInstructionStep(4, 'Enter your M-Pesa PIN'),
            _buildInstructionStep(5, 'Confirm payment'),
            SizedBox(height: 8),
            Text(
              'Payment expires in 5 minutes',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(int number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
