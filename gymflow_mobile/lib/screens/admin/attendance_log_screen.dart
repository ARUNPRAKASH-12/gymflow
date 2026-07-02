import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';

class AttendanceLogScreen extends ConsumerStatefulWidget {
  const AttendanceLogScreen({super.key});

  @override
  ConsumerState<AttendanceLogScreen> createState() => _AttendanceLogScreenState();
}

class _AttendanceLogScreenState extends ConsumerState<AttendanceLogScreen> {
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
      final data = await _api.getTodayAttendance();
      setState(() => _data = data);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Today's Attendance")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _statBox('Total', '${_data?['total'] ?? 0}', GymFlowColors.info),
                      const SizedBox(width: 12),
                      _statBox('Checked In', '${_data?['checked_in'] ?? 0}', GymFlowColors.success),
                      const SizedBox(width: 12),
                      _statBox('Checked Out', '${_data?['checked_out'] ?? 0}', GymFlowColors.warning),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: (_data?['records'] as List?)?.length ?? 0,
                      itemBuilder: (c, i) {
                        final r = (_data!['records'] as List)[i];
                        final profile = r['profile'];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: GymFlowColors.surfaceLight,
                              backgroundImage: profile?['photo_url'] != null ? NetworkImage(profile!['photo_url']) : null,
                              child: profile?['photo_url'] == null
                                  ? Text(profile?['full_name']?.isNotEmpty == true ? profile!['full_name'][0].toUpperCase() : '?')
                                  : null,
                            ),
                            title: Text(profile?['full_name'] ?? 'Unknown'),
                            subtitle: Text('In: ${r['check_in']?.toString().substring(11, 19) ?? ""}'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: r['check_out'] != null ? GymFlowColors.successBg : GymFlowColors.warningBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(r['check_out'] != null ? 'Out' : 'In',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: r['check_out'] != null ? GymFlowColors.success : GymFlowColors.warning,
                                  )),
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

  Widget _statBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
