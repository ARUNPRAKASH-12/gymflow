import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';

class TrainerListScreen extends ConsumerStatefulWidget {
  const TrainerListScreen({super.key});

  @override
  ConsumerState<TrainerListScreen> createState() => _TrainerListScreenState();
}

class _TrainerListScreenState extends ConsumerState<TrainerListScreen> {
  final _api = ApiService();
  List<dynamic> _trainers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.getTrainers();
      setState(() => _trainers = data);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainers'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddDialog()),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _trainers.length,
                itemBuilder: (c, i) {
                  final t = _trainers[i];
                  final profile = t['profile'];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: GymFlowColors.surfaceLight,
                        backgroundImage: profile?['photo_url'] != null ? NetworkImage(profile!['photo_url']) : null,
                        child: profile?['photo_url'] == null
                            ? Text(profile?['full_name']?.isNotEmpty == true ? profile!['full_name'][0].toUpperCase() : 'T',
                                style: const TextStyle(fontWeight: FontWeight.bold))
                            : null,
                      ),
                      title: Text(profile?['full_name'] ?? 'Unknown', style: Theme.of(context).textTheme.bodyLarge),
                      subtitle: Text(t['specialization'] ?? 'No specialization', style: Theme.of(context).textTheme.bodySmall),
                      trailing: Icon(t['is_active'] == true ? Icons.check_circle : Icons.cancel,
                          color: t['is_active'] == true ? GymFlowColors.success : GymFlowColors.error),
                    ),
                  );
                },
              ),
            ),
    );
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final specCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add Trainer', style: Theme.of(ctx).textTheme.displaySmall),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 12),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: specCtrl, decoration: const InputDecoration(labelText: 'Specialization')),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await _api.createTrainer({
                      'email': emailCtrl.text,
                      'full_name': nameCtrl.text,
                      'specialization': specCtrl.text,
                    });
                    Navigator.pop(ctx);
                    _load();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                child: const Text('Create Trainer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
