import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'config/theme.dart';
import 'config/routes.dart' as router_config;
import 'providers/theme_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return router_config.createRouter(ref);
});

class GymFlowApp extends ConsumerWidget {
  const GymFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'GymFlow',
      debugShowCheckedModeBanner: false,
      theme: GymFlowTheme.lightTheme,
      darkTheme: GymFlowTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
