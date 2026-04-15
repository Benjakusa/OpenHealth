import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../../../core/config/theme.dart';
import '../../auth/presentation/auth_controller.dart';
import 'admin_providers.dart';

class SuperAdminDashboard extends ConsumerWidget {
  const SuperAdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingUsers = ref.watch(pendingUsersProvider);
    final clinics = ref.watch(clinicsProvider);

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
            _buildOrgStats(pendingUsers, clinics),
            const SizedBox(height: AppSpacing.xxl),
            const Text('Pending Approvals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.lg),
            pendingUsers.when(
              data: (users) => _buildApprovalQueue(context, ref, users),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading users: $e'),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const Text('Manage Clinics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.lg),
            clinics.when(
              data: (clinicList) => _buildFacilitiesGrid(clinicList),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading clinics: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrgStats(AsyncValue<List<Map<String, dynamic>>> pendingUsers, AsyncValue<List<Map<String, dynamic>>> clinics) {
    return Row(
      children: [
        Expanded(child: _StatCard('Clinics', clinics.value?.length.toString() ?? '...', BootstrapIcons.hospital, AppTheme.primaryColor)),
        const SizedBox(width: AppSpacing.lg),
        Expanded(child: _StatCard('Pending Users', pendingUsers.value?.length.toString() ?? '...', BootstrapIcons.person_plus, Colors.orange)),
      ],
    );
  }

  Widget _buildApprovalQueue(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> users) {
    if (users.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Center(child: Text('No users awaiting approval')),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: users.map((user) => Column(
          children: [
            _buildApprovalItem(context, ref, user),
            if (user != users.last) const Divider(height: 1),
          ],
        )).toList(),
      ),
    );
  }

  Widget _buildApprovalItem(BuildContext context, WidgetRef ref, Map<String, dynamic> user) {
    final name = '${user['firstName']} ${user['lastName']}';
    final role = user['role'];
    final clinic = user['facility']?['name'] ?? 'No clinic';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        child: Text(name[0], style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('$role • $clinic'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () async {
              final success = await ref.read(authStateProvider.notifier).approveUser(user['id'], false);
              if (success) ref.refresh(pendingUsersProvider);
            }, 
            child: const Text('Reject', style: TextStyle(color: AppTheme.errorColor)),
          ),
          const SizedBox(width: AppSpacing.sm),
          ElevatedButton(
            onPressed: () async {
              final success = await ref.read(authStateProvider.notifier).approveUser(user['id'], true);
              if (success) ref.refresh(pendingUsersProvider);
            }, 
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitiesGrid(List<Map<String, dynamic>> clinicList) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
            childAspectRatio: 2.0,
          ),
          itemCount: clinicList.length,
          itemBuilder: (context, index) => _FacilityCard(clinic: clinicList[index]),
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
            const SizedBox(height: AppSpacing.md),
            Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryLight)),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _FacilityCard extends StatelessWidget {
  final Map<String, dynamic> clinic;
  const _FacilityCard({required this.clinic});

  @override
  Widget build(BuildContext context) {
    final List users = clinic['users'] ?? [];
    final staffCount = users.length;
    
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
                  child: Text(clinic['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                ),
                _StatusBadge(status: clinic['status'] == 'active' ? 'Active' : 'Inactive'),
              ],
            ),
            const SizedBox(height: 4),
            Text('Clinic Code: ${clinic['code']}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            const Spacer(),
            Row(
              children: [
                const Icon(BootstrapIcons.people, size: 14, color: AppTheme.textSecondaryLight),
                const SizedBox(width: 4),
                Text('$staffCount Staff', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryLight)),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {}, 
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
