import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/database_service.dart';
import '../data/patient_provider.dart';

class PatientDetailScreen extends ConsumerStatefulWidget {
  final String patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  ConsumerState<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends ConsumerState<PatientDetailScreen> {
  bool _isStartingEncounter = false;

  @override
  Widget build(BuildContext context) {
    final patientAsync = ref.watch(patientDetailProvider(widget.patientId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/patients/${widget.patientId}/edit'),
          ),
        ],
      ),
      body: patientAsync.when(
        data: (patient) {
          if (patient == null) {
            return const Center(child: Text('Patient not found'));
          }

          final age = DateTime.now().difference(patient.dateOfBirth).inDays ~/ 365;
          List<String> allergies = [];
          try {
            allergies = List<String>.from(jsonDecode(patient.allergies ?? '[]'));
          } catch (_) {}

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(patient.firstName, patient.lastName, patient.gender, age, patient.patientNumber),
                const SizedBox(height: 24),
                _buildInfoCard('Contact Information', [
                  if (patient.phone != null)
                    _InfoRow(icon: Icons.phone, label: 'Phone', value: patient.phone!),
                  if (patient.nationalId != null)
                    _InfoRow(icon: Icons.badge_outlined, label: 'National ID', value: patient.nationalId!),
                  if (patient.county != null)
                    _InfoRow(icon: Icons.location_on_outlined, label: 'County', value: patient.county!),
                  if (patient.email != null)
                    _InfoRow(icon: Icons.email_outlined, label: 'Email', value: patient.email!),
                ]),
                const SizedBox(height: 16),
                if (allergies.isNotEmpty)
                  _buildAllergiesCard(allergies)
                else
                  _buildNoAllergiesCard(),
                const SizedBox(height: 16),
                _buildInsuranceCard(patient.sha, patient.insurance),
                const SizedBox(height: 24),
                _buildEncountersCard(widget.patientId),
                const SizedBox(height: 24),
                _buildActionsCard(context, patient),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(patientDetailProvider(widget.patientId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String firstName, String lastName, String gender, int age, String patientNumber) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text(
                '${firstName[0]}${lastName[0]}',
                style: const TextStyle(
                  fontSize: 24,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$firstName $lastName',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    patientNumber,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$age years old, ${gender == 'male' ? 'Male' : 'Female'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<_InfoRow> rows) {
    if (rows.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...rows.map((row) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: row,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergiesCard(List<String> allergies) {
    return Card(
      color: AppTheme.errorColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: AppTheme.errorColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Allergies',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: allergies.map((allergy) => Chip(
                label: Text(allergy),
                backgroundColor: AppTheme.errorColor.withOpacity(0.1),
                labelStyle: TextStyle(color: AppTheme.errorColor),
                visualDensity: VisualDensity.compact,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAllergiesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.successColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'No known allergies',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceCard(String? shaJson, String? insuranceJson) {
    bool shaActive = false;
    bool insuranceActive = false;
    String? shaNumber;
    String? insuranceName;

    try {
      if (shaJson != null && shaJson.isNotEmpty) {
        final shaData = jsonDecode(shaJson);
        shaActive = shaData['active'] ?? false;
        shaNumber = shaData['memberNumber'];
      }
    } catch (_) {}

    try {
      if (insuranceJson != null && insuranceJson.isNotEmpty) {
        final insData = jsonDecode(insuranceJson);
        insuranceActive = insData['active'] ?? false;
        insuranceName = insData['provider'];
      }
    } catch (_) {}

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Insurance & SHA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InsuranceChip(
                    icon: Icons.health_and_safety,
                    label: 'SHA',
                    subtitle: shaActive ? (shaNumber ?? 'Active') : 'Not enrolled',
                    isActive: shaActive,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InsuranceChip(
                    icon: Icons.umbrella,
                    label: 'Insurance',
                    subtitle: insuranceActive ? (insuranceName ?? 'Active') : 'Not enrolled',
                    isActive: insuranceActive,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEncountersCard(String patientId) {
    final encountersAsync = ref.watch(patientEncountersProvider(patientId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Encounters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/encounters?patientId=$patientId'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            encountersAsync.when(
              data: (encounters) {
                if (encounters.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'No previous encounters',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  );
                }

                return Column(
                  children: encounters.take(3).map((encounter) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: _EncounterStatusBadge(status: encounter.status),
                    title: Text(encounter.encounterNumber),
                    subtitle: Text(_formatDate(encounter.createdAt)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/encounter/${encounter.id}'),
                  )).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Error: $error', style: TextStyle(color: AppTheme.errorColor)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context, PatientData patient) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _isStartingEncounter ? null : () => _startEncounter(context, patient),
              icon: _isStartingEncounter
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.add),
              label: Text(_isStartingEncounter ? 'Starting...' : 'Start New Encounter'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context.push('/billing?patientId=${widget.patientId}'),
              icon: const Icon(Icons.receipt_long),
              label: const Text('View Billing History'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startEncounter(BuildContext context, PatientData patient) async {
    setState(() => _isStartingEncounter = true);

    try {
      final database = ref.read(databaseServiceProvider);
      final counter = DateTime.now().millisecondsSinceEpoch.toString().substring(5);
      final encounterNumber = 'ENC-${DateTime.now().year}${counter.padLeft(6, '0')}';

      final encounterData = {
        'encounterNumber': encounterNumber,
        'patientId': patient.id,
        'providerId': 'current_user',
        'visitType': 'new',
        'status': 'pending_triage',
        'chiefComplaint': null,
      };

      await database.saveEncounter(encounterData);

      if (mounted) {
        final encounters = await database.getEncounters(patientId: patient.id);
        final newEncounter = encounters.first;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Encounter $encounterNumber created'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        context.push('/encounter/${newEncounter.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating encounter: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isStartingEncounter = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class _InsuranceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isActive;

  const _InsuranceChip({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.successColor.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? AppTheme.successColor : Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: isActive ? AppTheme.successColor : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _EncounterStatusBadge extends StatelessWidget {
  final String status;

  const _EncounterStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig[status] ?? _statusConfig['pending_triage']!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(config.icon, size: 16, color: config.color),
    );
  }

  static const _statusConfig = {
    'pending_triage': _StatusConfig(Icons.pending, AppTheme.warningColor, 'Pending'),
    'pending_doctor': _StatusConfig(Icons.schedule, AppTheme.warningColor, 'Pending'),
    'in_progress': _StatusConfig(Icons.play_arrow, AppTheme.infoColor, 'In Progress'),
    'completed': _StatusConfig(Icons.check_circle, AppTheme.successColor, 'Completed'),
    'cancelled': _StatusConfig(Icons.cancel, AppTheme.errorColor, 'Cancelled'),
    'referred': _StatusConfig(Icons.forward, AppTheme.mediumColor, 'Referred'),
    'admitted': _StatusConfig(Icons.local_hotel, AppTheme.primaryColor, 'Admitted'),
  };
}

class _StatusConfig {
  final IconData icon;
  final Color color;
  final String label;

  const _StatusConfig(this.icon, this.color, this.label);
}
