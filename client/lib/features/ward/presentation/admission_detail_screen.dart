import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/ward_provider.dart';
import 'nursing_note_form_screen.dart';
import 'mar_screen.dart';
import 'transfer_screen.dart';
import 'discharge_screen.dart';

class AdmissionDetailScreen extends ConsumerStatefulWidget {
  final String admissionId;

  const AdmissionDetailScreen({super.key, required this.admissionId});

  @override
  ConsumerState<AdmissionDetailScreen> createState() => _AdmissionDetailScreenState();
}

class _AdmissionDetailScreenState extends ConsumerState<AdmissionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final admissionAsync = ref.watch(admissionProvider(widget.admissionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admission Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(admissionProvider(widget.admissionId)),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'transfer':
                  _showTransferDialog();
                  break;
                case 'discharge':
                  _showDischargeDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'transfer',
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz),
                    SizedBox(width: 8),
                    Text('Transfer'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'discharge',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app),
                    SizedBox(width: 8),
                    Text('Discharge'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: admissionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (admission) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(admissionProvider(widget.admissionId)),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _PatientCard(admission: admission),
                const SizedBox(height: 16),
                _StatusCard(admission: admission),
                const SizedBox(height: 16),
                _ActionButtons(admissionId: widget.admissionId),
                const SizedBox(height: 16),
                _NursingNotesSection(admissionId: widget.admissionId),
                const SizedBox(height: 16),
                _MedicationSection(admissionId: widget.admissionId),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showTransferDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransferScreen(admissionId: widget.admissionId),
      ),
    );
  }

  void _showDischargeDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DischargeScreen(admissionId: widget.admissionId),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final Admission admission;

  const _PatientCard({required this.admission});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    admission.patient?.firstName.substring(0, 1).toUpperCase() ?? 'P',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        admission.patient?.fullName ?? 'Unknown',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        admission.patient?.patientNumber ?? '',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      if (admission.patient?.dateOfBirth != null)
                        Text(
                          'Age: ${_calculateAge(admission.patient!.dateOfBirth!)} years',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _InfoRow(label: 'Admission #', value: admission.admissionNumber),
            _InfoRow(label: 'Ward', value: admission.ward?.name ?? ''),
            _InfoRow(label: 'Bed', value: admission.bed?.bedNumber ?? ''),
            _InfoRow(label: 'Type', value: admission.admissionType.toUpperCase()),
            _InfoRow(
              label: 'Admitted',
              value: DateFormat('dd MMM yyyy, HH:mm').format(admission.admissionDate),
            ),
            if (admission.dischargeDate != null)
              _InfoRow(
                label: 'Discharged',
                value: DateFormat('dd MMM yyyy, HH:mm').format(admission.dischargeDate!),
              ),
          ],
        ),
      ),
    );
  }

  int _calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final Admission admission;

  const _StatusCard({required this.admission});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getStatusColor(admission.status).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(admission.status),
                  color: _getStatusColor(admission.status),
                ),
                const SizedBox(width: 8),
                Text(
                  'Status: ${admission.status.toUpperCase()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(admission.status),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Reason: ${admission.admissionReason}',
              style: const TextStyle(fontSize: 14),
            ),
            if (admission.presentingComplaint.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Presenting Complaint: ${admission.presentingComplaint}',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
            if (admission.specialRequirements.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: admission.specialRequirements.map((req) {
                  return Chip(
                    label: Text(req.replaceAll('_', ' ')),
                    backgroundColor: Colors.orange.withOpacity(0.2),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'critical':
        return Colors.red;
      case 'stable':
        return Colors.green;
      case 'discharged':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'critical':
        return Icons.warning;
      case 'stable':
        return Icons.check_circle;
      case 'discharged':
        return Icons.exit_to_app;
      default:
        return Icons.bed;
    }
  }
}

class _ActionButtons extends StatelessWidget {
  final String admissionId;

  const _ActionButtons({required this.admissionId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NursingNoteFormScreen(admissionId: admissionId),
                ),
              );
            },
            icon: const Icon(Icons.note_add),
            label: const Text('Add Note'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MarScreen(admissionId: admissionId),
                ),
              );
            },
            icon: const Icon(Icons.medication),
            label: const Text('Medications'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _NursingNotesSection extends ConsumerWidget {
  final String admissionId;

  const _NursingNotesSection({required this.admissionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(nursingNotesProvider(admissionId));

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
                  'Nursing Notes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NursingNoteFormScreen(admissionId: admissionId),
                      ),
                    );
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
            const Divider(),
            notesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Error: $e'),
              data: (notes) {
                if (notes.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('No nursing notes yet')),
                  );
                }
                return Column(
                  children: notes.take(5).map((note) => _NursingNoteTile(note: note)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NursingNoteTile extends StatelessWidget {
  final NursingNote note;

  const _NursingNoteTile({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getNoteTypeColor(note.noteType).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  note.noteType.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getNoteTypeColor(note.noteType),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('HH:mm').format(note.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(note.notes),
          if (note.nurseName != null) ...[
            const SizedBox(height: 4),
            Text(
              '- ${note.nurseName}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  Color _getNoteTypeColor(String type) {
    switch (type) {
      case 'vitals':
        return Colors.blue;
      case 'observation':
        return Colors.green;
      case 'intervention':
        return Colors.orange;
      case 'incident':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _MedicationSection extends ConsumerWidget {
  final String admissionId;

  const _MedicationSection({required this.admissionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final marAsync = ref.watch(marProvider({'admissionId': admissionId, 'date': today}));

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
                  'Today\'s Medications',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MarScreen(admissionId: admissionId),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const Divider(),
            marAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Error: $e'),
              data: (records) {
                if (records.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('No medications scheduled')),
                  );
                }
                return Column(
                  children: records.take(5).map((record) => _MedicationTile(record: record)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicationTile extends StatelessWidget {
  final MedicationRecord record;

  const _MedicationTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor(record.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getStatusColor(record.status).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(record.status),
            color: _getStatusColor(record.status),
          ),
          const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.medication,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${record.dosage ?? ''} - ${record.route ?? ''} - ${record.frequency ?? ''}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Text(
                record.scheduledTime != null ? DateFormat('HH:mm').format(record.scheduledTime!) : 'N/A',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'given':
        return Colors.green;
      case 'missed':
        return Colors.red;
      case 'refused':
        return Colors.orange;
      case 'scheduled':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'given':
        return Icons.check_circle;
      case 'missed':
        return Icons.cancel;
      case 'refused':
        return Icons.thumb_down;
      case 'scheduled':
        return Icons.schedule;
      default:
        return Icons.medication;
    }
  }
}
