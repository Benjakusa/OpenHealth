import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ward_provider.dart';
import 'admission_form_screen.dart';
import 'admission_detail_screen.dart';

class WardDetailScreen extends ConsumerStatefulWidget {
  final String wardId;

  const WardDetailScreen({super.key, required this.wardId});

  @override
  ConsumerState<WardDetailScreen> createState() => _WardDetailScreenState();
}

class _WardDetailScreenState extends ConsumerState<WardDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    final dashboardAsync = ref.watch(wardDashboardProvider(widget.wardId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ward Details'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Beds'),
            Tab(text: 'Patients'),
            Tab(text: 'Notes'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(wardDashboardProvider(widget.wardId)),
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (data) {
          final ward = Ward.fromJson(data['ward']);
          final beds = (data['beds'] as List?)?.map((b) => Bed.fromJson(b)).toList() ?? [];
          final stats = data['stats'] as Map<String, dynamic>?;
          final recentNotes = (data['recentNotes'] as List?)?.map((n) => NursingNote.fromJson(n)).toList() ?? [];

          return Column(
            children: [
              _WardHeader(ward: ward, stats: stats ?? {}),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _BedsTab(wardId: widget.wardId, beds: beds),
                    _PatientsTab(wardId: widget.wardId),
                    _NotesTab(notes: recentNotes),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdmissionFormScreen(wardId: widget.wardId),
            ),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Admit Patient'),
      ),
    );
  }
}

class _WardHeader extends StatelessWidget {
  final Ward ward;
  final Map<String, dynamic> stats;

  const _WardHeader({required this.ward, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ward.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${ward.building ?? ""} ${ward.floor != null ? "Floor ${ward.floor}" : ""}'.trim(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ward.status == 'active' ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  ward.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'Total',
                value: '${stats['totalBeds'] ?? 0}',
                icon: Icons.bed,
                color: Colors.blue,
              ),
              _StatItem(
                label: 'Available',
                value: '${stats['available'] ?? 0}',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
              _StatItem(
                label: 'Occupied',
                value: '${stats['occupied'] ?? 0}',
                icon: Icons.person,
                color: Colors.orange,
              ),
              _StatItem(
                label: 'Pending Meds',
                value: '${stats['pendingMedications'] ?? 0}',
                icon: Icons.medication,
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _BedsTab extends ConsumerWidget {
  final String wardId;
  final List<Bed> beds;

  const _BedsTab({required this.wardId, required this.beds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (beds.isEmpty) {
      return const Center(child: Text('No beds configured'));
    }

    final availableBeds = beds.where((b) => b.status == 'available').toList();
    final occupiedBeds = beds.where((b) => b.status == 'occupied').toList();
    final otherBeds = beds.where((b) => b.status != 'available' && b.status != 'occupied').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (availableBeds.isNotEmpty) ...[
          _BedSection(
            title: 'Available (${availableBeds.length})',
            beds: availableBeds,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
        ],
        if (occupiedBeds.isNotEmpty) ...[
          _BedSection(
            title: 'Occupied (${occupiedBeds.length})',
            beds: occupiedBeds,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
        ],
        if (otherBeds.isNotEmpty) ...[
          _BedSection(
            title: 'Other (${otherBeds.length})',
            beds: otherBeds,
            color: Colors.grey,
          ),
        ],
      ],
    );
  }
}

class _BedSection extends StatelessWidget {
  final String title;
  final List<Bed> beds;
  final Color color;

  const _BedSection({
    required this.title,
    required this.beds,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: beds.map((bed) => _BedTile(bed: bed)).toList(),
        ),
      ],
    );
  }
}

class _BedTile extends StatelessWidget {
  final Bed bed;

  const _BedTile({required this.bed});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (bed.status) {
      case 'available':
        statusColor = Colors.green;
        statusIcon = Icons.check;
        break;
      case 'occupied':
        statusColor = Colors.orange;
        statusIcon = Icons.person;
        break;
      case 'maintenance':
        statusColor = Colors.red;
        statusIcon = Icons.build;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.circle;
    }

    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(statusIcon, color: statusColor),
          const SizedBox(height: 4),
          Text(
            bed.bedNumber,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          Text(
            bed.bedType,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientsTab extends ConsumerWidget {
  final String wardId;

  const _PatientsTab({required this.wardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admissionsAsync = ref.watch(admissionsProvider({'wardId': wardId, 'status': 'admitted,in_progress,stable,critical'}));

    return admissionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (admissions) {
        if (admissions.isEmpty) {
          return const Center(child: Text('No patients admitted'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: admissions.length,
          itemBuilder: (context, index) {
            final admission = admissions[index];
            return _AdmissionTile(admission: admission);
          },
        );
      },
    );
  }
}

class _AdmissionTile extends StatelessWidget {
  final Admission admission;

  const _AdmissionTile({required this.admission});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdmissionDetailScreen(admissionId: admission.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: _getStatusColor(admission.status),
                child: Text(
                  admission.patient?.firstName.substring(0, 1).toUpperCase() ?? 'P',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      admission.patient?.fullName ?? 'Unknown Patient',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Bed ${admission.bed?.bedNumber ?? 'N/A'} - ${admission.admissionNumber}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(admission.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  admission.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(admission.status),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
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
      case 'admitted':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }
}

class _NotesTab extends StatelessWidget {
  final List<NursingNote> notes;

  const _NotesTab({required this.notes});

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return const Center(child: Text('No recent notes'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getNoteTypeColor(note.noteType).withOpacity(0.1),
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
                      _formatTime(note.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(note.content),
                if (note.authorName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '- ${note.authorName}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
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
      case 'assessment':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
