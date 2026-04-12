import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/config/environment.dart';
import 'core/services/database_service.dart';
import 'core/services/sync_service.dart';

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
