import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../../../core/config/theme.dart';
import '../../../core/config/app_config.dart';
import '../data/patient_provider.dart';

class PatientFormScreen extends ConsumerStatefulWidget {
  final String? patientId;
  const PatientFormScreen({super.key, this.patientId});

  @override
  ConsumerState<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends ConsumerState<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaving = false;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _emailController = TextEditingController();

  DateTime _dateOfBirth = DateTime.now().subtract(const Duration(days: 365 * 25));
  String _gender = 'male';
  String? _county;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    if (widget.patientId != null) {
      _isEdit = true;
      _loadPatient();
    }
  }

  Future<void> _loadPatient() async {
    setState(() => _isLoading = true);
    try {
      final db = ref.read(databaseServiceProvider);
      final patient = await db.getPatient(widget.patientId!);
      if (patient != null && mounted) {
        final data = PatientData.fromMap(patient);
        setState(() {
          _firstNameController.text = data.firstName;
          _lastNameController.text = data.lastName;
          _middleNameController.text = data.middleName ?? '';
          _phoneController.text = data.phone ?? '';
          _nationalIdController.text = data.nationalId ?? '';
          _emailController.text = data.email ?? '';
          _dateOfBirth = data.dateOfBirth;
          _gender = data.gender;
          _county = data.county;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final db = ref.read(databaseServiceProvider);
      await db.savePatient({
        if (_isEdit) 'id': widget.patientId,
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'middleName': _middleNameController.text.trim().isEmpty ? null : _middleNameController.text.trim(),
        'dateOfBirth': _dateOfBirth.toIso8601String().split('T')[0],
        'gender': _gender,
        'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'nationalId': _nationalIdController.text.trim().isEmpty ? null : _nationalIdController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'county': _county,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEdit ? 'Updated' : 'Registered'), backgroundColor: AppTheme.successColor));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Patient Record' : 'Register New Patient'),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: _buildPersonalSection()),
                              const SizedBox(width: AppSpacing.xl),
                              Expanded(flex: 2, child: _buildContactSection()),
                            ],
                          )
                        else ...[
                          _buildPersonalSection(),
                          const SizedBox(height: AppSpacing.xl),
                          _buildContactSection(),
                        ],
                        const SizedBox(height: AppSpacing.xxl),
                        _buildFooterActions(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildPersonalSection() {
    return _buildCard(
      'Personal Information',
      BootstrapIcons.person_gear,
      [
        Row(
          children: [
            Expanded(child: _buildTextField(_firstNameController, 'First Name *', BootstrapIcons.person)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _buildTextField(_middleNameController, 'Middle Name', null)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildTextField(_lastNameController, 'Last Name *', null),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(context: context, initialDate: _dateOfBirth, firstDate: DateTime(1900), lastDate: DateTime.now());
                  if (picked != null) setState(() => _dateOfBirth = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date of Birth *', prefixIcon: Icon(BootstrapIcons.calendar_date, size: 18)),
                  child: Text('${_dateOfBirth.day}/${_dateOfBirth.month}/${_dateOfBirth.year}'),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Gender *', prefixIcon: Icon(BootstrapIcons.gender_ambiguous, size: 18)),
                items: AppConfig.genders.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                onChanged: (v) => setState(() => _gender = v!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return _buildCard(
      'Contact & Identification',
      BootstrapIcons.telephone,
      [
        _buildTextField(_phoneController, 'Phone Number', BootstrapIcons.phone, prefix: '+254 '),
        const SizedBox(height: AppSpacing.lg),
        _buildTextField(_nationalIdController, 'National ID', BootstrapIcons.card_heading),
        const SizedBox(height: AppSpacing.lg),
        _buildTextField(_emailController, 'Email Address', BootstrapIcons.envelope),
        const SizedBox(height: AppSpacing.lg),
        DropdownButtonFormField<String>(
          value: _county,
          decoration: const InputDecoration(labelText: 'County / Region', prefixIcon: Icon(BootstrapIcons.geo_alt, size: 18)),
          items: AppConfig.supportedCounties.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => setState(() => _county = v),
        ),
      ],
    );
  }

  Widget _buildCard(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: AppSpacing.md),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData? icon, {String? prefix}) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 18) : null,
        prefixText: prefix,
      ),
      textCapitalization: TextCapitalization.words,
      validator: (v) => label.contains('*') && (v == null || v.trim().isEmpty) ? 'Required' : null,
    );
  }

  Widget _buildFooterActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
        const SizedBox(width: AppSpacing.lg),
        SizedBox(
          height: 52,
          width: 160,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(_isEdit ? 'Save Changes' : 'Register Patient'),
          ),
        ),
      ],
    );
  }
}
