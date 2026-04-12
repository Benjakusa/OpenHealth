import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pharmacy_provider.dart';

class DispensePrescriptionScreen extends ConsumerStatefulWidget {
  final String prescriptionId;

  const DispensePrescriptionScreen({
    Key? key,
    required this.prescriptionId,
  }) : super(key: key);

  @override
  ConsumerState<DispensePrescriptionScreen> createState() =>
      _DispensePrescriptionScreenState();
}

class _DispensePrescriptionScreenState
    extends ConsumerState<DispensePrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  Prescription? _prescription;
  Map<String, List<BatchStock>> _availableBatches = {};
  Map<String, BatchStock?> _selectedBatches = {};
  Map<String, double> _dispenseQuantities = {};
  Map<String, bool> _isSubstituted = {};
  Map<String, String> _substitutionNotes = {};
  bool _isLoading = true;
  bool _isDispensing = false;
  bool _loadingBatches = false;

  @override
  void initState() {
    super.initState();
    _loadPrescription();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadPrescription() async {
    final prescription = await ref
        .read(pharmacyProvider.notifier)
        .getPrescriptionById(widget.prescriptionId);

    if (prescription != null && mounted) {
      setState(() {
        _prescription = prescription;
        _isLoading = false;
      });

      for (var item in prescription.items) {
        if (!item.isDispensed) {
          _dispenseQuantities[item.id] = item.quantity;
          _isSubstituted[item.id] = false;
          _loadBatches(item.drugId, item.id);
        }
      }
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadBatches(String drugId, String itemId) async {
    final batches = await ref
        .read(pharmacyProvider.notifier)
        .getAvailableBatches(drugId);

    if (mounted) {
      setState(() {
        _availableBatches[itemId] = batches;
        if (batches.isNotEmpty) {
          final validBatches = batches.where((b) => !b.isExpired).toList();
          if (validBatches.isNotEmpty) {
            validBatches.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
            _selectedBatches[itemId] = validBatches.first;
          }
        }
      });
    }
  }

  void _updateBatch(String itemId, BatchStock batch) {
    setState(() {
      _selectedBatches[itemId] = batch;
    });
  }

  void _updateQuantity(String itemId, double quantity) {
    setState(() {
      _dispenseQuantities[itemId] = quantity;
    });
  }

  void _toggleSubstitution(String itemId) {
    setState(() {
      _isSubstituted[itemId] = !(_isSubstituted[itemId] ?? false);
      if (!(_isSubstituted[itemId] ?? false)) {
        _substitutionNotes[itemId] = '';
      }
    });
  }

  Future<void> _dispense() async {
    if (!_formKey.currentState!.validate()) return;

    final pendingItems = _prescription!.items
        .where((item) => !item.isDispensed)
        .toList();

    final dispenseItems = <DispenseItem>[];
    for (var item in pendingItems) {
      final batch = _selectedBatches[item.id];
      if (batch == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select batch for ${item.drugName}'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      dispenseItems.add(DispenseItem(
        prescriptionItemId: item.id,
        drugId: item.drugId,
        batchId: batch.id,
        quantity: _dispenseQuantities[item.id] ?? item.quantity,
        unitPrice: batch.unitPrice,
        isSubstituted: _isSubstituted[item.id] ?? false,
        substitutionNote: _substitutionNotes[item.id],
      ));
    }

    setState(() => _isDispensing = true);

    final result = await ref.read(pharmacyProvider.notifier).dispensePrescription(
          prescriptionId: widget.prescriptionId,
          items: dispenseItems,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );

    setState(() => _isDispensing = false);

    if (result.success && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 32),
              SizedBox(width: 12),
              Text('Dispensed'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Prescription has been dispensed successfully.'),
              SizedBox(height: 8),
              Text(
                'Dispense ID: ${result.dispenseId}',
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
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to dispense'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Dispense Prescription')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_prescription == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Dispense Prescription')),
        body: Center(child: Text('Prescription not found')),
      );
    }

    final pendingItems =
        _prescription!.items.where((item) => !item.isDispensed).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Dispense Prescription'),
        actions: [
          TextButton.icon(
            onPressed: _isDispensing || pendingItems.isEmpty ? null : _dispense,
            icon: _isDispensing
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.check),
            label: Text(_isDispensing ? 'Processing...' : 'Dispense'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPrescriptionInfo(),
              SizedBox(height: 24),
              ...pendingItems.map((item) => _buildItemCard(item)),
              SizedBox(height: 24),
              _buildNotesSection(),
              SizedBox(height: 24),
              _buildSummary(pendingItems),
              SizedBox(height: 32),
              _buildDispenseButton(pendingItems),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrescriptionInfo() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prescription Number',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      _prescription!.prescriptionNumber,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                if (_prescription!.isUrgent)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.priority_high,
                            size: 16, color: Colors.red[700]),
                        SizedBox(width: 4),
                        Text(
                          'URGENT',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patient',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        _prescription!.patientName ?? 'Unknown',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patient No.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        _prescription!.patientNumber ?? 'N/A',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prescriber',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        _prescription!.prescriberName ?? 'Unknown',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        _formatDate(_prescription!.prescribedAt),
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_prescription!.diagnosis != null) ...[
              SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diagnosis',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    _prescription!.diagnosis!,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(PrescriptionItem item) {
    final batches = _availableBatches[item.id] ?? [];
    final selectedBatch = _selectedBatches[item.id];
    final quantity = _dispenseQuantities[item.id] ?? item.quantity;
    final isSubbed = _isSubstituted[item.id] ?? false;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.drugName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (item.genericName != null)
                        Text(
                          item.genericName!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.drugCode,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildDosingRow('Dosage', item.dosage),
                  _buildDosingRow('Frequency', item.frequency),
                  _buildDosingRow('Duration', '${item.duration} ${item.durationUnit}'),
                  _buildDosingRow('Route', item.route ?? 'Oral'),
                  if (item.instructions != null)
                    _buildDosingRow('Instructions', item.instructions!),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity Required',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        item.quantity.toStringAsFixed(0),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dispense Qty',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          initialValue: quantity.toStringAsFixed(0),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            final qty = double.tryParse(value) ?? quantity;
                            _updateQuantity(item.id, qty);
                          },
                          validator: (value) {
                            final qty = double.tryParse(value ?? '0') ?? 0;
                            if (qty <= 0) return 'Required';
                            if (qty > item.quantity) return 'Exceeds Rx';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Select Batch *',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            if (batches.isEmpty)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[700], size: 20),
                    SizedBox(width: 8),
                    Text(
                      'No stock available',
                      style: TextStyle(color: Colors.orange[800]),
                    ),
                  ],
                ),
              )
            else
              ...batches.where((b) => !b.isExpired).map((batch) {
                final isSelected = selectedBatch?.id == batch.id;
                return InkWell(
                  onTap: () => _updateBatch(item.id, batch),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[50] : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: batch.id,
                          groupValue: selectedBatch?.id,
                          onChanged: (_) => _updateBatch(item.id, batch),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                batch.batchNumber,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Exp: ${_formatDate(batch.expiryDate)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: batch.isNearExpiry
                                      ? Colors.orange[700]
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Qty: ${batch.availableQuantity.toStringAsFixed(0)}',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'KSh ${batch.unitPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        if (batch.isNearExpiry && !batch.isExpired) ...[
                          SizedBox(width: 8),
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.orange[700],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            SizedBox(height: 12),
            CheckboxListTile(
              value: isSubbed,
              onChanged: (_) => _toggleSubstitution(item.id),
              title: Text('Substitute with alternative'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            if (isSubbed) ...[
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Substitution reason',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) =>
                    _substitutionNotes[item.id] = value,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDosingRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
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
              'Dispensing Notes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Any notes for the patient...',
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

  Widget _buildSummary(List<PrescriptionItem> pendingItems) {
    double total = 0;
    for (var item in pendingItems) {
      final batch = _selectedBatches[item.id];
      if (batch != null) {
        total += (_dispenseQuantities[item.id] ?? item.quantity) * batch.unitPrice;
      }
    }

    return Card(
      color: Colors.grey[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Items',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  '${pendingItems.length}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estimated Total',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  'KSh ${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDispenseButton(List<PrescriptionItem> pendingItems) {
    final allBatchesSelected = pendingItems.every(
      (item) => _selectedBatches[item.id] != null,
    );

    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isDispensing || !allBatchesSelected ? null : _dispense,
        icon: _isDispensing
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(Icons.local_pharmacy),
        label: Text(
          _isDispensing
              ? 'Dispensing...'
              : 'Dispense All Items',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
