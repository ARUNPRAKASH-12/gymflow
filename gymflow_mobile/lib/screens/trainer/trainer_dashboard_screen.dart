import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/app_shell.dart';

class TrainerDashboardScreen extends ConsumerStatefulWidget {
  const TrainerDashboardScreen({super.key});

  @override
  ConsumerState<TrainerDashboardScreen> createState() => _TrainerDashboardScreenState();
}

class _TrainerDashboardScreenState extends ConsumerState<TrainerDashboardScreen> {
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
      final data = await _api.getTrainerDashboard();
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

    return AppShell(
      title: 'Trainer Dashboard',
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    StatCard(
                      title: 'Assigned Members',
                      value: '${stats?['assigned_members'] ?? 0}',
                      icon: Icons.people,
                      color: GymFlowColors.secondary,
                    ),
                    StatCard(
                      title: "Today's Workouts",
                      value: '${stats?['today_workouts'] ?? 0}',
                      icon: Icons.fitness_center,
                      color: GymFlowColors.primary,
                    ),
                    StatCard(
                      title: 'Total Workouts',
                      value: '${stats?['total_workouts_created'] ?? 0}',
                      icon: Icons.list_alt,
                      color: GymFlowColors.success,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text("Today's Schedule", style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 12),
                ...(_data?['today_schedule'] as List? ?? []).take(5).map((w) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: GymFlowColors.primaryBg ?? GymFlowColors.primary.withOpacity(0.1),
                          child: Icon(Icons.fitness_center, color: GymFlowColors.primary, size: 20),
                        ),
                        title: Text(w['name'] ?? '', style: Theme.of(context).textTheme.bodyLarge),
                        subtitle: Text(w['member_profile']?['full_name'] ?? 'Member',
                            style: Theme.of(context).textTheme.bodySmall),
                        trailing: Icon(
                          w['is_completed'] == true ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: w['is_completed'] == true ? GymFlowColors.success : GymFlowColors.textMuted,
                        ),
                      ),
                    )),
                const SizedBox(height: 24),
                Text('Assigned Members', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 12),
                ...(_data?['assigned_members'] as List? ?? []).take(5).map((m) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: GymFlowColors.surfaceLight,
                          backgroundImage: m['profile']?['photo_url'] != null
                              ? NetworkImage(m['profile']!['photo_url'])
                              : null,
                          child: m['profile']?['photo_url'] == null
                              ? Text(m['profile']?['full_name']?.isNotEmpty == true
                                  ? m['profile']!['full_name'][0].toUpperCase()
                                  : '?')
                              : null,
                        ),
                        title: Text(m['profile']?['full_name'] ?? 'Unknown',
                            style: Theme.of(context).textTheme.bodyLarge),
                        subtitle: Text(m['status'] ?? '', style: Theme.of(context).textTheme.bodySmall),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: m['status'] == 'active'
                                ? GymFlowColors.successBg
                                : GymFlowColors.errorBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            (m['status'] as String?)?.toUpperCase() ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: m['status'] == 'active'
                                  ? GymFlowColors.success
                                  : GymFlowColors.error,
                            ),
                          ),
                        ),
                      ),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
