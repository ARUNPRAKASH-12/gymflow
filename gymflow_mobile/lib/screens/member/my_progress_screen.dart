import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';

class MyProgressScreen extends ConsumerStatefulWidget {
  const MyProgressScreen({super.key});

  @override
  ConsumerState<MyProgressScreen> createState() => _MyProgressScreenState();
}

class _MyProgressScreenState extends ConsumerState<MyProgressScreen> {
  final _api = ApiService();
  List<dynamic> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final result = await _api.getMyProgress();
      setState(() => _logs = result['logs'] ?? []);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddDialog() {
    final weightCtrl = TextEditingController();
    final chestCtrl = TextEditingController();
    final waistCtrl = TextEditingController();
    final armsCtrl = TextEditingController();
    final thighsCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Log Progress', style: Theme.of(ctx).textTheme.displaySmall),
            const SizedBox(height: 16),
            TextField(controller: weightCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Weight (kg)')),
            const SizedBox(height: 12),
            TextField(controller: chestCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Chest (cm)')),
            const SizedBox(height: 12),
            TextField(controller: waistCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Waist (cm)')),
            const SizedBox(height: 12),
            TextField(controller: armsCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Arms (cm)')),
            const SizedBox(height: 12),
            TextField(controller: thighsCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Thighs (cm)')),
            const SizedBox(height: 12),
            TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes')),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await _api.addProgress({
                      'weight': double.tryParse(weightCtrl.text),
                      'chest_cm': double.tryParse(chestCtrl.text),
                      'waist_cm': double.tryParse(waistCtrl.text),
                      'arms_cm': double.tryParse(armsCtrl.text),
                      'thighs_cm': double.tryParse(thighsCtrl.text),
                      'notes': notesCtrl.text,
                    });
                    Navigator.pop(ctx);
                    _load();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final latest = _logs.isNotEmpty ? _logs[0] : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _showAddDialog),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (latest != null) ...[
                      Text('Latest Entry', style: Theme.of(context).textTheme.headlineLarge),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _metric('Weight', '${latest['weight'] ?? '-'} kg'),
                                  _metric('BMI', '${latest['bmi'] ?? '-'}'),
                                  _metric('Body Fat', '${latest['body_fat'] ?? '-'}%'),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _metric('Chest', '${latest['chest_cm'] ?? '-'} cm'),
                                  _metric('Waist', '${latest['waist_cm'] ?? '-'} cm'),
                                  _metric('Arms', '${latest['arms_cm'] ?? '-'} cm'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Date: ${latest['date'] ?? ''}', style: Theme.of(context).textTheme.bodySmall),
                      if (latest['notes'] != null) ...[
                        const SizedBox(height: 4),
                        Text('Notes: ${latest['notes']}', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ],
                    const SizedBox(height: 24),
                    Text('History', style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 12),
                    ..._logs.map((log) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: GymFlowColors.successBg,
                              child: Icon(Icons.monitor_weight, color: GymFlowColors.success, size: 20),
                            ),
                            title: Text('Weight: ${log['weight'] ?? 'N/A'} kg • BMI: ${log['bmi'] ?? 'N/A'}',
                                style: Theme.of(context).textTheme.bodyLarge),
                            subtitle: Text(log['date'] ?? '', style: Theme.of(context).textTheme.bodySmall),
                            trailing: Text('${log['chest_cm'] ?? '-'}/${log['waist_cm'] ?? '-'}/${log['arms_cm'] ?? '-'}',
                                style: Theme.of(context).textTheme.bodySmall),
                          ),
                        )),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: GymFlowColors.primary)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: GymFlowColors.textMuted)),
      ],
    );
  }
}
