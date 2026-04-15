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
        title: const Text('Organization Console'),
        actions: [
          IconButton(
            icon: const Icon(BootstrapIcons.box_arrow_right),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrgStats(),
            const SizedBox(height: AppSpacing.xxl),
            const Text('Pending Approvals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.lg),
            _buildApprovalQueue(),
            const SizedBox(height: AppSpacing.xxl),
            const Text('Manage Clinics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.lg),
            _buildFacilitiesGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrgStats() {
    return Row(
      children: [
        Expanded(child: _StatCard('Total Clinics', '5', BootstrapIcons.hospital, AppTheme.primaryColor)),
        const SizedBox(width: AppSpacing.lg),
        Expanded(child: _StatCard('Total Staff', '48', BootstrapIcons.people, AppTheme.successColor)),
        const SizedBox(width: AppSpacing.lg),
        Expanded(child: _StatCard('Monthly Revenue', 'KES 840k', BootstrapIcons.wallet2, Colors.blue)),
        const SizedBox(width: AppSpacing.lg),
        Expanded(child: _StatCard('Pending Users', '3', BootstrapIcons.person_plus, Colors.orange)),
      ],
    );
  }

  Widget _buildApprovalQueue() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildApprovalItem('John Doe', 'Doctor', 'City Main Hospital', '2 hours ago'),
          const Divider(height: 1),
          _buildApprovalItem('Jane Smith', 'Nurse', 'Westside Clinic', '5 hours ago'),
          const Divider(height: 1),
          _buildApprovalItem('Robert Wilson', 'Receptionist', 'City Main Hospital', 'Yesterday'),
        ],
      ),
    );
  }

  Widget _buildApprovalItem(String name, String role, String clinic, String time) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        child: Text(name[0], style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('$role • $clinic • $time'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(onPressed: () {}, child: const Text('Reject', style: TextStyle(color: AppTheme.errorColor))),
          const SizedBox(width: AppSpacing.sm),
          ElevatedButton(onPressed: () {}, child: const Text('Approve')),
        ],
      ),
    );
  }

  Widget _buildFacilitiesGrid() {
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
            childAspectRatio: 1.8,
          ),
          itemCount: 3, // Mock data
          itemBuilder: (context, index) => _FacilityCard(index: index),
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

class _FacilityCard extends StatelessWidget {
  final int index;
  const _FacilityCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final names = ['City Main Hospital', 'Westside Clinic', 'Eastlands Medical Centre'];
    final codes = ['A3B9', 'C2D4', 'X1Y7'];
    
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
                _StatusBadge(status: 'Active'),
              ],
            ),
            const SizedBox(height: 4),
            Text('Clinic Code: ${codes[index]}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            const Spacer(),
            const Row(
              children: [
                Icon(BootstrapIcons.people, size: 14, color: AppTheme.textSecondaryLight),
                SizedBox(width: 4),
                Text('24 Staff', style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryLight)),
                SizedBox(width: 16),
                Icon(BootstrapIcons.activity, size: 14, color: AppTheme.textSecondaryLight),
                SizedBox(width: 4),
                Text('Active Now', style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryLight)),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {}, 
                  child: const Text('Settings'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('View Data'),
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
