import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../data/report_provider.dart';
import '../../../core/config/theme.dart';

class ReportsDashboardScreen extends ConsumerWidget {
  const ReportsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(icon: const Icon(BootstrapIcons.arrow_clockwise, size: 18), onPressed: () => ref.invalidate(dashboardStatsProvider)),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: statsAsync.when(
        data: (stats) => ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            _buildHeader(),
            const SizedBox(height: AppSpacing.xxl),
            _buildDashboard(stats, width),
            const SizedBox(height: AppSpacing.xxl),
            _buildQuickReports(context, width),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Operational Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()), style: const TextStyle(color: AppTheme.textSecondaryLight, fontSize: 13)),
      ],
    );
  }

  Widget _buildDashboard(DashboardStats stats, double width) {
    final cols = width > 1200 ? 3 : (width > 800 ? 2 : 1);
    return GridView.count(
      crossAxisCount: cols,
      crossAxisSpacing: AppSpacing.lg,
      mainAxisSpacing: AppSpacing.lg,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      children: [
        _StatCard('Patients', '${stats.patients.today}', 'Today', BootstrapIcons.people, AppTheme.primaryColor),
        _StatCard('Revenue', 'KES ${NumberFormat("#,###").format(stats.revenue.today)}', 'Today', BootstrapIcons.wallet2, AppTheme.successColor),
        _StatCard('Encounters', '${stats.encounters.today}', 'Today', BootstrapIcons.clipboard_pulse, Colors.blue),
        _StatCard('Admissions', '${stats.admissions.active}', 'Current', BootstrapIcons.hospital, Colors.orange),
        _StatCard('Lab Pending', '${stats.pending.lab}', 'Awaiting', BootstrapIcons.droplet_half, Colors.purple),
        _StatCard('Pharmacy', '${stats.pending.pharmacy}', 'Pending', BootstrapIcons.capsule, Colors.teal),
      ],
    );
  }

  Widget _buildQuickReports(BuildContext context, double width) {
    final cols = width > 1000 ? 4 : (width > 600 ? 2 : 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Reports', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.lg),
        GridView.count(
          crossAxisCount: cols,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.8,
          children: [
            _ReportBtn('Financial', BootstrapIcons.file_earmark_bar_graph, Colors.green),
            _ReportBtn('Clinical', BootstrapIcons.file_earmark_medical, Colors.blue),
            _ReportBtn('Patient Registry', BootstrapIcons.file_earmark_person, Colors.purple),
            _ReportBtn('Inventory', BootstrapIcons.file_earmark_code, Colors.orange),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value, label;
  final IconData icon;
  final Color color;
  const _StatCard(this.title, this.value, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondaryLight, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            _TrendBadge(),
          ],
        ),
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppTheme.successColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: const Row(children: [Icon(BootstrapIcons.arrow_up_short, color: AppTheme.successColor, size: 14), Text('8%', style: TextStyle(color: AppTheme.successColor, fontSize: 10, fontWeight: FontWeight.bold))]));
  }
}

class _ReportBtn extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _ReportBtn(this.title, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
