import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/config/environment.dart';
import 'core/services/database_service.dart';
import 'core/services/sync_service.dart';
import 'features/patients/data/patient_provider.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  throw UnimplementedError('SyncService must be overridden');
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await Environment.init();

  final database = createDatabaseService();
  await database.init();

  final syncService = SyncService(database);

  runApp(
    ProviderScope(
      overrides: [
        databaseServiceProvider.overrideWithValue(database),
        syncServiceProvider.overrideWithValue(syncService),
      ],
      child: const OpenHealthApp(),
    ),
  );
}
