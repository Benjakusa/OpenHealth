import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../../../core/config/theme.dart';
import '../../../core/services/database_service.dart';
import '../../patients/data/patient_provider.dart';

class InvoiceScreen extends ConsumerStatefulWidget {
  const InvoiceScreen({super.key});

  @override
  ConsumerState<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends ConsumerState<InvoiceScreen> {
  String _filter = 'pending';

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(invoiceListProvider(_filter));
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(isMobile),
          Expanded(
            child: invoicesAsync.when(
              data: (invoices) => invoices.isEmpty 
                  ? _buildEmptyState() 
                  : _buildList(invoices, isMobile),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: AppTheme.surfaceLight,
      child: Column(
        children: [
          Row(
            children: [
              const Text('Invoices & Billing', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (!isMobile)
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(BootstrapIcons.plus, size: 18),
                  label: const Text('Add Charge'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'pending', label: Text('Pending'), icon: Icon(BootstrapIcons.hourglass, size: 14)),
              ButtonSegment(value: 'partially_paid', label: Text('Partial'), icon: Icon(BootstrapIcons.plus_circle, size: 14)),
              ButtonSegment(value: 'paid', label: Text('Paid'), icon: Icon(BootstrapIcons.check_circle, size: 14)),
              ButtonSegment(value: 'all', label: Text('All'), icon: Icon(BootstrapIcons.list, size: 14)),
            ],
            selected: {_filter},
            onSelectionChanged: (s) => setState(() => _filter = s.first),
            showSelectedIcon: false,
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<BillingData> invoices, bool isMobile) {
    return isMobile 
      ? ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: invoices.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, i) => _InvoiceCard(invoice: invoices[i]),
        )
      : GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.xl),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
            mainAxisExtent: 100,
          ),
          itemCount: invoices.length,
          itemBuilder: (context, i) => _InvoiceCard(invoice: invoices[i]),
        );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(BootstrapIcons.receipt, size: 48, color: AppTheme.textSecondaryLight.withOpacity(0.3)),
          const SizedBox(height: AppSpacing.md),
          const Text('No invoices found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

final invoiceListProvider = FutureProvider.family<List<BillingData>, String>((ref, filter) async {
  final database = ref.read(databaseServiceProvider);
  final results = await database.getInvoices(status: filter == 'all' ? null : filter);
  return results.map((m) => BillingData.fromMap(m)).toList();
});

class _InvoiceCard extends StatelessWidget {
  final BillingData invoice;
  const _InvoiceCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              _buildStatusIcon(invoice.status),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(invoice.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Patient: ${invoice.patientId.substring(0, 8)}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryLight)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('KES ${invoice.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 16)),
                  if (invoice.balance > 0)
                    Text('Bal: KES ${invoice.balance.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: AppTheme.errorColor, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              const Icon(BootstrapIcons.chevron_right, size: 14, color: AppTheme.textSecondaryLight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    Color color;
    IconData icon;
    switch (status) {
      case 'paid': color = AppTheme.successColor; icon = BootstrapIcons.check_circle_fill; break;
      case 'partially_paid': color = Colors.orange; icon = BootstrapIcons.plus_circle; break;
      default: color = AppTheme.primaryColor; icon = BootstrapIcons.hourglass_split;
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
