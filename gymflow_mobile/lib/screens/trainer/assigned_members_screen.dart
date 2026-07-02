import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';

class AssignedMembersScreen extends ConsumerStatefulWidget {
  const AssignedMembersScreen({super.key});

  @override
  ConsumerState<AssignedMembersScreen> createState() => _AssignedMembersScreenState();
}

class _AssignedMembersScreenState extends ConsumerState<AssignedMembersScreen> {
  final _api = ApiService();
  List<dynamic> _members = [];
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
      setState(() => _members = data['assigned_members'] ?? []);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assigned Members')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _members.isEmpty
                  ? const Center(child: Text('No members assigned yet'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _members.length,
                      itemBuilder: (c, i) {
                        final m = _members[i];
                        final profile = m['profile'];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: GymFlowColors.surfaceLight,
                                  backgroundImage: profile?['photo_url'] != null
                                      ? NetworkImage(profile!['photo_url'])
                                      : null,
                                  child: profile?['photo_url'] == null
                                      ? Text(profile?['full_name']?.isNotEmpty == true
                                          ? profile!['full_name'][0].toUpperCase()
                                          : '?',
                                          style: const TextStyle(fontWeight: FontWeight.bold))
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(profile?['full_name'] ?? 'Unknown',
                                          style: Theme.of(context).textTheme.bodyLarge),
                                      Text(m['status'] ?? '', style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text('Expires', style: Theme.of(context).textTheme.bodySmall),
                                    Text(m['end_date']?.toString().substring(0, 10) ?? 'N/A',
                                        style: Theme.of(context).textTheme.bodyMedium),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
