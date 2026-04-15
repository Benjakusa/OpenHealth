import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../../../core/config/theme.dart';
import '../data/lab_provider.dart';

class LabQueueScreen extends ConsumerStatefulWidget {
  const LabQueueScreen({super.key});

  @override
  ConsumerState<LabQueueScreen> createState() => _LabQueueScreenState();
}

class _LabQueueScreenState extends ConsumerState<LabQueueScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Laboratory Queue'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Orders Pending'),
            Tab(text: 'Specimen Collected'),
            Tab(text: 'Results Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LabOrderList(status: 'pending'),
          _LabOrderList(status: 'collected'),
          _LabOrderList(status: 'completed'),
        ],
      ),
    );
  }
}

class _LabOrderList extends ConsumerWidget {
  final String status;
  const _LabOrderList({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(labQueueProvider(status));
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return ordersAsync.when(
      data: (orders) => orders.isEmpty ? _buildEmptyState() : _buildList(orders, isMobile),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildList(List<LabOrder> orders, bool isMobile) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, i) => _LabOrderCard(order: orders[i]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(BootstrapIcons.droplet_half, size: 48, color: AppTheme.textSecondaryLight.withOpacity(0.3)),
          const SizedBox(height: AppSpacing.md),
          Text('No $status lab orders', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

final labQueueProvider = FutureProvider.family<List<LabOrder>, String>((ref, status) async {
  final labNotifier = ref.read(labProvider.notifier);
  return await labNotifier.getLabOrders(status: status);
});

class _LabOrderCard extends StatelessWidget {
  final LabOrder order;
  const _LabOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final date = '${order.orderedAt.day}/${order.orderedAt.month} ${order.orderedAt.hour}:${order.orderedAt.minute.toString().padLeft(2, '0')}';
    
    return Card(
      child: InkWell(
        onTap: () => context.push('/lab/order/${order.id}'),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              _buildPriorityLine(order.priority),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.patientName ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(order.testName, style: const TextStyle(fontSize: 13, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(BootstrapIcons.clock, size: 12, color: AppTheme.textSecondaryLight),
                        const SizedBox(width: 6),
                        Text(date, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondaryLight)),
                        const Spacer(),
                        if (order.specimens != null && order.specimens!.isNotEmpty)
                          _buildBadge(order.specimens!.first, AppTheme.infoColor),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Icon(BootstrapIcons.chevron_right, size: 14, color: AppTheme.textSecondaryLight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityLine(String p) {
    final color = (p == 'urgent' || p == 'stat') ? AppTheme.errorColor : (p == 'high' ? AppTheme.warningColor : AppTheme.successColor);
    return Container(width: 4, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)));
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(label.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
