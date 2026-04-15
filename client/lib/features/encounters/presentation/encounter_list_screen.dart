import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../../../core/config/theme.dart';
import '../data/encounter_provider.dart';

class EncounterListScreen extends ConsumerStatefulWidget {
  const EncounterListScreen({super.key});

  @override
  ConsumerState<EncounterListScreen> createState() => _EncounterListScreenState();
}

class _EncounterListScreenState extends ConsumerState<EncounterListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = _getStatusFromIndex(_tabController.index);
    final encountersAsync = ref.watch(encounterListProvider(
      EncounterQuery(status: status, search: _searchQuery),
    ));
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(isMobile),
          _buildTabs(),
          Expanded(
            child: encountersAsync.when(
              data: (encounters) => encounters.isEmpty 
                  ? _buildEmptyState() 
                  : _buildList(encounters),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: AppTheme.surfaceLight,
      child: Column(
        children: [
          Row(
            children: [
              const Text('Clinical Encounters', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (!isMobile)
                ElevatedButton.icon(
                  onPressed: () => context.push('/patients'),
                  icon: const Icon(BootstrapIcons.plus, size: 18),
                  label: const Text('Start New Visit'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search by encounter number or patient name...',
              prefixIcon: Icon(BootstrapIcons.search, size: 18),
            ),
            onChanged: (v) => setState(() => _searchQuery = v.isEmpty ? null : v),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: AppTheme.surfaceLight,
      alignment: Alignment.centerLeft,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        onTap: (_) => setState(() {}),
        tabs: const [
          Tab(text: 'All Visits'),
          Tab(text: 'In Triage'),
          Tab(text: 'Pending Doctor'),
          Tab(text: 'Completed'),
        ],
      ),
    );
  }

  Widget _buildList(List<EncounterData> encounters) {
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(encounterListProvider),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: encounters.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, i) => _EncounterListItem(encounter: encounters[i]),
      ),
    );
  }

  String? _getStatusFromIndex(int index) {
    switch (index) {
      case 1: return 'pending_triage';
      case 2: return 'pending_doctor';
      case 3: return 'completed';
      default: return null;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(BootstrapIcons.clipboard_check, size: 48, color: AppTheme.textSecondaryLight.withOpacity(0.3)),
          const SizedBox(height: AppSpacing.md),
          const Text('No encounters found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _EncounterListItem extends StatelessWidget {
  final EncounterData encounter;
  const _EncounterListItem({required this.encounter});

  @override
  Widget build(BuildContext context) {
    final date = '${encounter.createdAt.day}/${encounter.createdAt.month}/${encounter.createdAt.year}';
    return Card(
      child: InkWell(
        onTap: () => context.push('/encounter/${encounter.id}'),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(encounter.patientName ?? 'Unknown Patient', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(encounter.encounterNumber, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryLight)),
                        const SizedBox(width: 8),
                        const Text('•', style: TextStyle(color: AppTheme.textSecondaryLight)),
                        const SizedBox(width: 8),
                        Text(date, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryLight)),
                      ],
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: encounter.status),
              const SizedBox(width: AppSpacing.md),
              const Icon(BootstrapIcons.chevron_right, size: 16, color: AppTheme.textSecondaryLight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
      child: const Icon(BootstrapIcons.clipboard_pulse, color: AppTheme.primaryColor, size: 24),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (status) {
      case 'completed': color = AppTheme.successColor; icon = BootstrapIcons.check_circle_fill; break;
      case 'pending_triage': color = AppTheme.warningColor; icon = BootstrapIcons.hourglass_split; break;
      case 'pending_doctor': color = Colors.orange; icon = BootstrapIcons.person_gear; break;
      case 'in_progress': color = AppTheme.primaryColor; icon = BootstrapIcons.play_circle_fill; break;
      default: color = AppTheme.textSecondaryLight; icon = BootstrapIcons.info_circle;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(status.replaceAll('_', ' ').toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
