import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../../../core/config/theme.dart';
import '../data/ward_provider.dart';
import 'ward_detail_screen.dart';

class WardListScreen extends ConsumerWidget {
  const WardListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wardsAsync = ref.watch(wardsProvider);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Facility Wards'),
        actions: [
          IconButton(icon: const Icon(BootstrapIcons.arrow_clockwise, size: 18), onPressed: () => ref.invalidate(wardsProvider)),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: wardsAsync.when(
        data: (wards) => wards.isEmpty ? _buildEmptyState() : _buildGrid(wards, width),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildGrid(List<Ward> wards, double width) {
    final cols = width > 1200 ? 3 : (width > 800 ? 2 : 1);
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.xl),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: AppSpacing.lg,
        mainAxisSpacing: AppSpacing.lg,
        mainAxisExtent: 180,
      ),
      itemCount: wards.length,
      itemBuilder: (context, i) => _WardCard(ward: wards[i]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(BootstrapIcons.door_open, size: 48, color: AppTheme.textSecondaryLight.withOpacity(0.3)),
          const SizedBox(height: AppSpacing.md),
          const Text('No wards configured', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _WardCard extends StatelessWidget {
  final Ward ward;
  const _WardCard({required this.ward});

  @override
  Widget build(BuildContext context) {
    final occ = ward.bedCount > 0 ? ((ward.bedCount - ward.availableBeds) / ward.bedCount * 100).round() : 0;
    final color = _getWardColor(ward.type);

    return Card(
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WardDetailScreen(wardId: ward.id))),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildCodeBadge(ward.code, color),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Text(ward.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)),
                  _StatusIndicator(status: ward.status),
                ],
              ),
              const Spacer(),
              _buildOccupancyBar(occ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _InfoIcon(BootstrapIcons.hospital, '${ward.availableBeds}/${ward.bedCount}'),
                  const SizedBox(width: AppSpacing.lg),
                  _InfoIcon(BootstrapIcons.geo_alt, ward.floor != null ? 'F${ward.floor}' : 'Ground'),
                  const Spacer(),
                  const Icon(BootstrapIcons.chevron_right, size: 14, color: AppTheme.textSecondaryLight),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeBadge(String code, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(code, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildOccupancyBar(int percent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Occupancy', style: TextStyle(fontSize: 10, color: AppTheme.textSecondaryLight)),
            Text('$percent%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: percent > 85 ? AppTheme.errorColor : AppTheme.primaryColor)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(value: percent / 100, minHeight: 4, backgroundColor: AppTheme.borderLight, color: percent > 85 ? AppTheme.errorColor : AppTheme.primaryColor),
        ),
      ],
    );
  }

  Color _getWardColor(String type) {
    switch (type) {
      case 'icu': return Colors.red;
      case 'maternity': return Colors.pink;
      case 'pediatric': return Colors.blue;
      case 'emergency': return Colors.red;
      default: return AppTheme.primaryColor;
    }
  }
}

class _InfoIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoIcon(this.icon, this.label);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppTheme.textSecondaryLight),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondaryLight)),
      ],
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final String status;
  const _StatusIndicator({required this.status});
  @override
  Widget build(BuildContext context) {
    final active = status == 'active';
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: active ? AppTheme.successColor : AppTheme.textSecondaryLight.withOpacity(0.4), shape: BoxShape.circle),
    );
  }
}
