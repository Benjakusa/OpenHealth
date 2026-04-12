import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme.dart';
import '../data/lab_provider.dart';

final labQueueTabProvider = StateProvider<int>((ref) => 0);

class LabQueueScreen extends ConsumerWidget {
  const LabQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Collected'),
              Tab(text: 'Completed'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _LabOrderList(status: 'pending'),
                _LabOrderList(status: 'collected'),
                _LabOrderList(status: 'completed'),
              ],
            ),
          ),
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

    return ordersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.science_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No ${status} orders',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(labQueueProvider(status));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _LabOrderCard(
                order: order,
                onProcess: () {
                  context.push('/lab/order/${order.id}');
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(labQueueProvider(status)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

final labQueueProvider = FutureProvider.family<List<LabOrder>, String>((ref, status) async {
  final labNotifier = ref.read(labProvider.notifier);
  final orders = await labNotifier.getLabOrders(status: status);
  return orders;
});

class _LabOrderCard extends StatelessWidget {
  final LabOrder order;
  final VoidCallback? onProcess;

  const _LabOrderCard({required this.order, this.onProcess});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onProcess,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildPriorityIndicator(order.priority),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          order.patientName ?? 'Unknown Patient',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          order.orderNumber,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.testName,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(order.orderedAt),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                        if (order.specimens != null && order.specimens!.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Chip(
                            label: Text(order.specimens!.first, style: const TextStyle(fontSize: 11)),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              _buildStatusChip(order.status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = AppTheme.warningColor;
        label = 'Pending';
        break;
      case 'collected':
        color = AppTheme.infoColor;
        label = 'Collected';
        break;
      case 'processing':
        color = AppTheme.primaryColor;
        label = 'Processing';
        break;
      case 'completed':
      case 'resulted':
        color = AppTheme.successColor;
        label = 'Completed';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }

  Widget _buildPriorityIndicator(String priority) {
    Color color;
    if (priority == 'urgent' || priority == 'stat') {
      color = AppTheme.errorColor;
    } else if (priority == 'high') {
      color = AppTheme.warningColor;
    } else {
      color = AppTheme.successColor;
    }

    return Container(
      width: 4,
      height: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
