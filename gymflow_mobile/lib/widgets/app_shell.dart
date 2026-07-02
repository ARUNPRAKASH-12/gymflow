import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';

class AppShell extends ConsumerWidget {
  final String title;
  final List<Widget>? actions;
  final Widget body;
  final int currentIndex;

  const AppShell({
    super.key,
    required this.title,
    this.actions,
    required this.body,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final role = authState.role;
    final selectedGymName = authState.selectedGymName;

    List<BottomNavigationBarItem> items;
    List<String> destinations;

    if (role == 'admin' || role == 'superadmin') {
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Members'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Attendance'),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
      ];
      destinations = ['/admin/dashboard', '/admin/members', '/admin/attendance', '/admin/reports'];
    } else if (role == 'trainer') {
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Members'),
        BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workouts'),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
      ];
      destinations = ['/trainer/dashboard', '/trainer/members', '/trainer/workouts/create', '/profile'];
    } else {
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workouts'),
        BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Progress'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];
      destinations = ['/member/dashboard', '/member/workouts', '/member/progress', '/profile'];
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            if (selectedGymName != null)
              Text(selectedGymName, style: const TextStyle(fontSize: 11, color: GymFlowColors.textMuted)),
          ],
        ),
        actions: [
          ...?actions,
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => context.go(destinations[i]),
        items: items,
      ),
    );
  }
}
