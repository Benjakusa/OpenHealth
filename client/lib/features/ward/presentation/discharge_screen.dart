import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

class DischargeScreen extends ConsumerStatefulWidget {
  final String admissionId;

  const DischargeScreen({super.key, required this.admissionId});

  @override
  ConsumerState<DischargeScreen> createState() => _DischargeScreenState();
}

class _DischargeScreenState extends ConsumerState<DischargeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  String _dischargeReason = 'discharged_home';
  final _summaryController = TextEditingController();
  final _instructionsController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _summaryController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _api.post('/ward/admissions/${widget.admissionId}/discharge', {
        'dischargeReason': _dischargeReason,
        'dischargeSummary': _summaryController.text,
        'dischargeInstructions': _instructionsController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient discharged successfully')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discharge Patient'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Discharge Warning',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This action will free up the bed and mark the patient as discharged. This action cannot be undone.',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Discharge Reason *', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DischargeReasonChip(
                  label: 'Discharged Home',
                  value: 'discharged_home',
                  icon: Icons.home,
                  selected: _dischargeReason == 'discharged_home',
                  onSelected: (v) => setState(() => _dischargeReason = 'discharged_home'),
                ),
                _DischargeReasonChip(
                  label: 'Transferred',
                  value: 'transferred',
                  icon: Icons.swap_horiz,
                  selected: _dischargeReason == 'transferred',
                  onSelected: (v) => setState(() => _dischargeReason = 'transferred'),
                ),
                _DischargeReasonChip(
                  label: 'Absconded',
                  value: 'absconded',
                  icon: Icons.exit_to_app,
                  selected: _dischargeReason == 'absconded',
                  onSelected: (v) => setState(() => _dischargeReason = 'absconded'),
                ),
                _DischargeReasonChip(
                  label: 'Died',
                  value: 'died',
                  icon: Icons.sentiment_very_dissatisfied,
                  selected: _dischargeReason == 'died',
                  onSelected: (v) => setState(() => _dischargeReason = 'died'),
                ),
                _DischargeReasonChip(
                  label: 'Referred',
                  value: 'referred',
                  icon: Icons.local_hospital,
                  selected: _dischargeReason == 'referred',
                  onSelected: (v) => setState(() => _dischargeReason = 'referred'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _summaryController,
              decoration: const InputDecoration(
                labelText: 'Discharge Summary *',
                border: OutlineInputBorder(),
                hintText: 'Enter clinical summary of the admission...',
              ),
              maxLines: 5,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Discharge Instructions *',
                border: OutlineInputBorder(),
                hintText: 'Enter follow-up care instructions, medications, etc...',
              ),
              maxLines: 5,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.red,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Confirm Discharge',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DischargeReasonChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool selected;
  final Function(bool) onSelected;

  const _DischargeReasonChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    );
  }
}
