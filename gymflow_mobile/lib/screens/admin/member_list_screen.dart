import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';
import '../../models/member.dart';

class MemberListScreen extends ConsumerStatefulWidget {
  const MemberListScreen({super.key});

  @override
  ConsumerState<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends ConsumerState<MemberListScreen> {
  final _api = ApiService();
  List<Member> _members = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Member> get _filteredMembers {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) return _members;
    return _members.where((m) {
      final name = m.fullName?.toLowerCase() ?? '';
      final email = m.email?.toLowerCase() ?? '';
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.getMembers();
      setState(() => _members = data.map((m) => Member.fromJson(m)).toList());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return GymFlowColors.success;
      case 'expired':
        return GymFlowColors.error;
      case 'pending':
        return GymFlowColors.warning;
      default:
        return GymFlowColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMemberDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search members...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); _loadMembers(); })
                    : null,
              ),
              onChanged: (v) => setState(() {}),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadMembers,
                    child: ListView.builder(
                      itemCount: _filteredMembers.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final member = _filteredMembers[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () => context.push('/admin/members/${member.id}'),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: GymFlowColors.surfaceLight,
                                    backgroundImage: member.profile?.photoUrl != null
                                        ? NetworkImage(member.profile!.photoUrl!)
                                        : null,
                                    child: member.profile?.photoUrl == null
                                        ? Text(member.profile?.fullName.isNotEmpty == true
                                            ? member.profile!.fullName[0].toUpperCase()
                                            : '?',
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(member.profile?.fullName ?? 'Unknown',
                                            style: Theme.of(context).textTheme.bodyLarge),
                                        const SizedBox(height: 4),
                                        Text(member.user?.email ?? '',
                                            style: Theme.of(context).textTheme.bodySmall),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _statusColor(member.status).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(member.status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: _statusColor(member.status),
                                        )),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.chevron_right, color: GymFlowColors.textMuted),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Member', style: Theme.of(ctx).textTheme.displaySmall),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 12),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await _api.createMember({
                      'email': emailCtrl.text,
                      'full_name': nameCtrl.text,
                      'phone': phoneCtrl.text,
                    });
                    Navigator.pop(ctx);
                    _loadMembers();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                child: const Text('Create Member'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
