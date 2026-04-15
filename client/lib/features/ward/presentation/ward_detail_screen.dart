import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../../../core/config/theme.dart';
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Ward Operations'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Bed Status'),
            Tab(text: 'Patient Census'),
            Tab(text: 'Clinical Notes'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(BootstrapIcons.arrow_clockwise, size: 18), onPressed: () => ref.invalidate(wardDashboardProvider(widget.wardId))),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: dashboardAsync.when(
        data: (data) => _buildContent(data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdmissionFormScreen(wardId: widget.wardId))),
        icon: const Icon(BootstrapIcons.person_plus, size: 18),
        label: const Text('Admit Patient'),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    final ward = Ward.fromJson(data['ward']);
    final beds = (data['beds'] as List?)?.map((b) => Bed.fromJson(b)).toList() ?? [];
    final stats = data['stats'] as Map<String, dynamic>? ?? {};
    final recentNotes = (data['recentNotes'] as List?)?.map((n) => NursingNote.fromJson(n)).toList() ?? [];

    return Column(
      children: [
        _WardDashboardHeader(ward: ward, stats: stats),
        const Divider(height: 1),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _BedsTab(beds: beds),
              _PatientsTab(wardId: widget.wardId),
              _NotesTab(notes: recentNotes),
            ],
          ),
        ),
      ],
    );
  }
}

class _WardDashboardHeader extends StatelessWidget {
  final Ward ward;
  final Map<String, dynamic> stats;
  const _WardDashboardHeader({required this.ward, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      color: AppTheme.surfaceLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ward.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('${ward.building ?? "Main Building"} • Floor ${ward.floor ?? 0}', style: const TextStyle(color: AppTheme.textSecondaryLight, fontSize: 13)),
                ],
              ),
              const Spacer(),
              _StatusBadge(status: ward.status),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatBlock('Total', '${stats['totalBeds'] ?? 0}', BootstrapIcons.hospital, AppTheme.primaryColor),
              _StatBlock('Available', '${stats['available'] ?? 0}', BootstrapIcons.check_circle, AppTheme.successColor),
              _StatBlock('Occupied', '${stats['occupied'] ?? 0}', BootstrapIcons.person, Colors.orange),
              _StatBlock('Critical', '${stats['criticalCount'] ?? 0}', BootstrapIcons.exclamation_triangle, AppTheme.errorColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatBlock(this.label, this.value, this.icon, this.color);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondaryLight)),
      ],
    );
  }
}

class _BedsTab extends StatelessWidget {
  final List<Bed> beds;
  const _BedsTab({required this.beds});

  @override
  Widget build(BuildContext context) {
    final available = beds.where((b) => b.status == 'available').toList();
    final occupied = beds.where((b) => b.status == 'occupied').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (available.isNotEmpty) ...[
            _SectionTitle('Available Beds (${available.length})', AppTheme.successColor),
            _BedGrid(beds: available),
            const SizedBox(height: AppSpacing.xxl),
          ],
          if (occupied.isNotEmpty) ...[
            _SectionTitle('Occupied Beds (${occupied.length})', Colors.orange),
            _BedGrid(beds: occupied),
          ],
        ],
      ),
    );
  }
}

class _BedGrid extends StatelessWidget {
  final List<Bed> beds;
  const _BedGrid({required this.beds});
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: beds.map((b) => _BedTile(bed: b)).toList(),
    );
  }
}

class _BedTile extends StatelessWidget {
  final Bed bed;
  const _BedTile({required this.bed});
  @override
  Widget build(BuildContext context) {
    final available = bed.status == 'available';
    final color = available ? AppTheme.successColor : Colors.orange;
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(
        children: [
          Icon(available ? BootstrapIcons.check_circle : BootstrapIcons.person_fill, size: 16, color: color),
          const SizedBox(height: 8),
          Text(bed.bedNumber, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          Text(bed.type.toUpperCase(), style: TextStyle(fontSize: 8, color: color.withOpacity(0.8))),
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
      data: (items) => items.isEmpty ? _buildEmpty('No patients currently admitted') : ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.xl),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, i) => _AdmissionListItem(admission: items[i]),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
  Widget _buildEmpty(String m) => Center(child: Text(m, style: const TextStyle(color: AppTheme.textSecondaryLight)));
}

class _AdmissionListItem extends StatelessWidget {
  final Admission admission;
  const _AdmissionListItem({required this.admission});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdmissionDetailScreen(admissionId: admission.id))),
        leading: CircleAvatar(backgroundColor: AppTheme.primaryColor.withOpacity(0.1), child: Text(admission.patient?.firstName[0] ?? 'P', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold))),
        title: Text(admission.patient?.fullName ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Bed ${admission.bed?.bedNumber ?? "N/A"} • ${admission.admissionNumber}', style: const TextStyle(fontSize: 12)),
        trailing: _StatusBadge(status: admission.status, compact: true),
      ),
    );
  }
}

class _NotesTab extends StatelessWidget {
  final List<NursingNote> notes;
  const _NotesTab({required this.notes});
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, i) => _NoteCard(note: notes[i]),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final NursingNote note;
  const _NoteCard({required this.note});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildNoteType(note.noteType),
            const Spacer(),
            Text('${note.createdAt.hour}:${note.createdAt.minute.toString().padLeft(2, "0")}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondaryLight)),
          ],
        ),
        const SizedBox(height: 8),
        Text(note.notes, style: const TextStyle(fontSize: 14, height: 1.4)),
        if (note.nurseName != null) ...[
          const SizedBox(height: 4),
          Text('— ${note.nurseName}', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.textSecondaryLight)),
        ],
      ],
    );
  }
  Widget _buildNoteType(String t) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.05), borderRadius: BorderRadius.circular(4)), child: Text(t.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)));
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionTitle(this.title, this.color);
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: AppSpacing.md), child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)));
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool compact;
  const _StatusBadge({required this.status, this.compact = false});
  @override
  Widget build(BuildContext context) {
    final active = status == 'active' || status == 'stable' || status == 'admitted';
    final color = active ? AppTheme.successColor : (status == 'critical' ? AppTheme.errorColor : AppTheme.textSecondaryLight);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 3 : 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: compact ? 9 : 11, fontWeight: FontWeight.bold)),
    );
  }
}
