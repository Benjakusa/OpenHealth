import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

class NursingNoteFormScreen extends ConsumerStatefulWidget {
  final String admissionId;

  const NursingNoteFormScreen({super.key, required this.admissionId});

  @override
  ConsumerState<NursingNoteFormScreen> createState() => _NursingNoteFormScreenState();
}

class _NursingNoteFormScreenState extends ConsumerState<NursingNoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  String _noteType = 'observation';
  String _content = '';
  String _priority = 'routine';
  String? _shiftType;
  String? _consciousness;
  String? _mobility;
  int? _painScore;

  final _tempController = TextEditingController();
  final _pulseController = TextEditingController();
  final _bpSystolicController = TextEditingController();
  final _bpDiastolicController = TextEditingController();
  final _respRateController = TextEditingController();
  final _spo2Controller = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _tempController.dispose();
    _pulseController.dispose();
    _bpSystolicController.dispose();
    _bpDiastolicController.dispose();
    _respRateController.dispose();
    _spo2Controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final vitals = {
        if (_tempController.text.isNotEmpty) 'temperature': double.tryParse(_tempController.text),
        if (_pulseController.text.isNotEmpty) 'pulse': int.tryParse(_pulseController.text),
        if (_bpSystolicController.text.isNotEmpty) 'bp_systolic': int.tryParse(_bpSystolicController.text),
        if (_bpDiastolicController.text.isNotEmpty) 'bp_diastolic': int.tryParse(_bpDiastolicController.text),
        if (_respRateController.text.isNotEmpty) 'respRate': int.tryParse(_respRateController.text),
        if (_spo2Controller.text.isNotEmpty) 'spo2': int.tryParse(_spo2Controller.text),
      };

      await _api.post('/ward/nursing-notes', {
        'admissionId': widget.admissionId,
        'noteType': _noteType,
        'content': _content,
        'priority': _priority,
        'shiftType': _shiftType,
        'consciousness': _consciousness,
        'mobility': _mobility,
        'painScore': _painScore,
        'vitals': vitals.isNotEmpty ? vitals : null,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note added successfully')),
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
        title: const Text('Add Nursing Note'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildNoteTypeSelector(),
            const SizedBox(height: 16),
            _buildPrioritySelector(),
            const SizedBox(height: 16),
            _buildShiftSelector(),
            const SizedBox(height: 24),
            _buildVitalsSection(),
            const SizedBox(height: 24),
            _buildAssessmentSection(),
            const SizedBox(height: 24),
            _buildContentField(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Note'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteTypeSelector() {
    final types = ['observation', 'vitals', 'care_plan', 'intervention', 'assessment', 'handover', 'incident'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Note Type', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: types.map((type) {
            return ChoiceChip(
              label: Text(_formatLabel(type)),
              selected: _noteType == type,
              onSelected: (v) => setState(() => _noteType = type),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Priority', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Routine'),
              selected: _priority == 'routine',
              onSelected: (v) => setState(() => _priority = 'routine'),
            ),
            ChoiceChip(
              label: const Text('Urgent'),
              selected: _priority == 'urgent',
              onSelected: (v) => setState(() => _priority = 'urgent'),
            ),
            ChoiceChip(
              label: const Text('Critical'),
              selected: _priority == 'critical',
              onSelected: (v) => setState(() => _priority = 'critical'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShiftSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Shift', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Morning'),
              selected: _shiftType == 'morning',
              onSelected: (v) => setState(() => _shiftType = v ? 'morning' : null),
            ),
            ChoiceChip(
              label: const Text('Evening'),
              selected: _shiftType == 'evening',
              onSelected: (v) => setState(() => _shiftType = v ? 'evening' : null),
            ),
            ChoiceChip(
              label: const Text('Night'),
              selected: _shiftType == 'night',
              onSelected: (v) => setState(() => _shiftType = v ? 'night' : null),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVitalsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vitals',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _tempController,
                    decoration: const InputDecoration(
                      labelText: 'Temp (°C)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _pulseController,
                    decoration: const InputDecoration(
                      labelText: 'Pulse (bpm)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _bpSystolicController,
                    decoration: const InputDecoration(
                      labelText: 'BP Sys',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('/'),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _bpDiastolicController,
                    decoration: const InputDecoration(
                      labelText: 'BP Dia',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _respRateController,
                    decoration: const InputDecoration(
                      labelText: 'Resp Rate',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _spo2Controller,
                    decoration: const InputDecoration(
                      labelText: 'SpO2 (%)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assessment',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _consciousness,
              decoration: const InputDecoration(
                labelText: 'Consciousness',
                border: OutlineInputBorder(),
              ),
              items: ['alert', 'voice', 'pain', 'unresponsive'].map((c) {
                return DropdownMenuItem(value: c, child: Text(c.toUpperCase()));
              }).toList(),
              onChanged: (v) => setState(() => _consciousness = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _mobility,
              decoration: const InputDecoration(
                labelText: 'Mobility',
                border: OutlineInputBorder(),
              ),
              items: ['ambulant', 'wheelchair', 'bedridden'].map((m) {
                return DropdownMenuItem(value: m, child: Text(_formatLabel(m)));
              }).toList(),
              onChanged: (v) => setState(() => _mobility = v),
            ),
            const SizedBox(height: 16),
            const Text('Pain Score (0-10)', style: TextStyle(fontWeight: FontWeight.w500)),
            Slider(
              value: (_painScore ?? 0).toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              label: (_painScore ?? 0).toString(),
              onChanged: (v) => setState(() => _painScore = v.round()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Note Content *', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(
            hintText: 'Enter your nursing note...',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          onChanged: (v) => _content = v,
        ),
      ],
    );
  }

  String _formatLabel(String text) {
    return text.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
  }
}
