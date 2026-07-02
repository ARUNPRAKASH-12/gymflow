import 'package:flutter/material.dart';
import '../../config/theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymFlowColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [GymFlowColors.primary, GymFlowColors.secondary],
                ),
              ),
              child: const Icon(Icons.fitness_center, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text('GymFlow', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: GymFlowColors.primary),
          ],
        ),
      ),
    );
  }
}
