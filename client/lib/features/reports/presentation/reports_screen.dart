import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/report_provider.dart';
import '../../../core/config/theme.dart';

class ReportsDashboardScreen extends ConsumerWidget {
  const ReportsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(dashboardStatsProvider),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (stats) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardStatsProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildPatientStats(context, stats),
              const SizedBox(height: 16),
              _buildRevenueStats(context, stats),
              const SizedBox(height: 16),
              _buildActivityStats(context, stats),
              const SizedBox(height: 24),
              _buildQuickReportButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildPatientStats(BuildContext context, DashboardStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.people, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Patients',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatColumn(
                  label: 'Today',
                  value: '${stats.patients.today}',
                  color: AppTheme.primaryColor,
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                _StatColumn(
                  label: 'This Month',
                  value: '${stats.patients.thisMonth}',
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueStats(BuildContext context, DashboardStats stats) {
    final currencyFormat = NumberFormat.currency(symbol: 'KSh ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.attach_money, color: AppTheme.successColor),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Revenue',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatColumn(
                  label: 'Today',
                  value: currencyFormat.format(stats.revenue.today),
                  color: AppTheme.successColor,
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                _StatColumn(
                  label: 'This Month',
                  value: currencyFormat.format(stats.revenue.thisMonth),
                  color: AppTheme.successColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityStats(BuildContext context, DashboardStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatColumn(
                  label: 'Encounters',
                  value: '${stats.encounters.today}',
                  color: Colors.blue,
                ),
                _StatColumn(
                  label: 'Admissions',
                  value: '${stats.admissions.active}',
                  color: Colors.orange,
                ),
                _StatColumn(
                  label: 'Lab Pending',
                  value: '${stats.pending.lab}',
                  color: Colors.purple,
                ),
                _StatColumn(
                  label: 'Pharmacy',
                  value: '${stats.pending.pharmacy}',
                  color: Colors.teal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReportButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Reports',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _QuickReportCard(
              title: 'Revenue',
              subtitle: 'Financial breakdown',
              icon: Icons.trending_up,
              color: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RevenueReportScreen()),
              ),
            ),
            _QuickReportCard(
              title: 'Clinical',
              subtitle: 'Encounters & diagnoses',
              icon: Icons.medical_services,
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ClinicalReportScreen()),
              ),
            ),
            _QuickReportCard(
              title: 'Patients',
              subtitle: 'Registrations & demographics',
              icon: Icons.people,
              color: Colors.purple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PatientReportScreen()),
              ),
            ),
            _QuickReportCard(
              title: 'Inventory',
              subtitle: 'Stock & expiry',
              icon: Icons.inventory,
              color: Colors.orange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InventoryReportScreen()),
              ),
            ),
            _QuickReportCard(
              title: 'Ward',
              subtitle: 'Occupancy & admissions',
              icon: Icons.bed,
              color: Colors.teal,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WardReportScreen()),
              ),
            ),
            _QuickReportCard(
              title: 'All Reports',
              subtitle: 'View generated reports',
              icon: Icons.folder,
              color: Colors.grey,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportListScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _QuickReportCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickReportCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RevenueReportScreen extends ConsumerStatefulWidget {
  const RevenueReportScreen({super.key});

  @override
  ConsumerState<RevenueReportScreen> createState() => _RevenueReportScreenState();
}

class _RevenueReportScreenState extends ConsumerState<RevenueReportScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(revenueReportProvider({
      'startDate': _startDate.toIso8601String().split('T')[0],
      'endDate': _endDate.toIso8601String().split('T')[0],
    }));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Revenue Report'),
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          Expanded(
            child: reportAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
              data: (report) => _buildReportContent(report),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Row(
        children: [
          Expanded(
            child: _DateButton(
              label: 'Start',
              date: _startDate,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2020),
                  lastDate: _endDate,
                );
                if (date != null) setState(() => _startDate = date);
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('to'),
          ),
          Expanded(
            child: _DateButton(
              label: 'End',
              date: _endDate,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: _startDate,
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _endDate = date);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(RevenueReportData report) {
    final currencyFormat = NumberFormat.currency(symbol: 'KSh ');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: AppTheme.successColor.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Total Revenue', style: TextStyle(fontSize: 14)),
                Text(
                  currencyFormat.format(report.summary.totalRevenue),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('${report.summary.totalTransactions} transactions'),
                    Text('${report.summary.uniquePatients} patients'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (report.byDepartment.isNotEmpty) ...[
          const Text('By Department', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...report.byDepartment.map((dept) => Card(
            child: ListTile(
              title: Text(dept.department),
              trailing: Text(
                currencyFormat.format(dept.total),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )),
        ],
        if (report.timeline.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Daily Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...report.timeline.take(10).map((day) => Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(DateFormat('d').format(day.date)),
              ),
              title: Text(DateFormat('MMM d, yyyy').format(day.date)),
              subtitle: Text('${day.transactionCount} transactions'),
              trailing: Text(
                currencyFormat.format(day.totalAmount),
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successColor),
              ),
            ),
          )),
        ],
      ],
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10)),
          Text(DateFormat('dd MMM yyyy').format(date)),
        ],
      ),
    );
  }
}

class ClinicalReportScreen extends ConsumerWidget {
  const ClinicalReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));

    final reportAsync = ref.watch(clinicalReportProvider({
      'startDate': startDate.toIso8601String().split('T')[0],
      'endDate': endDate.toIso8601String().split('T')[0],
    }));

    return Scaffold(
      appBar: AppBar(title: const Text('Clinical Report')),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (report) {
          final summary = report['summary'] as Map<String, dynamic>? ?? {};
          final topDiagnoses = (report['topDiagnoses'] as List? ?? []);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Colors.blue.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Total Encounters', style: TextStyle(fontSize: 14)),
                      Text(
                        '${summary['totalEncounters'] ?? 0}',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('Emergency: ${summary['emergency'] ?? 0}'),
                          Text('Completed: ${summary['completed'] ?? 0}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Top Diagnoses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ...topDiagnoses.map((d) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    child: Text('${d['count']}', style: const TextStyle(fontSize: 12)),
                  ),
                  title: Text(d['description'] ?? 'Unknown'),
                  subtitle: Text('ICD: ${d['code'] ?? 'N/A'}'),
                ),
              )),
            ],
          );
        },
      ),
    );
  }
}

class PatientReportScreen extends ConsumerWidget {
  const PatientReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));

    final reportAsync = ref.watch(patientReportProvider({
      'startDate': startDate.toIso8601String().split('T')[0],
      'endDate': endDate.toIso8601String().split('T')[0],
    }));

    return Scaffold(
      appBar: AppBar(title: const Text('Patient Report')),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (report) {
          final summary = report['summary'] as Map<String, dynamic>? ?? {};
          final ageDistribution = (report['ageDistribution'] as List? ?? []);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Colors.purple.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Total Registrations', style: TextStyle(fontSize: 14)),
                      Text(
                        '${summary['totalRegistrations'] ?? 0}',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.purple),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('Male: ${summary['maleCount'] ?? 0}'),
                          Text('Female: ${summary['femaleCount'] ?? 0}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Age Distribution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ...ageDistribution.map((d) => Card(
                child: ListTile(
                  title: Text(d['age_group'] ?? 'Unknown'),
                  trailing: Text('${d['count']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              )),
            ],
          );
        },
      ),
    );
  }
}

class InventoryReportScreen extends ConsumerWidget {
  const InventoryReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(inventoryReportProvider({}));

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Report')),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (report) {
          final summary = report['summary'] as Map<String, dynamic>? ?? {};
          final lowStock = (report['lowStock'] as List? ?? []);
          final expiringItems = (report['expiringItems'] as List? ?? []);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Colors.orange.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('${summary['totalReceived'] ?? 0}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                          const Text('Received'),
                        ],
                      ),
                      Column(
                        children: [
                          Text('${summary['totalDispensed'] ?? 0}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                          const Text('Dispensed'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (lowStock.isNotEmpty) ...[
                const Text('Low Stock Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
                const SizedBox(height: 8),
                ...lowStock.map((item) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.warning, color: Colors.red),
                    title: Text(item['name'] ?? 'Unknown'),
                    subtitle: Text('Qty: ${item['quantity']} (Reorder: ${item['reorderLevel']})'),
                  ),
                )),
                const SizedBox(height: 16),
              ],
              if (expiringItems.isNotEmpty) ...[
                const Text('Expiring Soon (30 days)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
                const SizedBox(height: 8),
                ...expiringItems.map((item) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.timer, color: Colors.orange),
                    title: Text(item['name'] ?? 'Unknown'),
                    subtitle: Text('Batch: ${item['batchNumber']} - Exp: ${item['expiryDate']}'),
                  ),
                )),
              ],
            ],
          );
        },
      ),
    );
  }
}

class WardReportScreen extends ConsumerWidget {
  const WardReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(wardReportProvider({}));

    return Scaffold(
      appBar: AppBar(title: const Text('Ward Report')),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (report) {
          final summary = report['summary'] as Map<String, dynamic>? ?? {};
          final wardOccupancy = (report['wardOccupancy'] as List? ?? []);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Colors.teal.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Average Occupancy', style: TextStyle(fontSize: 14)),
                      Text(
                        '${((summary['avgOccupancy'] ?? 0) as double).toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                      Text('Total Admissions: ${summary['totalAdmissions'] ?? 0}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Ward Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ...wardOccupancy.map((ward) {
                final occupancy = ward['total_beds'] > 0
                    ? (ward['current_admissions'] / ward['total_beds'] * 100).toStringAsFixed(1)
                    : '0';
                return Card(
                  child: ListTile(
                    title: Text(ward['ward'] ?? 'Unknown'),
                    subtitle: Text('${ward['current_admissions']}/${ward['total_beds']} beds - ${ward['total_admissions']} admissions'),
                    trailing: Text('$occupancy%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class ReportListScreen extends ConsumerWidget {
  const ReportListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(generatedReportsProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(generatedReportsProvider(null)),
          ),
        ],
      ),
      body: reportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (reports) {
          if (reports.isEmpty) {
            return const Center(child: Text('No reports generated yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getCategoryColor(report.category).withOpacity(0.2),
                    child: Icon(_getCategoryIcon(report.category), color: _getCategoryColor(report.category)),
                  ),
                  title: Text(report.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('dd MMM yyyy, HH:mm').format(report.createdAt)),
                      Text('Status: ${report.status.toUpperCase()}', style: TextStyle(fontSize: 11, color: _getStatusColor(report.status))),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to report detail
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'clinical': return Colors.blue;
      case 'financial': return Colors.green;
      case 'operational': return Colors.orange;
      case 'inventory': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'clinical': return Icons.medical_services;
      case 'financial': return Icons.attach_money;
      case 'operational': return Icons.analytics;
      case 'inventory': return Icons.inventory;
      default: return Icons.description;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed': return Colors.green;
      case 'failed': return Colors.red;
      default: return Colors.orange;
    }
  }
}
