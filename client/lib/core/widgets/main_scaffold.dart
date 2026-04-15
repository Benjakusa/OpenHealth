import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../config/theme.dart';
import '../services/sync_service.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<_NavItem> _navItems = [
    _NavItem(BootstrapIcons.people, 'Patients', '/patients'),
    _NavItem(BootstrapIcons.clipboard_pulse, 'Encounters', '/encounters'),
    _NavItem(BootstrapIcons.droplet_half, 'Ward', '/wards'),
    _NavItem(BootstrapIcons.cash_stack, 'Billing', '/billing'),
    _NavItem(BootstrapIcons.droplet_half, 'Laboratory', '/lab'),
    _NavItem(BootstrapIcons.capsule, 'Pharmacy', '/pharmacy'),
    _NavItem(BootstrapIcons.graph_up, 'Reports', '/reports'),
    _NavItem(BootstrapIcons.gear, 'Settings', '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final syncStatus = ref.watch(syncStatusProvider);
    final location = GoRouterState.of(context).matchedLocation;
    final width = MediaQuery.of(context).size.width;

    bool isMobile = width < 768;
    bool isTablet = width >= 768 && width < 1024;
    bool isDesktop = width >= 1024;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile ? _buildDrawer(location) : null,
      appBar: _buildTopBar(user, syncStatus, isMobile),
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(location, isTablet),
          Expanded(
            child: Container(
              color: AppTheme.backgroundLight,
              child: widget.child,
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile ? _buildBottomNav(location) : null,
    );
  }

  PreferredSizeWidget _buildTopBar(AuthUser? user, AsyncValue<SyncStatus> syncStatus, bool isMobile) {
    return AppBar(
      titleSpacing: isMobile ? 8 : 24,
      leading: isMobile ? IconButton(
        icon: const Icon(BootstrapIcons.list, size: 24),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ) : null,
      title: Row(
        children: [
          if (!isMobile) ...[
            const Icon(BootstrapIcons.heart_pulse_fill, color: AppTheme.primaryColor, size: 24),
            const SizedBox(width: AppSpacing.md),
            const Text('OpenHealth', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: AppSpacing.md),
          ],
          _buildFacilitySwitcher(user, isMobile),
        ],
      ),
      actions: [
        _buildSyncIndicator(syncStatus),
        const SizedBox(width: AppSpacing.md),
        _buildUserMenu(user),
        const SizedBox(width: AppSpacing.md),
      ],
    );
  }

  Widget _buildFacilitySwitcher(AuthUser? user, bool isMobile) {
    if (user == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            (Environment.facilityName ?? user.tenantName).toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryColor, letterSpacing: 1),
          ),
          if (user.role == 'SUPER_ADMIN' || user.role == 'FACILITY_ADMIN') ...[
            const SizedBox(width: 4),
            const Icon(BootstrapIcons.chevron_down, size: 12, color: AppTheme.primaryColor),
          ],
        ],
      ),
    );
  }

  Widget _buildSidebar(String currentLocation, bool isMini) {
    return Container(
      width: isMini ? 72 : 260,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceLight,
        border: Border(right: BorderSide(color: AppTheme.borderLight)),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _navItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = currentLocation.startsWith(item.path);
                return _SidebarItem(
                  item: item,
                  isSelected: isSelected,
                  isMini: isMini,
                  onTap: () => context.go(item.path),
                );
              },
            ),
          ),
          _SidebarFooter(isMini: isMini),
        ],
      ),
    );
  }

  Widget _buildDrawer(String currentLocation) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primaryColor),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(BootstrapIcons.heart_pulse_fill, color: Colors.white, size: 40),
                  const SizedBox(height: AppSpacing.sm),
                  const Text('OpenHealth', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: _navItems.map((item) {
                final isSelected = currentLocation.startsWith(item.path);
                return ListTile(
                  leading: Icon(item.icon, color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryLight),
                  title: Text(item.label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  selected: isSelected,
                  onTap: () {
                    context.go(item.path);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(String currentLocation) {
    final activeIndex = _navItems.take(5).toList().indexWhere((item) => currentLocation.startsWith(item.path));
    return NavigationBar(
      selectedIndex: activeIndex == -1 ? 0 : activeIndex,
      onDestinationSelected: (index) => context.go(_navItems[index].path),
      destinations: _navItems.take(5).map((item) => NavigationDestination(
        icon: Icon(item.icon),
        label: item.label,
      )).toList(),
    );
  }

  Widget _buildSyncIndicator(AsyncValue<SyncStatus> syncStatus) {
    return syncStatus.when(
      data: (status) => status.isSyncing 
        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
        : Icon(BootstrapIcons.cloud_check, color: AppTheme.successColor, size: 20),
      loading: () => const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
      error: (_, __) => const Icon(BootstrapIcons.cloud_slash, color: AppTheme.errorColor, size: 20),
    );
  }

  Widget _buildUserMenu(AuthUser? user) {
    return PopupMenuButton(
      offset: const Offset(0, 48),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        child: Text(user != null ? '${user.firstName[0]}${user.lastName[0]}' : 'U', 
                   style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
      itemBuilder: (context) => <PopupMenuEntry<dynamic>>[
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${user?.firstName} ${user?.lastName}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimaryLight)),
              Text(user?.role.toUpperCase() ?? '', style: const TextStyle(fontSize: 10, color: AppTheme.textSecondaryLight)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'profile', child: _MenuRow(BootstrapIcons.person, 'Profile')),
        const PopupMenuItem(value: 'logout', child: _MenuRow(BootstrapIcons.box_arrow_right, 'Logout')),
      ],
      onSelected: (val) {
        if (val == 'logout') ref.read(authStateProvider.notifier).logout();
      },
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final bool isMini;
  final VoidCallback onTap;

  const _SidebarItem({required this.item, required this.isSelected, required this.isMini, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: isMini 
          ? Center(child: Icon(item.icon, color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryLight))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(item.icon, color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryLight, size: 20),
                  const SizedBox(width: 16),
                  Text(item.label, style: TextStyle(color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimaryLight, 
                                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                ],
              ),
            ),
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  final bool isMini;
  const _SidebarFooter({required this.isMini});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.borderLight))),
      child: Row(
        mainAxisAlignment: isMini ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          const Icon(BootstrapIcons.question_circle, size: 20, color: AppTheme.textSecondaryLight),
          if (!isMini) ...[
            const SizedBox(width: 16),
            const Text('Help & Support', style: TextStyle(color: AppTheme.textSecondaryLight, fontSize: 13)),
          ],
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MenuRow(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 12),
        Text(label),
      ],
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;
  _NavItem(this.icon, this.label, this.path);
}

final syncStatusProvider = FutureProvider<SyncStatus>((ref) async {
  return SyncStatus(isSyncing: false, pendingChanges: 0, lastSyncAt: DateTime.now());
});
