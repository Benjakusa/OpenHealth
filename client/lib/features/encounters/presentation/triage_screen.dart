import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../../../core/config/theme.dart';

class TriageScreen extends ConsumerStatefulWidget {
  final String encounterId;
  const TriageScreen({super.key, required this.encounterId});

  @override
  ConsumerState<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends ConsumerState<TriageScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _pulseController = TextEditingController();
  final _respRateController = TextEditingController();
  final _spo2Controller = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _notesController = TextEditingController();

  String _triageCategory = 'non_urgent';

  @override
  void dispose() {
    for (var c in [_systolicController, _diastolicController, _temperatureController, _pulseController, _respRateController, _spo2Controller, _weightController, _heightController, _notesController]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Triage completed'), backgroundColor: AppTheme.successColor));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Clinical Triage')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionHeader('Vital Signs', BootstrapIcons.heart_pulse),
                  const SizedBox(height: AppSpacing.lg),
                  _buildVitalsGrid(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildSectionHeader('Priority Assessment', BootstrapIcons.flag),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTriageCategorySelector(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildSectionHeader('Additional Observations', BootstrapIcons.journal_text),
                  const SizedBox(height: AppSpacing.lg),
                  _buildNotesCard(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildFooterAction(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: AppSpacing.md),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildVitalsGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1);
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.lg,
        mainAxisSpacing: AppSpacing.lg,
        childAspectRatio: 3,
        children: [
          _buildVitalField(_systolicController, 'Systolic', 'mmHg'),
          _buildVitalField(_diastolicController, 'Diastolic', 'mmHg'),
          _buildVitalField(_temperatureController, 'Temp', '°C'),
          _buildVitalField(_pulseController, 'Pulse', 'bpm'),
          _buildVitalField(_respRateController, 'Resp Rate', '/min'),
          _buildVitalField(_spo2Controller, 'SpO2', '%'),
          _buildVitalField(_weightController, 'Weight', 'kg'),
          _buildVitalField(_heightController, 'Height', 'cm'),
        ],
      );
    });
  }

  Widget _buildVitalField(TextEditingController ctrl, String label, String unit) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppTheme.borderLight)),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          suffixText: unit,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _buildTriageCategorySelector() {
    final categories = [
      ('Emergency', 'emergency', Colors.red, BootstrapIcons.lightning_fill),
      ('Urgent', 'urgent', Colors.orange, BootstrapIcons.exclamation_triangle_fill),
      ('Stable', 'stable', Colors.blue, BootstrapIcons.check_circle_fill),
      ('Routine', 'non_urgent', Colors.green, BootstrapIcons.info_circle_fill),
    ];

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: categories.map((cat) {
        final isSelected = _triageCategory == cat.$2;
        return InkWell(
          onTap: () => setState(() => _triageCategory = cat.$2),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: isSelected ? cat.$3 : AppTheme.surfaceLight,
              border: Border.all(color: isSelected ? cat.$3 : AppTheme.borderLight),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(cat.$4, size: 16, color: isSelected ? Colors.white : cat.$3),
                const SizedBox(width: AppSpacing.md),
                Text(cat.$1, style: TextStyle(color: isSelected ? Colors.white : AppTheme.textPrimaryLight, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(hintText: 'Add clinical notes, patient complaints...', border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none),
          maxLines: 4,
        ),
      ),
    );
  }

  Widget _buildFooterAction() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _save,
        child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Complete Assessment & Queue for Doctor'),
      ),
    );
  }
}
