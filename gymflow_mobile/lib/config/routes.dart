import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/gym_selection_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/member_list_screen.dart';
import '../screens/admin/member_detail_screen.dart';
import '../screens/admin/trainer_list_screen.dart';
import '../screens/admin/plan_list_screen.dart';
import '../screens/admin/attendance_log_screen.dart';
import '../screens/admin/payment_history_screen.dart';
import '../screens/admin/report_screen.dart';
import '../screens/trainer/trainer_dashboard_screen.dart';
import '../screens/trainer/assigned_members_screen.dart';
import '../screens/trainer/workout_create_screen.dart';
import '../screens/trainer/diet_create_screen.dart';
import '../screens/member/member_dashboard_screen.dart';
import '../screens/member/my_attendance_screen.dart';
import '../screens/member/my_workouts_screen.dart';
import '../screens/member/my_diet_screen.dart';
import '../screens/member/my_progress_screen.dart';
import '../screens/member/my_membership_screen.dart';
import '../screens/member/subscription_renew_screen.dart';
import '../screens/shared/profile_screen.dart';
import '../screens/shared/notifications_screen.dart';
import '../screens/shared/qr_scanner_screen.dart';
import '../screens/shared/splash_screen.dart';

GoRouter createRouter(Ref ref) {
  ref.listen(authProvider, (prev, next) {
    _authRefreshNotifier.value++;
  });

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _authRefreshNotifier,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/gym-selection',
        builder: (context, state) => const GymSelectionScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/members',
        builder: (context, state) => const MemberListScreen(),
      ),
      GoRoute(
        path: '/admin/members/:id',
        builder: (context, state) => MemberDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/admin/trainers',
        builder: (context, state) => const TrainerListScreen(),
      ),
      GoRoute(
        path: '/admin/plans',
        builder: (context, state) => const PlanListScreen(),
      ),
      GoRoute(
        path: '/admin/attendance',
        builder: (context, state) => const AttendanceLogScreen(),
      ),
      GoRoute(
        path: '/admin/payments',
        builder: (context, state) => const PaymentHistoryScreen(),
      ),
      GoRoute(
        path: '/admin/reports',
        builder: (context, state) => const ReportScreen(),
      ),
      GoRoute(
        path: '/trainer/dashboard',
        builder: (context, state) => const TrainerDashboardScreen(),
      ),
      GoRoute(
        path: '/trainer/members',
        builder: (context, state) => const AssignedMembersScreen(),
      ),
      GoRoute(
        path: '/trainer/workouts/create',
        builder: (context, state) => const WorkoutCreateScreen(),
      ),
      GoRoute(
        path: '/trainer/diets/create',
        builder: (context, state) => const DietCreateScreen(),
      ),
      GoRoute(
        path: '/member/dashboard',
        builder: (context, state) => const MemberDashboardScreen(),
      ),
      GoRoute(
        path: '/member/attendance',
        builder: (context, state) => const MyAttendanceScreen(),
      ),
      GoRoute(
        path: '/member/workouts',
        builder: (context, state) => const MyWorkoutsScreen(),
      ),
      GoRoute(
        path: '/member/diet',
        builder: (context, state) => const MyDietScreen(),
      ),
      GoRoute(
        path: '/member/progress',
        builder: (context, state) => const MyProgressScreen(),
      ),
      GoRoute(
        path: '/member/membership',
        builder: (context, state) => const MyMembershipScreen(),
      ),
      GoRoute(
        path: '/member/subscription/renew',
        builder: (context, state) => const SubscriptionRenewScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/qr-scanner',
        builder: (context, state) => const QRScannerScreen(),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoading = authState.isLoading;
      final isLoggedIn = authState.isAuthenticated;
      final location = state.matchedLocation;
      final isOnSplash = location == '/splash';
      final isOnAuthPage = location.startsWith('/login') ||
          location.startsWith('/register') ||
          location.startsWith('/forgot-password');

      if (isLoading) {
        if (!isOnSplash) return '/splash';
        return null;
      }

      if (!isLoggedIn && !isOnAuthPage) return '/login';
      if (isLoggedIn && isOnAuthPage) return _getDefaultRoute(authState.role);
      if (isLoggedIn && isOnSplash) return _getDefaultRoute(authState.role);

      return null;
    },
  );
}

final ValueNotifier<int> _authRefreshNotifier = ValueNotifier(0);

String _getDefaultRoute(String? role) {
  switch (role) {
    case 'admin':
    case 'superadmin':
      return '/admin/dashboard';
    case 'trainer':
      return '/trainer/dashboard';
    case 'member':
      return '/member/dashboard';
    default:
      return '/gym-selection';
  }
}
