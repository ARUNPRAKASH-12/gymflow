import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';
import '../../utils/extensions.dart';

class WorkoutCreateScreen extends ConsumerStatefulWidget {
  const WorkoutCreateScreen({super.key});

  @override
  ConsumerState<WorkoutCreateScreen> createState() => _WorkoutCreateScreenState();
}

class _WorkoutCreateScreenState extends ConsumerState<WorkoutCreateScreen> {
  final _api = ApiService();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedMemberId;
  String? _selectedDay;
  List<dynamic> _members = [];
  List<dynamic> _exercises = [];
  List<Map<String, dynamic>> _selectedExercises = [];
  bool _isLoading = true;

  final _days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final dashboard = await _api.getTrainerDashboard();
      final exercises = await _api.getExercises();
      setState(() {
        _members = dashboard['assigned_members'] ?? [];
        _exercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty || _selectedMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and member are required')),
      );
      return;
    }

    try {
      await _api.createWorkout({
        'member_id': _selectedMemberId,
        'name': _nameController.text,
        'description': _descController.text,
        'day_of_week': _selectedDay,
        'exercises': _selectedExercises.map((e) => {
          'exercise_id': e['id'],
          'sets': e['sets'] ?? 3,
          'reps': e['reps'] ?? 12,
          'weight': e['weight'],
        }).toList(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Workout created!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Workout'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Workout Name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Description (optional)'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Assign to Member'),
                    items: _members.map<DropdownMenuItem<String>>((m) {
                      final name = m['profile']?['full_name'] ?? m['user']?['email'] ?? 'Unknown';
                      return DropdownMenuItem<String>(value: m['user']?['id'] as String?, child: Text(name));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedMemberId = v),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Day of Week'),
                    items: _days.map((d) => DropdownMenuItem(value: d, child: Text(d.capitalize()))).toList(),
                    onChanged: (v) => setState(() => _selectedDay = v),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Exercises', style: Theme.of(context).textTheme.headlineLarge),
                      TextButton.icon(
                        onPressed: () => _showAddExerciseDialog(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_selectedExercises.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text('No exercises added yet', style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ),
                    )
                  else
                    ..._selectedExercises.asMap().entries.map((entry) {
                      final i = entry.key;
                      final e = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(e['name'] ?? '', style: Theme.of(context).textTheme.bodyLarge),
                                    Text('${e['sets']} sets x ${e['reps']} reps${e['weight'] != null ? ' @ ${e['weight']}kg' : ''}',
                                        style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: GymFlowColors.error),
                                onPressed: () => setState(() => _selectedExercises.removeAt(i)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }

  void _showAddExerciseDialog() {
    final selected = <String>[];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Exercises'),
        content: SizedBox(
          width: double.maxFinite,
          child: _exercises.isEmpty
              ? const Text('No exercises in library')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _exercises.length,
                  itemBuilder: (c, i) {
                    final e = _exercises[i];
                    return CheckboxListTile(
                      title: Text(e['name'] ?? ''),
                      subtitle: Text(e['category'] ?? ''),
                      value: selected.contains(e['id']),
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            selected.add(e['id']);
                          } else {
                            selected.remove(e['id']);
                          }
                        });
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              for (final id in selected) {
                final ex = _exercises.firstWhere((e) => e['id'] == id);
                if (!_selectedExercises.any((s) => s['id'] == id)) {
                  _selectedExercises.add({
                    'id': ex['id'],
                    'name': ex['name'],
                    'sets': 3,
                    'reps': 12,
                    'weight': null,
                  });
                }
              }
              setState(() {});
              Navigator.pop(ctx);
            },
            child: Text('Add (${selected.length})'),
          ),
        ],
      ),
    );
  }
}


