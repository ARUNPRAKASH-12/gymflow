import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../models/member.dart';
import '../../config/theme.dart';

class MemberDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const MemberDetailScreen({super.key, required this.id});

  @override
  ConsumerState<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends ConsumerState<MemberDetailScreen>
    with SingleTickerProviderStateMixin {
  final _api = ApiService();
  Member? _member;
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMember();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMember() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.getMember(widget.id);
      setState(() => _member = Member.fromJson(data));
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
    if (_isLoading) {
      return Scaffold(appBar: AppBar(title: const Text('Member Details')),
          body: const Center(child: CircularProgressIndicator()));
    }

    final member = _member!;
    final profile = member.profile;

    return Scaffold(
      appBar: AppBar(title: Text(profile?.fullName ?? 'Member Details')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: GymFlowColors.surfaceLight,
                  backgroundImage: profile?.photoUrl != null ? NetworkImage(profile!.photoUrl!) : null,
                  child: profile?.photoUrl == null
                      ? Text(profile?.fullName.isNotEmpty == true ? profile!.fullName[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold))
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile?.fullName ?? 'Unknown', style: Theme.of(context).textTheme.displaySmall),
                      Text(member.user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: member.isActive ? GymFlowColors.successBg : GymFlowColors.errorBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(member.status.toUpperCase(),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                                color: member.isActive ? GymFlowColors.success : GymFlowColors.error)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Info'),
              Tab(text: 'Attendance'),
              Tab(text: 'Payments'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _InfoTab(member: member),
                _AttendanceTab(userId: member.userId),
                _PaymentsTab(userId: member.userId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  final Member member;
  const _InfoTab({required this.member});

  @override
  Widget build(BuildContext context) {
    final profile = member.profile;
    final plan = member.plan;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Membership', style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 12),
                  _infoRow('Plan', plan?.name ?? 'No Plan'),
                  _infoRow('Start Date', member.startDate ?? 'N/A'),
                  _infoRow('End Date', member.endDate ?? 'N/A'),
                  _infoRow('Status', member.status.toUpperCase()),
                  if (member.isExpiringSoon)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: GymFlowColors.warningBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: GymFlowColors.warning, size: 20),
                          const SizedBox(width: 8),
                          Text('Membership expiring soon!',
                              style: TextStyle(color: GymFlowColors.warning)),
                        ],
                      ),
                    ),
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
                  Text('Personal Info', style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 12),
                  _infoRow('Phone', member.user?.phone ?? 'N/A'),
                  _infoRow('Email', member.user?.email ?? 'N/A'),
                  _infoRow('Address', profile?.address ?? 'N/A'),
                  _infoRow('Blood Group', profile?.bloodGroup ?? 'N/A'),
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
                  const SizedBox(height: 12),
                  _infoRow('Name', profile?.emergencyContactName ?? 'N/A'),
                  _infoRow('Phone', profile?.emergencyContactPhone ?? 'N/A'),
                ],
              ),
            ),
          ),
          if (profile?.medicalConditions != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Medical Info', style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 8),
                    Text(profile!.medicalConditions!, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: GymFlowColors.textMuted)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _AttendanceTab extends ConsumerStatefulWidget {
  final String userId;
  const _AttendanceTab({required this.userId});

  @override
  ConsumerState<_AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends ConsumerState<_AttendanceTab> {
  final _api = ApiService();
  List<dynamic> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _api.getMyAttendance();
      setState(() => _records = data);
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_records.isEmpty) return const Center(child: Text('No attendance records'));
    return ListView.builder(
      itemCount: _records.length,
      itemBuilder: (c, i) {
        final r = _records[i];
        return ListTile(
          leading: Icon(Icons.calendar_today, color: GymFlowColors.primary),
          title: Text(r['date'] ?? ''),
          subtitle: Text('${r['check_in']?.toString().substring(11, 19) ?? ""} - ${r['check_out']?.toString().substring(11, 19) ?? "..."}'),
          trailing: Text(r['method'] ?? ''),
        );
      },
    );
  }
}

class _PaymentsTab extends ConsumerStatefulWidget {
  final String userId;
  const _PaymentsTab({required this.userId});

  @override
  ConsumerState<_PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends ConsumerState<_PaymentsTab> {
  final _api = ApiService();
  List<dynamic> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _api.getMyPayments();
      setState(() => _payments = data);
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_payments.isEmpty) return const Center(child: Text('No payment records'));
    return ListView.builder(
      itemCount: _payments.length,
      itemBuilder: (c, i) {
        final p = _payments[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: GymFlowColors.successBg,
            child: Icon(Icons.check_circle, color: GymFlowColors.success, size: 20),
          ),
          title: Text('₹${p['amount']}'),
          subtitle: Text(p['payment_date']?.toString().substring(0, 10) ?? ''),
          trailing: Text(p['method'] ?? '', style: Theme.of(context).textTheme.bodySmall),
        );
      },
    );
  }
}
