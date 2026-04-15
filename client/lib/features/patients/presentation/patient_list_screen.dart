import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../../../core/config/theme.dart';
import '../data/patient_provider.dart';

class PatientListScreen extends ConsumerStatefulWidget {
  const PatientListScreen({super.key});

  @override
  ConsumerState<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends ConsumerState<PatientListScreen> {
  final _searchController = TextEditingController();
  String? _searchQuery;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientListProvider(
      PatientQuery(search: _searchQuery, limit: 50),
    ));
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Scaffold(
      backgroundColor: Colors.transparent, // Handled by scaffold body container
      body: Column(
        children: [
          _buildHeader(context, isMobile),
          Expanded(
            child: patientsAsync.when(
              data: (patients) => patients.isEmpty 
                  ? _buildEmptyState() 
                  : _buildList(patients, isMobile),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => _buildErrorState(err),
            ),
          ),
        ],
      ),
      floatingActionButton: isMobile ? FloatingActionButton(
        onPressed: () => context.push('/patients/new'),
        child: const Icon(BootstrapIcons.plus),
      ) : null,
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceLight,
        border: Border(bottom: BorderSide(color: AppTheme.borderLight)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Patients', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (!isMobile)
                ElevatedButton.icon(
                  onPressed: () => context.push('/patients/new'),
                  icon: const Icon(BootstrapIcons.person_plus, size: 18),
                  label: const Text('Add Patient'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, phone or ID...',
                    prefixIcon: const Icon(BootstrapIcons.search, size: 18),
                    suffixIcon: _searchQuery != null ? IconButton(
                      icon: const Icon(BootstrapIcons.x, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = null);
                      },
                    ) : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v.isEmpty ? null : v),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _buildFilterButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<PatientData> patients, bool isMobile) {
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(patientListProvider),
      child: isMobile 
        ? ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: patients.length,
            itemBuilder: (context, i) => _PatientCard(patient: patients[i]),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : 2,
              crossAxisSpacing: AppSpacing.lg,
              mainAxisSpacing: AppSpacing.lg,
              mainAxisExtent: 110,
            ),
            itemCount: patients.length,
            itemBuilder: (context, i) => _PatientCard(patient: patients[i]),
          ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: IconButton(
        icon: const Icon(BootstrapIcons.sliders, size: 18, color: AppTheme.textPrimaryLight),
        onPressed: () {},
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(BootstrapIcons.people, size: 64, color: AppTheme.textSecondaryLight.withOpacity(0.3)),
          const SizedBox(height: AppSpacing.lg),
          const Text('No patients found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          const Text('Try adjusting your search or add a new patient.', style: TextStyle(color: AppTheme.textSecondaryLight)),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object err) {
    return Center(child: Text('Error: $err', style: const TextStyle(color: AppTheme.errorColor)));
  }
}

class _PatientCard extends StatelessWidget {
  final PatientData patient;
  const _PatientCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    final age = DateTime.now().difference(patient.dateOfBirth).inDays ~/ 365;
    return Card(
      child: InkWell(
        onTap: () => context.push('/patients/${patient.id}'),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${patient.firstName} ${patient.lastName}', 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text('#${patient.patientNumber}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryLight)),
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(BootstrapIcons.dot, size: 12, color: AppTheme.textSecondaryLight),
                        const SizedBox(width: AppSpacing.sm),
                        Text('$age yrs • ${patient.gender.substring(0, 1).toUpperCase()}', 
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryLight)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(BootstrapIcons.chevron_right, size: 16, color: AppTheme.textSecondaryLight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Center(
        child: Text(
          '${patient.firstName[0]}${patient.lastName[0]}',
          style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
