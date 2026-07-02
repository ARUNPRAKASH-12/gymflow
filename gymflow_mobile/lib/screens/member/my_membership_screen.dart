import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';

class MyMembershipScreen extends ConsumerStatefulWidget {
  const MyMembershipScreen({super.key});

  @override
  ConsumerState<MyMembershipScreen> createState() => _MyMembershipScreenState();
}

class _MyMembershipScreenState extends ConsumerState<MyMembershipScreen> {
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
    final member = _data?['member'] as Map<String, dynamic>?;
    final stats = _data?['stats'] as Map<String, dynamic>?;
    final plan = member?['plan'] as Map<String, dynamic>?;
    final upcomingPayments = (_data?['upcoming_payments'] as List?) ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('My Membership')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [GymFlowColors.primary, GymFlowColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Membership Card', style: TextStyle(fontSize: 14, color: Colors.white70)),
                        const SizedBox(height: 12),
                        Text('ROCKFORT PLANET GYM FITNESS',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text('Plan: ${plan?['name'] ?? 'N/A'}', style: const TextStyle(color: Colors.white70)),
                        Text('Status: ${member?['status']?.toString().toUpperCase() ?? 'N/A'}',
                            style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Start Date', style: TextStyle(fontSize: 11, color: Colors.white60)),
                                Text(member?['start_date'] ?? 'N/A',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('End Date', style: TextStyle(fontSize: 11, color: Colors.white60)),
                                Text(member?['end_date'] ?? 'N/A',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.timer, color: Colors.white70, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              '${stats?['days_remaining'] ?? 0} days remaining',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: (stats?['days_remaining'] ?? 0) < 7
                                    ? GymFlowColors.warning
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/member/subscription/renew'),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Renew Membership'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (member?['trainer_profile'] != null) ...[
                    Text('Your Trainer', style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: GymFlowColors.primary.withOpacity(0.1),
                          child: Icon(Icons.person, color: GymFlowColors.primary),
                        ),
                        title: Text(member!['trainer_profile']?['full_name'] ?? 'Trainer',
                            style: Theme.of(context).textTheme.bodyLarge),
                      ),
                    ),
                  ],
                  if (upcomingPayments.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Payment History', style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 12),
                    ...upcomingPayments.map((p) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: GymFlowColors.warningBg,
                              child: Icon(Icons.pending, color: GymFlowColors.warning, size: 20),
                            ),
                            title: Text('₹${p['amount']}', style: Theme.of(context).textTheme.bodyLarge),
                            subtitle: Text(p['payment_date']?.toString().substring(0, 10) ?? ''),
                            trailing: Text(p['status'] ?? '', style: Theme.of(context).textTheme.bodySmall),
                          ),
                        )),
                  ],
                ],
              ),
            ),
    );
  }
}
