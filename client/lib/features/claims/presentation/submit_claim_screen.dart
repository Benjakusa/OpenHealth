import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/claim_provider.dart';

class SubmitClaimScreen extends ConsumerStatefulWidget {
  final String invoiceId;
  final String patientId;
  final double totalAmount;
  final String? encounterId;

  const SubmitClaimScreen({
    Key? key,
    required this.invoiceId,
    required this.patientId,
    required this.totalAmount,
    this.encounterId,
  }) : super(key: key);

  @override
  ConsumerState<SubmitClaimScreen> createState() => _SubmitClaimScreenState();
}

class _SubmitClaimScreenState extends ConsumerState<SubmitClaimScreen> {
  final _formKey = GlobalKey<FormState>();
  final _memberNumberController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isVerifying = false;
  bool _isSubmitting = false;
  bool _isVerified = false;
  InsuranceVerificationResult? _verificationResult;

  @override
  void dispose() {
    _memberNumberController.dispose();
    _cardNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _verifyInsurance() async {
    if (_memberNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter member number')),
      );
      return;
    }

    setState(() => _isVerifying = true);

    final result = await ref.read(claimProvider.notifier).verifyInsurance(
          memberNumber: _memberNumberController.text,
          cardNumber: _cardNumberController.text.isNotEmpty
              ? _cardNumberController.text
              : null,
        );

    setState(() {
      _isVerifying = false;
      _verificationResult = result;
      _isVerified = result.valid;
    });

    if (!result.valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Insurance verification failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitClaim() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please verify insurance first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await ref.read(claimProvider.notifier).submitShaClaim(
          invoiceId: widget.invoiceId,
          encounterId: widget.encounterId,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );

    setState(() => _isSubmitting = false);

    if (result.success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 32),
              SizedBox(width: 12),
              Text('Claim Submitted'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your claim has been submitted successfully.'),
              SizedBox(height: 16),
              if (result.shaReference != null)
                _buildInfoRow('Reference', result.shaReference!),
              if (result.claimReference != null)
                _buildInfoRow('Claim ID', result.claimReference!),
              SizedBox(height: 8),
              Text(
                'You will be notified once the claim is processed.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to submit claim'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Insurance Claim'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildClaimInfoCard(),
              SizedBox(height: 24),
              _buildInsuranceSection(),
              if (_isVerified && _verificationResult != null) ...[
                SizedBox(height: 24),
                _buildVerificationResult(),
              ],
              SizedBox(height: 24),
              _buildNotesSection(),
              SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClaimInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Claim Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice ID',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      widget.invoiceId.substring(0, 8),
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Claim Amount',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'KES ${widget.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety, color: Colors.blue[700]),
                SizedBox(width: 8),
                Text(
                  'Insurance Verification',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _memberNumberController,
              decoration: InputDecoration(
                labelText: 'Member Number *',
                hintText: 'e.g., SHA-123456',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter member number';
                }
                return null;
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: 'Card Number',
                hintText: 'SHA Card Number (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isVerifying ? null : _verifyInsurance,
                icon: _isVerifying
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.verified_user),
                label: Text(_isVerifying ? 'Verifying...' : 'Verify Insurance'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationResult() {
    final result = _verificationResult!;

    return Card(
      color: result.valid ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  result.valid ? Icons.check_circle : Icons.error,
                  color: result.valid ? Colors.green : Colors.red,
                ),
                SizedBox(width: 8),
                Text(
                  result.valid ? 'Insurance Verified' : 'Verification Failed',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: result.valid ? Colors.green[800] : Colors.red[800],
                  ),
                ),
              ],
            ),
            if (result.valid) ...[
              SizedBox(height: 16),
              if (result.member != null) ...[
                _buildInfoRow('Member Name', result.member!.name),
                _buildInfoRow('Member No.', result.member!.memberNumber),
                _buildInfoRow('Relationship', result.member!.relationship.toUpperCase()),
              ],
              if (result.coverage != null) ...[
                SizedBox(height: 8),
                _buildInfoRow('Coverage Type', result.coverage!.type),
                _buildInfoRow(
                    'Coverage', '${result.coverage!.coveragePercent.toStringAsFixed(0)}%'),
                if (result.coverage!.limit != null)
                  _buildInfoRow('Limit', 'KES ${result.coverage!.limit!.toStringAsFixed(2)}'),
                _buildInfoRow('Status', result.coverage!.status.toUpperCase()),
              ],
            ] else
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  result.error ?? 'Unable to verify insurance. Please check the details.',
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Notes',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Any additional information for the claim...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitClaim,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
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
                    'Submit Claim',
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
}
