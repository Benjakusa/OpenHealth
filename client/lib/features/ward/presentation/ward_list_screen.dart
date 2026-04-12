import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ward_provider.dart';
import 'ward_detail_screen.dart';

class WardListScreen extends ConsumerWidget {
  const WardListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wardsAsync = ref.watch(wardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(wardsProvider),
          ),
        ],
      ),
      body: wardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(wardsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (wards) {
          if (wards.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.meeting_room_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No wards found'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(wardsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: wards.length,
              itemBuilder: (context, index) {
                final ward = wards[index];
                return _WardCard(ward: ward);
              },
            ),
          );
        },
      ),
    );
  }
}

class _WardCard extends StatelessWidget {
  final Ward ward;

  const _WardCard({required this.ward});

  @override
  Widget build(BuildContext context) {
    final occupancy = ward.bedCount > 0 
        ? ((ward.bedCount - ward.availableBeds) / ward.bedCount * 100).round()
        : 0;

    Color occupancyColor;
    if (occupancy >= 90) {
      occupancyColor = Colors.red;
    } else if (occupancy >= 70) {
      occupancyColor = Colors.orange;
    } else {
      occupancyColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WardDetailScreen(wardId: ward.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getWardTypeColor(ward.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      ward.code,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getWardTypeColor(ward.type),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ward.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ward.status == 'active' ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      ward.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: ward.status == 'active' ? Colors.green : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.bed,
                    label: '${ward.availableBeds}/${ward.bedCount}',
                    color: occupancyColor,
                  ),
                  const SizedBox(width: 12),
                  _InfoChip(
                    icon: Icons.trending_up,
                    label: '$occupancy%',
                    color: occupancyColor,
                  ),
                  const Spacer(),
                  _WardTypeBadge(type: ward.type),
                ],
              ),
              if (ward.floor != null || ward.building != null) ...[
                const SizedBox(height: 8),
                Text(
                  [ward.building, ward.floor].where((e) => e != null).join(', '),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getWardTypeColor(String type) {
    switch (type) {
      case 'icu':
        return Colors.red;
      case 'maternity':
        return Colors.pink;
      case 'pediatric':
        return Colors.blue;
      case 'surgical':
        return Colors.orange;
      case 'emergency':
        return Colors.red;
      case 'isolation':
        return Colors.purple;
      case 'private':
        return Colors.indigo;
      default:
        return Colors.teal;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _WardTypeBadge extends StatelessWidget {
  final String type;

  const _WardTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}
