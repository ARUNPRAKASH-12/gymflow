import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/app_shell.dart';

class MemberDashboardScreen extends ConsumerStatefulWidget {
  const MemberDashboardScreen({super.key});

  @override
  ConsumerState<MemberDashboardScreen> createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends ConsumerState<MemberDashboardScreen> {
  final _api = ApiService();
  Map<String, dynamic>? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.getMemberDashboard();
      setState(() => _data = data);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = _data?['stats'] as Map<String, dynamic>?;
    final member = _data?['member'] as Map<String, dynamic>?;
    final todayWorkout = (_data?['today_workout'] as List?) ?? [];
    final recentProgress = (_data?['recent_progress'] as List?) ?? [];

    return AppShell(
      title: 'My Dashboard',
      actions: [
        IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => context.push('/notifications')),
      ],
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [GymFlowColors.primary, GymFlowColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ROCKFORT PLANET GYM FITNESS',
                                        style: TextStyle(fontSize: 12, color: Colors.white70)),
                                    const SizedBox(height: 4),
                                    Text('Dashboard', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: (stats?['membership_status'] == 'active'
                                      ? GymFlowColors.success
                                      : GymFlowColors.error)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  (stats?['membership_status'] as String?)?.toUpperCase() ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: stats?['membership_status'] == 'active'
                                        ? GymFlowColors.success
                                        : GymFlowColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${stats?['days_remaining'] ?? 0} days remaining',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            'Expires: ${member?['end_date'] ?? 'N/A'}',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        StatCard(
                          title: 'Attendance',
                          value: '${stats?['this_month_attendance'] ?? 0} this month',
                          icon: Icons.calendar_today,
                          color: GymFlowColors.secondary,
                        ),
                        StatCard(
                          title: 'Workouts',
                          value: '${todayWorkout.length} today',
                          icon: Icons.fitness_center,
                          color: GymFlowColors.primary,
                        ),
                        StatCard(
                          title: 'Progress Logs',
                          value: '${recentProgress.length} entries',
                          icon: Icons.trending_up,
                          color: GymFlowColors.success,
                        ),
                        StatCard(
                          title: 'Trainer',
                          value: member?['trainer_profile']?['full_name'] ?? 'Not assigned',
                          icon: Icons.person,
                          color: GymFlowColors.info,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text("Today's Workout", style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 12),
                    if (todayWorkout.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text('No workout scheduled for today',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ),
                        ),
                      )
                    else
                      ...todayWorkout.take(3).map((w) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: GymFlowColors.primary.withOpacity(0.1),
                                child: Icon(Icons.fitness_center, color: GymFlowColors.primary, size: 20),
                              ),
                              title: Text(w['name'] ?? '', style: Theme.of(context).textTheme.bodyLarge),
                              trailing: Checkbox(
                                value: w['is_completed'] ?? false,
                                onChanged: (v) async {
                                  await _api.completeWorkout(w['id']);
                                  _load();
                                },
                                activeColor: GymFlowColors.primary,
                              ),
                            ),
                          )),
                    const SizedBox(height: 24),
                    Text('Recent Progress', style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 12),
                    if (recentProgress.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text('No progress logged yet', style: Theme.of(context).textTheme.bodyMedium),
                          ),
                        ),
                      )
                    else
                      ...recentProgress.take(3).map((p) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: GymFlowColors.successBg,
                                child: Icon(Icons.monitor_weight, color: GymFlowColors.success, size: 20),
                              ),
                              title: Text('Weight: ${p['weight'] ?? 'N/A'} kg',
                                  style: Theme.of(context).textTheme.bodyLarge),
                              subtitle: Text(p['date'] ?? '', style: Theme.of(context).textTheme.bodySmall),
                              trailing: p['bmi'] != null ? Text('BMI: ${p['bmi']}') : null,
                            ),
                          )),
                  ],
                ),
        ),
      ),
    );
  }
}
