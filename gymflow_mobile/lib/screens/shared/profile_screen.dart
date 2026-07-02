import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final profile = authState.profile;
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: GymFlowColors.error),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 48,
              backgroundColor: GymFlowColors.surfaceLight,
              backgroundImage: profile?.photoUrl != null ? NetworkImage(profile!.photoUrl!) : null,
              child: profile?.photoUrl == null
                  ? Text(
                      profile?.fullName.isNotEmpty == true ? profile!.fullName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(profile?.fullName ?? 'User', style: Theme.of(context).textTheme.displaySmall),
            Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: GymFlowColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user?.role.toUpperCase() ?? '',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GymFlowColors.primary),
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Personal Information', style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 16),
                    _field(profile?.fullName ?? '', Icons.person, 'Full Name'),
                    _field(user?.email ?? '', Icons.email, 'Email'),
                    _field(user?.phone ?? 'Not set', Icons.phone, 'Phone'),
                    _field(profile?.gender ?? 'Not set', Icons.wc, 'Gender'),
                    _field(profile?.bloodGroup ?? 'Not set', Icons.bloodtype, 'Blood Group'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Emergency Contact', style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 16),
                    _field(profile?.emergencyContactName ?? 'Not set', Icons.person, 'Contact Name'),
                    _field(profile?.emergencyContactPhone ?? 'Not set', Icons.phone, 'Contact Phone'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Medical Info', style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 16),
                    _field(profile?.medicalConditions ?? 'None', Icons.medical_information, 'Conditions'),
                    _field(profile?.allergies ?? 'None', Icons.warning, 'Allergies'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Appearance', style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isDark ? Icons.dark_mode : Icons.light_mode,
                              size: 18,
                              color: GymFlowColors.textMuted,
                            ),
                            const SizedBox(width: 12),
                            Text(isDark ? 'Dark Mode' : 'Light Mode'),
                          ],
                        ),
                        Switch(
                          value: isDark,
                          activeColor: GymFlowColors.primary,
                          onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  context.go('/login');
                },
                icon: const Icon(Icons.logout, color: GymFlowColors.error),
                label: const Text('Logout', style: TextStyle(color: GymFlowColors.error)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: GymFlowColors.error)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _field(String value, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: GymFlowColors.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: GymFlowColors.textMuted)),
                Text(value, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
