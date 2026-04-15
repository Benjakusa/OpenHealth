import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../../../core/config/theme.dart';
import '../../auth/presentation/auth_controller.dart';

class PlatformAdminDashboard extends ConsumerWidget {
  const PlatformAdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            Row(
              children: [
                _buildStatCard('Total Tenants', '124', BootstrapIcons.buildings, Colors.blue),
                const SizedBox(width: AppSpacing.lg),
                _buildStatCard('Active Clinics', '482', BootstrapIcons.hospital, Colors.green),
                const SizedBox(width: AppSpacing.lg),
                _buildStatCard('Total Patients', '12.5k', BootstrapIcons.people, Colors.orange),
                const SizedBox(width: AppSpacing.lg),
                _buildStatCard('System Health', '99.9%', BootstrapIcons.activity, Colors.purple),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            const Text(
              'Recent Tenants',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildTenantTable(),
          ],
        ),
      ),
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

  Widget _buildTenantTable() {
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
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(1),
          4: FlexColumnWidth(1),
        },
        children: [
          _buildTableHeader(),
          _buildTableRow('Aga Khan University Hospital', 'Nairobi', 'Premium', 'Active', '12 Clinics'),
          _buildTableRow('Gertrude\'s Children\'s Hospital', 'Muthaiga', 'Standard', 'Active', '8 Clinics'),
          _buildTableRow('Kenyatta National Hospital', 'Upperhill', 'Enterprise', 'Active', '1 Clinic'),
          _buildTableRow('Nairobi Hospital', 'Argwings Kodhek', 'Premium', 'Suspended', '3 Clinics'),
        ],
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
        ),
      ),
      children: [
        _buildTableCell('Tenant Name', isHeader: true),
        _buildTableCell('Location', isHeader: true),
        _buildTableCell('Package', isHeader: true),
        _buildTableCell('Status', isHeader: true),
        _buildTableCell('Scale', isHeader: true),
      ],
    );
  }

  TableRow _buildTableRow(String name, String loc, String pkg, String status, String scale) {
    return TableRow(
      children: [
        _buildTableCell(name),
        _buildTableCell(loc),
        _buildTableCell(pkg),
        _buildTableCell(status, isStatus: true),
        _buildTableCell(scale),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: isStatus 
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: text == 'Active' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: text == 'Active' ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          )
        : Text(
            text,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: isHeader ? Colors.grey[800] : Colors.grey[600],
            ),
          ),
    );
  }
}
