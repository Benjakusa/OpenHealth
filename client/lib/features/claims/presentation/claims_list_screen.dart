import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/claim_provider.dart';

class ClaimsListScreen extends ConsumerStatefulWidget {
  final String? patientId;

  const ClaimsListScreen({
    Key? key,
    this.patientId,
  }) : super(key: key);

  @override
  ConsumerState<ClaimsListScreen> createState() => _ClaimsListScreenState();
}

class _ClaimsListScreenState extends ConsumerState<ClaimsListScreen> {
  final _scrollController = ScrollController();
  List<Claim> _claims = [];
  bool _isLoading = false;
  int _page = 1;
  bool _hasMore = true;
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadClaims();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadClaims();
      }
    }
  }

  Future<void> _loadClaims() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final claims = await ref.read(claimProvider.notifier).getClaims(
          patientId: widget.patientId,
          status: _filterStatus,
          page: _page,
        );

    if (mounted) {
      setState(() {
        _claims.addAll(claims);
        _hasMore = claims.length >= 20;
        _page++;
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _claims = [];
      _page = 1;
      _hasMore = true;
    });
    await _loadClaims();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Filter Claims'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption(null, 'All Claims'),
            _buildFilterOption('draft', 'Draft'),
            _buildFilterOption('submitted', 'Submitted'),
            _buildFilterOption('pending_approval', 'Pending Approval'),
            _buildFilterOption('approved', 'Approved'),
            _buildFilterOption('rejected', 'Rejected'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String? status, String label) {
    final isSelected = _filterStatus == status;
    return ListTile(
      title: Text(label),
      leading: Radio<String?>(
        value: status,
        groupValue: _filterStatus,
        onChanged: (value) {
          setState(() => _filterStatus = value);
          Navigator.of(ctx).pop();
          _refresh();
        },
      ),
      selected: isSelected,
      onTap: () {
        setState(() => _filterStatus = status);
        Navigator.of(ctx).pop();
        _refresh();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insurance Claims'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _claims.isEmpty && !_isLoading
            ? _buildEmptyState()
            : ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(16),
                itemCount: _claims.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= _claims.length) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return _buildClaimCard(_claims[index]);
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No claims found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          if (_filterStatus != null) ...[
            SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() => _filterStatus = null);
                _refresh();
              },
              child: Text('Clear Filter'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClaimCard(Claim claim) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showClaimDetails(claim),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          claim.claimId,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          claim.claimType.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(claim.status),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Submitted',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        'KES ${claim.submittedAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (claim.approvedAmount != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Approved',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                        Text(
                          'KES ${claim.approvedAmount!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (claim.patient != null) ...[
                SizedBox(height: 8),
                Text(
                  'Patient: ${claim.patient!.fullName}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'draft':
        color = Colors.grey;
        label = 'Draft';
        icon = Icons.edit;
        break;
      case 'submitted':
        color = Colors.blue;
        label = 'Submitted';
        icon = Icons.send;
        break;
      case 'pending_approval':
        color = Colors.orange;
        label = 'Pending';
        icon = Icons.hourglass_empty;
        break;
      case 'approved':
        color = Colors.green;
        label = 'Approved';
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Rejected';
        icon = Icons.cancel;
        break;
      case 'failed':
        color = Colors.red;
        label = 'Failed';
        icon = Icons.error;
        break;
      default:
        color = Colors.grey;
        label = status;
        icon = Icons.help;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showClaimDetails(Claim claim) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Claim Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildStatusChip(claim.status),
                  ],
                ),
                SizedBox(height: 24),
                _buildDetailRow('Claim ID', claim.claimId),
                if (claim.externalReference != null)
                  _buildDetailRow('SHA Reference', claim.externalReference!),
                _buildDetailRow('Claim Type', claim.claimType.toUpperCase()),
                _buildDetailRow(
                  'Total Amount',
                  'KES ${claim.totalAmount.toStringAsFixed(2)}',
                ),
                _buildDetailRow(
                  'Submitted Amount',
                  'KES ${claim.submittedAmount.toStringAsFixed(2)}',
                ),
                if (claim.approvedAmount != null)
                  _buildDetailRow(
                    'Approved Amount',
                    'KES ${claim.approvedAmount!.toStringAsFixed(2)}',
                  ),
                _buildDetailRow('Status', claim.status.toUpperCase()),
                if (claim.failureReason != null)
                  _buildDetailRow('Failure Reason', claim.failureReason!),
                _buildDetailRow('Created', _formatDateTime(claim.createdAt)),
                if (claim.submittedAt != null)
                  _buildDetailRow('Submitted', _formatDateTime(claim.submittedAt!)),
                if (claim.patient != null) ...[
                  SizedBox(height: 16),
                  Text(
                    'Patient Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildDetailRow('Name', claim.patient!.fullName),
                  if (claim.patient!.patientNumber != null)
                    _buildDetailRow('Patient No.', claim.patient!.patientNumber!),
                ],
                if (claim.invoice != null) ...[
                  SizedBox(height: 16),
                  Text(
                    'Invoice Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildDetailRow('Invoice No.', claim.invoice!.invoiceNumber ?? 'N/A'),
                  _buildDetailRow(
                    'Amount',
                    'KES ${claim.invoice!.totalAmount.toStringAsFixed(2)}',
                  ),
                ],
                SizedBox(height: 24),
                if (claim.status == 'submitted' || claim.status == 'pending_approval')
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _checkStatus(claim),
                      icon: Icon(Icons.refresh),
                      label: Text('Check Status'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _checkStatus(Claim claim) async {
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Checking claim status...')),
    );

    final result = await ref.read(claimProvider.notifier).checkClaimStatus(
          claim.externalReference ?? claim.claimId,
        );

    if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${result.error}'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Status: ${result.status.toUpperCase()}'
            '${result.approvedAmount != null ? ' - KES ${result.approvedAmount!.toStringAsFixed(2)} approved' : ''}',
          ),
          backgroundColor: Colors.blue,
        ),
      );
      _refresh();
    }
  }
}
