import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme.dart';
import '../../../core/services/database_service.dart';
import '../../patients/data/patient_provider.dart';

class EncounterListScreen extends ConsumerWidget {
  const EncounterListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final encountersAsync = ref.watch(encounterListProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'all', label: Text('All')),
                    ButtonSegment(value: 'pending_triage', label: Text('Pending Triage')),
                    ButtonSegment(value: 'in_progress', label: Text('In Progress')),
                    ButtonSegment(value: 'completed', label: Text('Completed')),
                  ],
                  selected: const {'all'},
                  onSelectionChanged: (selection) {},
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: encountersAsync.when(
            data: (encounters) {
              if (encounters.isEmpty) {
                return const Center(
                  child: Text('No encounters found'),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: encounters.length,
                itemBuilder: (context, index) {
                  return _EncounterCard(encounter: encounters[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          ),
        ),
      ],
    );
  }
}

final encounterListProvider = FutureProvider<List<EncounterData>>((ref) async {
  final database = ref.read(databaseServiceProvider);
  final results = await database.getEncounters();
  return results.map((m) => EncounterData.fromMap(m)).toList();
});

class _EncounterCard extends StatelessWidget {
  final EncounterData encounter;

  const _EncounterCard({required this.encounter});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.push('/encounter/${encounter.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _StatusBadge(status: encounter.status),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      encounter.encounterNumber,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Patient: ${encounter.patientId.substring(0, 8)}...',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDateTime(encounter.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig[status] ?? _statusConfig['pending_triage']!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: config.color,
        ),
      ),
    );
  }

  static const _statusConfig = {
    'pending_triage': _BadgeConfig('Pending Triage', AppTheme.warningColor),
    'pending_doctor': _BadgeConfig('Pending Doctor', AppTheme.warningColor),
    'in_progress': _BadgeConfig('In Progress', AppTheme.infoColor),
    'completed': _BadgeConfig('Completed', AppTheme.successColor),
    'cancelled': _BadgeConfig('Cancelled', AppTheme.errorColor),
    'referred': _BadgeConfig('Referred', AppTheme.mediumColor),
    'admitted': _BadgeConfig('Admitted', AppTheme.primaryColor),
  };
}

class _BadgeConfig {
  final String label;
  final Color color;

  const _BadgeConfig(this.label, this.color);
}
