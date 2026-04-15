import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../../../core/config/theme.dart';
import '../../auth/presentation/auth_controller.dart';
import 'admin_providers.dart';

class PlatformAdminDashboard extends ConsumerWidget {
  const PlatformAdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantsAsync = ref.watch(tenantsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Admin Portal'),
        actions: [
          IconButton(
            icon: const Icon(BootstrapIcons.box_arrow_right),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.xl),
            tenantsAsync.when(
              data: (tenants) => _buildStatsRow(tenants),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading stats: $e'),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const Text(
              'All Tenants',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.lg),
            tenantsAsync.when(
              data: (tenants) => _buildTenantTable(ref, tenants),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading tenants: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(List<Map<String, dynamic>> tenants) {
    return Row(
      children: [
        _buildStatCard('Total Tenants', tenants.length.toString(), BootstrapIcons.buildings, Colors.blue),
        const SizedBox(width: AppSpacing.lg),
        _buildStatCard('Active Subscriptions', tenants.where((t) => t['status'] == 'active').length.toString(), BootstrapIcons.check_circle, Colors.green),
        const SizedBox(width: AppSpacing.lg),
        _buildStatCard('Trial Accounts', tenants.where((t) => t['status'] == 'trial').length.toString(), BootstrapIcons.clock, Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTenantTable(WidgetRef ref, List<Map<String, dynamic>> tenants) {
    if (tenants.isEmpty) {
      return const Center(child: Text('No tenants found'));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          ...tenants.map((t) => _buildTenantRow(ref, t)).toList(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Tenant Name', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Package', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildTenantRow(WidgetRef ref, Map<String, dynamic> tenant) {
    final status = tenant['status'] ?? 'unknown';
    final isSuspended = status == 'suspended';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(tenant['name'], style: TextStyle(fontWeight: FontWeight.w500))),
          Expanded(flex: 2, child: Text(tenant['package'] ?? 'DEFAULT')),
          Expanded(
            flex: 2, 
            child: _StatusBadge(status: status),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isSuspended ? BootstrapIcons.play_circle : BootstrapIcons.pause_circle,
                    color: isSuspended ? Colors.green : Colors.orange,
                  ),
                  onPressed: () async {
                    final success = await ref.read(authStateProvider.notifier).suspendTenant(tenant['id'], !isSuspended);
                    if (success) ref.refresh(tenantsProvider);
                  },
                ),
                IconButton(
                  icon: const Icon(BootstrapIcons.trash, color: AppTheme.errorColor),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color color;
    switch (status) {
      case 'active': color = Colors.green; break;
      case 'trial': color = Colors.blue; break;
      case 'suspended': color = Colors.red; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
