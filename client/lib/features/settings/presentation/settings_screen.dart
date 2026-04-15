import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../../../core/config/theme.dart';
import '../../../core/config/environment.dart';
import '../../auth/presentation/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('System Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            _buildUserCard(user),
            const SizedBox(height: AppSpacing.xxl),
            _buildSyncSection(),
            const SizedBox(height: AppSpacing.xxl),
            _buildGroup('Facility Management', [
              _SettingsTile(BootstrapIcons.building, 'Facility Information', Environment.tenantName),
              _SettingsTile(BootstrapIcons.shield_check, 'Role & Permissions', user?.role ?? 'Staff'),
            ]),
            const SizedBox(height: AppSpacing.xl),
            _buildGroup('Preference & Tools', [
              _SettingsTile(BootstrapIcons.bell, 'Notifications', 'Alerts & Messages'),
              _SettingsTile(BootstrapIcons.cloud_arrow_up, 'Sync Settings', 'Every 30 seconds'),
              _SettingsTile(BootstrapIcons.lock, 'Security', 'Authentication & PIN'),
            ]),
            const SizedBox(height: AppSpacing.xl),
            _buildGroup('Support', [
              _SettingsTile(BootstrapIcons.question_circle, 'Help Center', 'Guides & Support'),
              _SettingsTile(BootstrapIcons.info_circle, 'About OpenHealth', 'v${Environment.appVersion}'),
            ]),
            const SizedBox(height: AppSpacing.xxl),
            _buildLogoutBtns(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(dynamic user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Row(
          children: [
            CircleAvatar(radius: 30, backgroundColor: AppTheme.primaryColor.withOpacity(0.1), child: Text(user != null ? '${user.firstName[0]}${user.lastName[0]}' : 'U', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 20))),
            const SizedBox(width: AppSpacing.xl),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${user?.firstName ?? "System"} ${user?.lastName ?? "User"}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(user?.email ?? 'No email associated', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondaryLight)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncSection() {
    return Card(
      color: AppTheme.primaryColor.withOpacity(0.04),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            const Icon(BootstrapIcons.cloud_check, color: AppTheme.successColor, size: 20),
            const SizedBox(width: AppSpacing.md),
            const Expanded(child: Text('Cloud Data Synchronized', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            TextButton(onPressed: () {}, child: const Text('Sync Now')),
          ],
        ),
      ),
    );
  }

  Widget _buildGroup(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor))),
        Card(child: Column(children: tiles)),
      ],
    );
  }

  Widget _buildLogoutBtns(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        OutlinedButton.icon(onPressed: () => context.go('/setup'), icon: const Icon(BootstrapIcons.arrow_left_right, size: 16), label: const Text('Switch Facility'), style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50))),
        const SizedBox(height: AppSpacing.md),
        TextButton.icon(
          onPressed: () => ref.read(authStateProvider.notifier).logout(),
          icon: const Icon(BootstrapIcons.box_arrow_right, size: 16),
          label: const Text('Sign Out'),
          style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor, minimumSize: const Size(double.infinity, 50)),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _SettingsTile(this.icon, this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 18, color: AppTheme.textSecondaryLight),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryLight)),
      trailing: const Icon(BootstrapIcons.chevron_right, size: 14, color: AppTheme.textSecondaryLight),
      onTap: () {},
    );
  }
}
