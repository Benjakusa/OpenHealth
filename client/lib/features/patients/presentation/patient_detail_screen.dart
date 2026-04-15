import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../../../core/config/theme.dart';
import '../../../core/services/database_service.dart';
import '../data/patient_provider.dart';

class PatientDetailScreen extends ConsumerStatefulWidget {
  final String patientId;
  const PatientDetailScreen({super.key, required this.patientId});

  @override
  ConsumerState<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends ConsumerState<PatientDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isStartingEncounter = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientAsync = ref.watch(patientDetailProvider(widget.patientId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Patient Record'),
        actions: [
          IconButton(
            icon: const Icon(BootstrapIcons.pencil_square, size: 20),
            onPressed: () => context.push('/patients/${widget.patientId}/edit'),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: patientAsync.when(
        data: (patient) => patient == null ? _buildNotFound() : _buildContent(patient),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _buildError(err),
      ),
    );
  }

  Widget _buildContent(PatientData patient) {
    final age = DateTime.now().difference(patient.dateOfBirth).inDays ~/ 365;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;

    return Column(
      children: [
        _buildProfileHeader(patient, age, isDesktop),
        const Divider(height: 1),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(patient),
              _buildClinicalTab(patient),
              _buildHistoryTab(patient),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(PatientData patient, int age, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      color: AppTheme.surfaceLight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(patient),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${patient.firstName} ${patient.lastName}',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (isDesktop) _buildActionButtons(patient),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.md,
                  children: [
                    _buildHeaderBadge(BootstrapIcons.hash, patient.patientNumber),
                    _buildHeaderBadge(BootstrapIcons.person, '${patient.gender.substring(0, 1).toUpperCase()} • $age yrs'),
                    if (patient.phone != null) _buildHeaderBadge(BootstrapIcons.phone, patient.phone!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(PatientData patient) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: () => context.push('/billing?patientId=${widget.patientId}'),
          icon: const Icon(BootstrapIcons.receipt, size: 16),
          label: const Text('Billing'),
        ),
        const SizedBox(width: AppSpacing.md),
        ElevatedButton.icon(
          onPressed: _isStartingEncounter ? null : () => _startEncounter(patient),
          icon: _isStartingEncounter 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(BootstrapIcons.plus_circle, size: 16),
          label: Text(_isStartingEncounter ? 'Starting...' : 'New Encounter'),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.surfaceLight,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        tabs: const [
          Tab(text: 'General Info'),
          Tab(text: 'Clinical Records'),
          Tab(text: 'Visit History'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(PatientData patient) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: LayoutBuilder(builder: (context, constraints) {
        final cols = constraints.maxWidth > 800 ? 2 : 1;
        return Column(
          children: [
            if (constraints.maxWidth < 1024) ...[
              _buildActionButtons(patient),
              const SizedBox(height: AppSpacing.xl),
            ],
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              mainAxisSpacing: AppSpacing.lg,
              crossAxisSpacing: AppSpacing.lg,
              childAspectRatio: 4,
              children: [
                _buildInfoTile('National ID', patient.nationalId ?? 'N/A', BootstrapIcons.card_heading),
                _buildInfoTile('Email', patient.email ?? 'N/A', BootstrapIcons.envelope),
                _buildInfoTile('County', patient.county ?? 'N/A', BootstrapIcons.geo_alt),
                _buildInfoTile('D.O.B', '${patient.dateOfBirth.day}/${patient.dateOfBirth.month}/${patient.dateOfBirth.year}', BootstrapIcons.calendar_date),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildInsuranceSection(patient),
          ],
        );
      }),
    );
  }

  Widget _buildClinicalTab(PatientData patient) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClinicalCard(
            'Allergies', 
            patient.allergies.isEmpty ? ['No known allergies'] : patient.allergies,
            BootstrapIcons.exclamation_triangle,
            patient.allergies.isEmpty ? AppTheme.successColor : AppTheme.errorColor,
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildClinicalCard('Chronic Conditions', ['N/A'], BootstrapIcons.activity, AppTheme.primaryColor),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(PatientData patient) {
    final encountersAsync = ref.watch(patientEncountersProvider(widget.patientId));
    return encountersAsync.when(
      data: (encounters) => encounters.isEmpty 
          ? _buildEmptyState('No past visits') 
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: encounters.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, i) => _VisitCard(encounter: encounters[i]),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading history: $e')),
    );
  }

  Widget _buildAvatar(PatientData patient) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
      ),
      child: Center(
        child: Text(
          '${patient.firstName[0]}${patient.lastName[0]}',
          style: const TextStyle(color: AppTheme.primaryColor, fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHeaderBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.textSecondaryLight.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondaryLight),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondaryLight)),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryLight)),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildInsuranceSection(PatientData patient) {
    final sha = patient.sha;
    final ins = patient.insurance;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Insurance & Health Coverage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(child: _InsuranceBadge(title: 'SHA', subtitle: sha?['memberNumber'] ?? 'Not Enrolled', isActive: sha?['active'] ?? false)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _InsuranceBadge(title: 'Private', subtitle: ins?['provider'] ?? 'Not Enrolled', isActive: ins?['active'] ?? false)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicalCard(String title, List<String> items, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.04),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: color.withOpacity(0.1))),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: AppSpacing.md),
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: items.map((item) => Chip(
                label: Text(item),
                backgroundColor: color.withOpacity(0.1),
                side: BorderSide.none,
                labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startEncounter(PatientData patient) async {
    setState(() => _isStartingEncounter = true);
    try {
      final db = ref.read(databaseServiceProvider);
      final id = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
      final num = 'ENC-${DateTime.now().year}$id';
      
      await db.saveEncounter({
        'encounterNumber': num,
        'patientId': patient.id,
        'providerId': 'current_user',
        'status': 'pending_triage',
      });

      if (mounted) {
        context.push('/encounter/$id');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isStartingEncounter = false);
    }
  }

  Widget _buildEmptyState(String msg) => Center(child: Text(msg, style: const TextStyle(color: AppTheme.textSecondaryLight)));
  Widget _buildNotFound() => const Center(child: Text('Patient not found'));
  Widget _buildError(Object err) => Center(child: Text('Error: $err', style: const TextStyle(color: AppTheme.errorColor)));
}

class _InsuranceBadge extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isActive;
  const _InsuranceBadge({required this.title, required this.subtitle, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.successColor : AppTheme.textSecondaryLight.withOpacity(0.4);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
              const Spacer(),
              Icon(isActive ? BootstrapIcons.check_circle_fill : BootstrapIcons.x_circle, color: color, size: 14),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  final EncounterData encounter;
  const _VisitCard({required this.encounter});

  @override
  Widget build(BuildContext context) {
    final date = '${encounter.createdAt.day}/${encounter.createdAt.month}/${encounter.createdAt.year}';
    return Card(
      child: ListTile(
        onTap: () => context.push('/encounter/${encounter.id}'),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(BootstrapIcons.clipboard_pulse, color: AppTheme.primaryColor, size: 20),
        ),
        title: Text(encounter.encounterNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date),
        trailing: _StatusChip(status: encounter.status),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'completed': color = AppTheme.successColor; break;
      case 'pending_triage': color = AppTheme.warningColor; break;
      case 'in_progress': color = AppTheme.primaryColor; break;
      default: color = AppTheme.textSecondaryLight;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(status.replaceAll('_', ' ').toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
