import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme.dart';
import '../../../core/services/database_service.dart';
import '../../patients/data/patient_provider.dart';

class EncounterDetailScreen extends ConsumerWidget {
  final String encounterId;

  const EncounterDetailScreen({super.key, required this.encounterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final encounterAsync = ref.watch(encounterDetailProvider(encounterId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Encounter Details'),
      ),
      body: encounterAsync.when(
        data: (encounter) {
          if (encounter == null) {
            return const Center(child: Text('Encounter not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(encounter),
                const SizedBox(height: 16),
                if (encounter.triage != null) ...[
                  _buildTriageSection(encounter.triage!),
                  const SizedBox(height: 16),
                ],
                if (encounter.vitals != null) ...[
                  _buildVitalsSection(encounter.vitals!),
                  const SizedBox(height: 16),
                ],
                _buildDiagnosisSection(encounter.diagnoses),
                const SizedBox(height: 16),
                _buildPrescriptionsSection(encounter.prescriptions),
                const SizedBox(height: 16),
                _buildLabOrdersSection(encounter.labOrders),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      bottomNavigationBar: encounterAsync.valueOrNull != null
          ? _buildBottomBar(context, encounterAsync.value!)
          : null,
    );
  }

  Widget _buildHeader(EncounterData encounter) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  encounter.encounterNumber,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(encounter.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Started: ${_formatDateTime(encounter.startedAt ?? encounter.createdAt)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final config = {
      'pending_triage': (Colors.orange, 'Pending Triage'),
      'pending_doctor': (Colors.orange, 'Pending Doctor'),
      'in_progress': (Colors.blue, 'In Progress'),
      'completed': (Colors.green, 'Completed'),
    }[status] ?? (Colors.grey, status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.$1.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        config.$2,
        style: TextStyle(
          color: config.$1,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTriageSection(Map<String, dynamic>? triageData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.medical_services_outlined, size: 20),
                SizedBox(width: 8),
                Text(
                  'Triage Assessment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Triage completed',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalsSection(Map<String, dynamic>? vitalsData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.favorite_outline, size: 20),
                SizedBox(width: 8),
                Text(
                  'Vitals',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Vitals recorded',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosisSection(List<dynamic>? diagnoses) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.medical_information_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Diagnoses',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'No diagnoses recorded',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionsSection(List<dynamic>? prescriptions) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.medication_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Prescriptions',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'No prescriptions',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabOrdersSection(List<dynamic>? labOrders) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.science_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Lab Orders',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'No lab orders',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildBottomBar(BuildContext context, EncounterData encounter) {
    if (encounter.status == 'completed') return null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (encounter.status == 'pending_triage')
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push('/encounter/$encounterId/triage'),
                  icon: const Icon(Icons.assignment),
                  label: const Text('Start Triage'),
                ),
              ),
            if (encounter.status == 'pending_doctor' || encounter.status == 'in_progress')
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push('/encounter/$encounterId/consultation'),
                  icon: const Icon(Icons.medical_services_outlined),
                  label: const Text('Start Consultation'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

final encounterDetailProvider = FutureProvider.family<EncounterData?, String>((ref, id) async {
  final database = ref.read(databaseServiceProvider);
  final result = await database.getEncounter(id);
  return result != null ? EncounterData.fromMap(result) : null;
});
