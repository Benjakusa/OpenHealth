import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../../../core/config/theme.dart';
import '../../auth/presentation/auth_controller.dart';

class SuperAdminDashboard extends ConsumerWidget {
  const SuperAdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Console'),
        actions: [
          IconButton(
            icon: const Icon(BootstrapIcons.plus_circle),
            onPressed: () {}, // Add Tenant
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGlobalStats(),
            const SizedBox(height: AppSpacing.xxl),
            const Text('Tenants Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.lg),
            _buildTenantsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalStats() {
    return Row(
      children: [
        Expanded(child: _StatCard('Total Tenants', '42', BootstrapIcons.building, AppTheme.primaryColor)),
        const SizedBox(width: AppSpacing.lg),
        Expanded(child: _StatCard('Active Hospitals', '156', BootstrapIcons.hospital, AppTheme.successColor)),
        const SizedBox(width: AppSpacing.lg),
        Expanded(child: _StatCard('Monthly Revenue', 'KES 2.4M', BootstrapIcons.wallet2, Colors.blue)),
        const SizedBox(width: AppSpacing.lg),
        Expanded(child: _StatCard('System Health', '99.9%', BootstrapIcons.activity, Colors.orange)),
      ],
    );
  }

  Widget _buildTenantsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 3 : (constraints.maxWidth > 800 ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
            childAspectRatio: 1.5,
          ),
          itemCount: 6, // Mock data
          itemBuilder: (context, index) => _TenantCard(index: index),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryLight)),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _TenantCard extends StatelessWidget {
  final int index;
  const _TenantCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final names = ['Metropolitan Group', 'St. Peters Hospital', 'Afya Connect', 'MediLink Solutions', 'Guardian Healthcare', 'Unity Medical'];
    final packages = ['HOSPITALI', 'AFYA', 'DAWA', 'HOSPITALI', 'AFYA', 'DAWA'];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(names[index], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                ),
                _StatusBadge(status: index % 3 == 0 ? 'Trial' : 'Active'),
              ],
            ),
            const SizedBox(height: 4),
            Text(packages[index], style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryColor.withOpacity(0.7))),
            const Spacer(),
            const Row(
              children: [
                Icon(BootstrapIcons.hospital, size: 14, color: AppTheme.textSecondaryLight),
                SizedBox(width: 4),
                Text('8 Facilities', style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryLight)),
                SizedBox(width: 16),
                Icon(BootstrapIcons.people, size: 14, color: AppTheme.textSecondaryLight),
                SizedBox(width: 4),
                Text('124 Users', style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryLight)),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () {}, child: const Text('Manage')),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: index % 4 == 0 ? AppTheme.errorColor : AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(index % 4 == 0 ? 'Suspend' : 'Monitor'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == 'Active' ? AppTheme.successColor : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
