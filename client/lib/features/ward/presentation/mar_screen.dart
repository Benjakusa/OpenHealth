import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/ward_provider.dart';
import '../../../core/services/api_service.dart';

class MarScreen extends ConsumerStatefulWidget {
  final String admissionId;

  const MarScreen({super.key, required this.admissionId});

  @override
  ConsumerState<MarScreen> createState() => _MarScreenState();
}

class _MarScreenState extends ConsumerState<MarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final marAsync = ref.watch(marProvider({
      'admissionId': widget.admissionId,
      'date': dateStr,
    }));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Administration'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Scheduled'),
            Tab(text: 'Given'),
            Tab(text: 'Missed'),
            Tab(text: 'Refused'),
          ],
        ),
      ),
      body: Column(
        children: [
          _DateSelector(
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() => _selectedDate = date);
            },
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _MarList(
                  admissionId: widget.admissionId,
                  status: 'scheduled',
                  date: dateStr,
                  emptyMessage: 'No scheduled medications',
                ),
                _MarList(
                  admissionId: widget.admissionId,
                  status: 'given',
                  date: dateStr,
                  emptyMessage: 'No medications given yet',
                ),
                _MarList(
                  admissionId: widget.admissionId,
                  status: 'missed',
                  date: dateStr,
                  emptyMessage: 'No missed medications',
                ),
                _MarList(
                  admissionId: widget.admissionId,
                  status: 'refused',
                  date: dateStr,
                  emptyMessage: 'No refused medications',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const _DateSelector({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              onDateSelected(selectedDate.subtract(const Duration(days: 1)));
            },
          ),
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                onDateSelected(date);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('EEEE, dd MMM yyyy').format(selectedDate),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              onDateSelected(selectedDate.add(const Duration(days: 1)));
            },
          ),
        ],
      ),
    );
  }
}

class _MarList extends ConsumerWidget {
  final String admissionId;
  final String status;
  final String date;
  final String emptyMessage;

  const _MarList({
    required this.admissionId,
    required this.status,
    required this.date,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marAsync = ref.watch(marProvider({
      'admissionId': admissionId,
      'status': status,
      'date': date,
    }));

    return marAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (records) {
        if (records.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medication, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(emptyMessage, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        final groupedRecords = _groupByTime(records);

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groupedRecords.length,
          itemBuilder: (context, index) {
            final timeSlot = groupedRecords.keys.elementAt(index);
            final slotRecords = groupedRecords[timeSlot]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    timeSlot,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                ...slotRecords.map((record) => _MarCard(
                  record: record,
                  onAdminister: status == 'scheduled' ? () => _showAdministerDialog(context, ref, record) : null,
                )),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }

  Map<String, List<MedicationRecord>> _groupByTime(List<MedicationRecord> records) {
    final Map<String, List<MedicationRecord>> grouped = {};
    for (final record in records) {
      final timeKey = DateFormat('HH:mm').format(record.scheduledTime);
      grouped.putIfAbsent(timeKey, () => []);
      grouped[timeKey]!.add(record);
    }
    return grouped;
  }

  void _showAdministerDialog(BuildContext context, WidgetRef ref, MedicationRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AdministerMedicationSheet(
        record: record,
        onComplete: () {
          ref.invalidate(marProvider({'admissionId': admissionId, 'date': date}));
        },
      ),
    );
  }
}

class _MarCard extends StatelessWidget {
  final MedicationRecord record;
  final VoidCallback? onAdminister;

  const _MarCard({
    required this.record,
    this.onAdminister,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onAdminister,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getStatusColor(record.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getStatusIcon(record.status),
                  color: _getStatusColor(record.status),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.medicationName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${record.dosage} - ${_formatRoute(record.route)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    if (record.site != null)
                      Text(
                        'Site: ${record.site}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('HH:mm').format(record.scheduledTime),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (record.administeredTime != null)
                    Text(
                      'Given: ${DateFormat('HH:mm').format(record.administeredTime!)}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  if (record.nurseName != null)
                    Text(
                      'by ${record.nurseName}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                ],
              ),
              if (onAdminister != null) ...[
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ],
          ),
        ),
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

  String _formatRoute(String route) {
    return route.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
  }
}

class _AdministerMedicationSheet extends StatefulWidget {
  final MedicationRecord record;
  final VoidCallback onComplete;

  const _AdministerMedicationSheet({
    required this.record,
    required this.onComplete,
  });

  @override
  State<_AdministerMedicationSheet> createState() => _AdministerMedicationSheetState();
}

class _AdministerMedicationSheetState extends State<_AdministerMedicationSheet> {
  final _api = ApiService();
  bool _isLoading = false;
  String _response = 'given';
  final _notesController = TextEditingController();
  final _siteController = TextEditingController();
  final _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quantityController.text = widget.record.quantityGiven?.toString() ?? '1';
  }

  @override
  void dispose() {
    _notesController.dispose();
    _siteController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    try {
      await _api.post('/ward/mar/${widget.record.id}/administer', {
        'response': _response,
        'quantityGiven': double.tryParse(_quantityController.text),
        'site': _siteController.text.isNotEmpty ? _siteController.text : null,
        'notes': _notesController.text.isNotEmpty ? _notesController.text : null,
      });

      if (mounted) {
        Navigator.pop(context);
        widget.onComplete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication administered')),
        );
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medication, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.record.medicationName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.record.dosage} - ${widget.record.route}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Response', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Given'),
                  selected: _response == 'given',
                  onSelected: (v) => setState(() => _response = 'given'),
                ),
                ChoiceChip(
                  label: const Text('Refused'),
                  selected: _response == 'refused',
                  onSelected: (v) => setState(() => _response = 'refused'),
                ),
                ChoiceChip(
                  label: const Text('Nauseated'),
                  selected: _response == 'nauseated',
                  onSelected: (v) => setState(() => _response = 'nauseated'),
                ),
                ChoiceChip(
                  label: const Text('Vomited'),
                  selected: _response == 'vomited',
                  onSelected: (v) => setState(() => _response = 'vomited'),
                ),
              ],
            ),
            if (_response == 'given') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _siteController,
                      decoration: const InputDecoration(
                        labelText: 'Site (e.g., Left arm)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Confirm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
