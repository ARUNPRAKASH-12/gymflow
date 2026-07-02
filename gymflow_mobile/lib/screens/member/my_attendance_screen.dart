import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';

class MyAttendanceScreen extends ConsumerStatefulWidget {
  const MyAttendanceScreen({super.key});

  @override
  ConsumerState<MyAttendanceScreen> createState() => _MyAttendanceScreenState();
}

class _MyAttendanceScreenState extends ConsumerState<MyAttendanceScreen> {
  final _api = ApiService();
  List<dynamic> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final result = await _api.getMyAttendance();
      setState(() => _records = result is List ? result : result['records'] ?? []);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkIn() async {
    try {
      final result = await _api.checkIn('');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Checked in successfully!'), backgroundColor: GymFlowColors.success),
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final thisMonth = _records.where((r) {
      final date = r['date'] ?? '';
      return date.startsWith(DateTime.now().toIso8601String().substring(0, 7));
    }).length;

    return Scaffold(
      appBar: AppBar(title: const Text('My Attendance')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: GymFlowColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: GymFlowColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('This Month', style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 4),
                            Text('$thisMonth days',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: GymFlowColors.primary,
                                )),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _checkIn,
                        icon: const Icon(Icons.login, size: 18),
                        label: const Text('Check In'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: _records.isEmpty
                        ? const Center(child: Text('No attendance records'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _records.length,
                            itemBuilder: (c, i) {
                              final r = _records[i];
                              final checkIn = r['check_in']?.toString() ?? '';
                              final checkOut = r['check_out']?.toString();
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: checkOut != null
                                        ? GymFlowColors.successBg
                                        : GymFlowColors.warningBg,
                                    child: Icon(
                                      checkOut != null ? Icons.check_circle : Icons.access_time,
                                      color: checkOut != null
                                          ? GymFlowColors.success
                                          : GymFlowColors.warning,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(r['date'] ?? '', style: Theme.of(context).textTheme.bodyLarge),
                                  subtitle: Text(
                                    'In: ${checkIn.length > 16 ? checkIn.substring(11, 16) : checkIn}'
                                    '${checkOut != null ? ' • Out: ${checkOut.substring(11, 16)}' : ' • In progress'}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  trailing: Text(
                                    r['method']?.toString().toUpperCase() ?? '',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: GymFlowColors.textMuted,
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
}
