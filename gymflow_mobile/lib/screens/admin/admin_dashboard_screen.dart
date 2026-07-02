import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/app_shell.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final _api = ApiService();
  Map<String, dynamic>? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.getAdminDashboard();
      setState(() => _data = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = _data?['stats'] as Map<String, dynamic>?;

    return AppShell(
      title: 'Admin Dashboard',
      actions: [
        IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: () {}),
        IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
      ],
      body: RefreshIndicator(
        onRefresh: _loadData,
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
                      title: 'Total Members',
                      value: '${stats?['total_members'] ?? 0}',
                      icon: Icons.people,
                      color: GymFlowColors.secondary,
                    ),
                    StatCard(
                      title: 'Active',
                      value: '${stats?['active_members'] ?? 0}',
                      icon: Icons.verified_user,
                      color: GymFlowColors.success,
                    ),
                    StatCard(
                      title: 'Expired',
                      value: '${stats?['expired_members'] ?? 0}',
                      icon: Icons.timer_off,
                      color: GymFlowColors.error,
                    ),
                    StatCard(
                      title: "Today's Attendance",
                      value: '${stats?['today_attendance'] ?? 0}',
                      icon: Icons.calendar_today,
                      color: GymFlowColors.primary,
                    ),
                    StatCard(
                      title: 'Monthly Revenue',
                      value: '₹${stats?['monthly_revenue'] ?? 0}',
                      icon: Icons.currency_rupee,
                      color: GymFlowColors.warning,
                    ),
                    StatCard(
                      title: 'Trainers',
                      value: '${stats?['total_trainers'] ?? 0}',
                      icon: Icons.fitness_center,
                      color: GymFlowColors.info,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Revenue Overview', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 12),
                Card(
                  child: Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text('Revenue chart will render here',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Recent Payments', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 12),
                ...(_data?['recent_payments'] as List? ?? []).take(5).map((p) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: GymFlowColors.successBg,
                          child: Icon(Icons.check_circle, color: GymFlowColors.success, size: 20),
                        ),
                        title: Text('₹${p['amount']}', style: Theme.of(context).textTheme.bodyLarge),
                        subtitle: Text(p['profile']?['full_name'] ?? 'Member',
                            style: Theme.of(context).textTheme.bodySmall),
                        trailing: Text(p['plan']?['name'] ?? '', style: Theme.of(context).textTheme.bodySmall),
                      ),
                    )),
                const SizedBox(height: 24),
                Text('Expiring Soon', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 12),
                ...(_data?['expiring_memberships'] as List? ?? []).take(5).map((m) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: GymFlowColors.warningBg,
                          child: Icon(Icons.warning, color: GymFlowColors.warning, size: 20),
                        ),
                        title: Text(m['profile']?['full_name'] ?? 'Member',
                            style: Theme.of(context).textTheme.bodyLarge),
                        subtitle: Text('Expires: ${m['end_date'] ?? 'N/A'}',
                            style: Theme.of(context).textTheme.bodySmall),
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
