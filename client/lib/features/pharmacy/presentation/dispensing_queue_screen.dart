import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../../../core/config/theme.dart';
import '../data/pharmacy_provider.dart';

class DispensingQueueScreen extends ConsumerStatefulWidget {
  const DispensingQueueScreen({super.key});

  @override
  ConsumerState<DispensingQueueScreen> createState() => _DispensingQueueScreenState();
}

class _DispensingQueueScreenState extends ConsumerState<DispensingQueueScreen> with SingleTickerProviderStateMixin {
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
        title: const Text('Pharmacy Dispensing'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Pending Requests'),
            Tab(text: 'Ready for Pickup'),
            Tab(text: 'Dispensed List'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PrescriptionList(status: 'pending'),
          _PrescriptionList(status: 'ready'),
          _PrescriptionList(status: 'dispensed'),
        ],
      ),
    );
  }
}

class _PrescriptionList extends ConsumerWidget {
  final String status;
  const _PrescriptionList({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prescriptionsAsync = ref.watch(pharmacyQueueProvider(status));
    return prescriptionsAsync.when(
      data: (prescriptions) => prescriptions.isEmpty ? _buildEmptyState() : _buildList(prescriptions),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildList(List<Prescription> prescriptions) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: prescriptions.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, i) => _PrescriptionCard(prescription: prescriptions[i]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(BootstrapIcons.capsule, size: 48, color: AppTheme.textSecondaryLight.withOpacity(0.3)),
          const SizedBox(height: AppSpacing.md),
          Text('No $status prescriptions', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  final Prescription prescription;
  const _PrescriptionCard({required this.prescription});

  @override
  Widget build(BuildContext context) {
    final date = '${prescription.prescribedAt.day}/${prescription.prescribedAt.month} ${prescription.prescribedAt.hour}:${prescription.prescribedAt.minute.toString().padLeft(2, '0')}';

    return Card(
      child: InkWell(
        onTap: () => context.push('/pharmacy/dispense/${prescription.id}'),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              _buildUrgencyLine(prescription.isUrgent),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(prescription.patientName ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        if (prescription.isUrgent) ...[
                          const SizedBox(width: 8),
                          _buildBadge('URGENT', AppTheme.errorColor),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildItemsPreview(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(BootstrapIcons.person, size: 12, color: AppTheme.textSecondaryLight),
                        const SizedBox(width: 4),
                        Text(prescription.prescriberName ?? 'Unknown', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondaryLight)),
                        const SizedBox(width: 12),
                        const Icon(BootstrapIcons.clock, size: 12, color: AppTheme.textSecondaryLight),
                        const SizedBox(width: 4),
                        Text(date, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondaryLight)),
                      ],
                    ),
                  ],
                ),
              ),
              _buildStatusChip(prescription.status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemsPreview() {
    final items = prescription.items.take(2).toList();
    return Column(
      children: items.map((it) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(
          children: [
            const Icon(BootstrapIcons.dot, size: 14, color: AppTheme.primaryColor),
            Text(it.drugName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text('Qty: ${it.quantity.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryLight)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildUrgencyLine(bool urgent) {
    return Container(width: 4, height: 48, decoration: BoxDecoration(color: urgent ? AppTheme.errorColor : AppTheme.successColor, borderRadius: BorderRadius.circular(2)));
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'ready': color = AppTheme.infoColor; break;
      case 'dispensed': color = AppTheme.successColor; break;
      default: color = AppTheme.warningColor;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
