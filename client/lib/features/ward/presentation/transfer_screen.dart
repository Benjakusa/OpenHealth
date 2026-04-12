import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../data/ward_provider.dart';

class TransferScreen extends ConsumerStatefulWidget {
  final String admissionId;

  const TransferScreen({super.key, required this.admissionId});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  final _reasonController = TextEditingController();

  String? _selectedWardId;
  String? _selectedBedId;
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWardId == null || _selectedBedId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a ward and bed')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _api.post('/ward/admissions/${widget.admissionId}/transfer', {
        'newWardId': _selectedWardId,
        'newBedId': _selectedBedId,
        'reason': _reasonController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient transferred successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wardsAsync = ref.watch(wardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Patient'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Transfer Information',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'The patient will be moved from their current bed to a new bed in the selected ward.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Target Ward *', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            wardsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, s) => Text('Error: $e'),
              data: (wards) {
                return DropdownButtonFormField<String>(
                  value: _selectedWardId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select ward',
                  ),
                  items: wards.map((ward) {
                    return DropdownMenuItem(
                      value: ward.id,
                      child: Text('${ward.name} (${ward.availableBeds} beds available)'),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedWardId = v;
                      _selectedBedId = null;
                    });
                  },
                  validator: (v) => v == null ? 'Required' : null,
                );
              },
            ),
            const SizedBox(height: 24),
            if (_selectedWardId != null) ...[
              const Text('Target Bed *', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              FutureBuilder(
                future: _api.get('/ward/beds', queryParams: {'wardId': _selectedWardId, 'status': 'available'}),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator();
                  }
                  if (!snapshot.hasData || (snapshot.data!['data'] as List).isEmpty) {
                    return Card(
                      color: Colors.orange[50],
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange),
                            SizedBox(width: 12),
                            Text('No beds available in this ward'),
                          ],
                        ),
                      ),
                    );
                  }
                  final beds = snapshot.data!['data'] as List;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: beds.map((bed) {
                      final isSelected = _selectedBedId == bed['id'];
                      return ChoiceChip(
                        label: Text('${bed['bedNumber']} (${bed['bedType']})'),
                        selected: isSelected,
                        onSelected: (v) {
                          setState(() => _selectedBedId = v ? bed['id'] : null);
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Transfer Reason *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.orange,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Transfer Patient'),
            ),
          ],
        ),
      ),
    );
  }
}
