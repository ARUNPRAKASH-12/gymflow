import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../models/user.dart';

class GymSelectionScreen extends ConsumerWidget {
  const GymSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [GymFlowColors.primary, GymFlowColors.secondary]),
              ),
              child: const Icon(Icons.fitness_center, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text('Welcome to GymFlow', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 8),
            Text('Select your gym to continue', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 40),
            Expanded(
              child: authState.gyms.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.business_outlined, size: 64, color: GymFlowColors.textMuted),
                          const SizedBox(height: 16),
                          Text('No gyms found', style: Theme.of(context).textTheme.bodyLarge),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: const Text('Go back'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: authState.gyms.length,
                      itemBuilder: (context, index) {
                        final gym = authState.gyms[index];
                        return _GymCard(gym: gym, onTap: () async {
                          await ref.read(authProvider.notifier).selectGym(gym.id, gymName: gym.name);
                        });
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GymCard extends StatelessWidget {
  final Gym gym;
  final VoidCallback onTap;
  const _GymCard({required this.gym, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: GymFlowColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: gym.logoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(gym.logoUrl!, fit: BoxFit.cover),
                      )
                    : Icon(Icons.fitness_center, color: GymFlowColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(gym.name, style: Theme.of(context).textTheme.titleLarge),
                    if (gym.city != null) ...[
                      const SizedBox(height: 4),
                      Text('${gym.city}${gym.state != null ? ', ${gym.state}' : ''}',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: GymFlowColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
