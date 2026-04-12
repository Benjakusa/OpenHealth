import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/router.dart';
import 'core/config/theme.dart';
import 'features/auth/presentation/auth_controller.dart';

class OpenHealthApp extends ConsumerWidget {
  const OpenHealthApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'OpenHealth',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        return authState.when(
          data: (user) => child ?? const SizedBox(),
          loading: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Scaffold(
            body: Center(
              child: Text('Error: $error'),
            ),
          ),
        );
      },
    );
  }
}
