import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';

final pendingUsersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final notifier = ref.read(authStateProvider.notifier);
  return await notifier.getPendingUsers();
});

final clinicsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final notifier = ref.read(authStateProvider.notifier);
  return await notifier.getClinics();
});

final tenantsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final notifier = ref.read(authStateProvider.notifier);
  return await notifier.getTenants();
});
