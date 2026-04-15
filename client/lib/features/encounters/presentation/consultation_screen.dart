import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../../../core/config/theme.dart';

class ConsultationScreen extends ConsumerStatefulWidget {
  final String encounterId;
  const ConsultationScreen({super.key, required this.encounterId});

  @override
  ConsumerState<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends ConsumerState<ConsultationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSaving = false;

  final _chiefComplaintController = TextEditingController();
  final _subjectiveController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _assessmentController = TextEditingController();
  final _planController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var c in [_chiefComplaintController, _subjectiveController, _objectiveController, _assessmentController, _planController]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Doctor Consultation'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'History'),
            Tab(text: 'SOAP Note'),
            Tab(text: 'Diagnosis'),
            Tab(text: 'Prescriptions'),
            Tab(text: 'Lab Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHistoryTab(),
          _buildSoapTab(),
          _buildDiagnosisTab(),
          _buildPrescriptionTab(),
          _buildLabOrdersTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHistoryTab() {
    return _buildTabContent([
      _buildSectionHeader('Chief Complaint', BootstrapIcons.chat_left_dots),
      const SizedBox(height: AppSpacing.md),
      _buildTextArea(_chiefComplaintController, 'Search for chief complaints or enter custom text...'),
      const SizedBox(height: AppSpacing.xxl),
      _buildSectionHeader('History of Presenting Illness (HPI)', BootstrapIcons.clock_history),
      const SizedBox(height: AppSpacing.md),
      _buildTextArea(null, 'Detailed history of symptoms, duration, and severity...'),
    ]);
  }

  Widget _buildSoapTab() {
    return _buildTabContent([
      _buildSoapItem('Subjective', _subjectiveController, 'Patient reports, symptoms, history', BootstrapIcons.chat_left_dots),
      const SizedBox(height: AppSpacing.lg),
      _buildSoapItem('Objective', _objectiveController, 'Physical exam findings, clinical observations', BootstrapIcons.eye),
      const SizedBox(height: AppSpacing.lg),
      _buildSoapItem('Assessment', _assessmentController, 'Diagnosis and clinical impression', BootstrapIcons.activity),
      const SizedBox(height: AppSpacing.lg),
      _buildSoapItem('Plan', _planController, 'Management plan, follow-up, advice', BootstrapIcons.clipboard_check),
    ]);
  }

  Widget _buildDiagnosisTab() {
    return _buildEmptyTab(BootstrapIcons.search, 'No Diagnoses Added', 'Search for ICD-11 codes or clinical conditions');
  }

  Widget _buildPrescriptionTab() {
    return _buildEmptyTab(BootstrapIcons.capsule, 'No Medications Prescribed', 'Search facility inventory to add medications');
  }

  Widget _buildLabOrdersTab() {
    return _buildEmptyTab(BootstrapIcons.droplet_half, 'No Lab Orders', 'Add test requests to be sent to the laboratory');
  }

  Widget _buildTabContent(List<Widget> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryColor),
        const SizedBox(width: AppSpacing.md),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
      ],
    );
  }

  Widget _buildTextArea(TextEditingController? ctrl, String hint) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppTheme.borderLight)),
      child: TextFormField(
        controller: ctrl,
        maxLines: 4,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none, contentPadding: const EdgeInsets.all(AppSpacing.md)),
      ),
    );
  }

  Widget _buildSoapItem(String title, TextEditingController ctrl, String hint, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title, icon),
        const SizedBox(height: AppSpacing.sm),
        _buildTextArea(ctrl, hint),
      ],
    );
  }

  Widget _buildEmptyTab(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppTheme.surfaceLight, shape: BoxShape.circle), child: Icon(icon, size: 48, color: AppTheme.textSecondaryLight.withOpacity(0.3))),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: const TextStyle(color: AppTheme.textSecondaryLight)),
          const SizedBox(height: AppSpacing.xl),
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(BootstrapIcons.plus), label: const Text('Add Entry')),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(color: AppTheme.surfaceLight, border: Border(top: BorderSide(color: AppTheme.borderLight))),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(BootstrapIcons.save), label: const Text('Save Draft'))),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : () async {
                  setState(() => _isSaving = true);
                  await Future.delayed(const Duration(milliseconds: 800));
                  if (mounted) Navigator.of(context).pop();
                },
                icon: const Icon(BootstrapIcons.check2_all),
                label: const Text('Complete Consultation'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
