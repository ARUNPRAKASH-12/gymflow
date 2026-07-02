import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'config/routes.dart' as router_config;
import 'providers/theme_provider.dart';

class GymFlowApp extends ConsumerWidget {
  const GymFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = router_config.createRouter(ref);
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
