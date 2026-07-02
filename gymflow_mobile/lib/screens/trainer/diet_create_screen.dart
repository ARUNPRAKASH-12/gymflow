import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';

class DietCreateScreen extends ConsumerStatefulWidget {
  const DietCreateScreen({super.key});

  @override
  ConsumerState<DietCreateScreen> createState() => _DietCreateScreenState();
}

class _DietCreateScreenState extends ConsumerState<DietCreateScreen> {
  final _api = ApiService();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  String? _selectedMemberId;
  String _dietType = 'muscle_gain';
  List<Map<String, dynamic>> _meals = [];
  List<dynamic> _members = [];
  bool _isLoading = true;

  final _mealTypes = ['breakfast', 'mid_morning', 'lunch', 'evening_snack', 'dinner', 'post_workout'];
  final _dietTypes = ['weight_loss', 'muscle_gain', 'maintenance'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final dashboard = await _api.getTrainerDashboard();
      setState(() {
        _members = dashboard['assigned_members'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addMeal() {
    setState(() => _meals.add({
          'meal': 'breakfast',
          'time': '08:00',
          'foods': <String>[],
          'calories': 0,
        }));
  }

  void _removeMeal(int index) {
    setState(() => _meals.removeAt(index));
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty || _selectedMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and member are required')),
      );
      return;
    }

    try {
      await _api.createDiet({
        'member_id': _selectedMemberId,
        'name': _nameController.text,
        'type': _dietType,
        'target_calories': int.tryParse(_caloriesController.text),
        'meals': _meals,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Diet plan created!')));
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
        title: const Text('Create Diet Plan'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
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
                    decoration: const InputDecoration(labelText: 'Diet Plan Name'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Assign to Member'),
                    items: _members.map((m) {
                      final name = m['profile']?['full_name'] ?? 'Unknown';
                      return DropdownMenuItem(value: m['user_id'], child: Text(name));
                    }).toList(),
                    onChanged: (v) => _selectedMemberId = v,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Diet Type'),
                    value: _dietType,
                    items: _dietTypes.map((d) => DropdownMenuItem(
                      value: d,
                      child: Text(d.replaceAll('_', ' ').capitalize()),
                    )).toList(),
                    onChanged: (v) => setState(() => _dietType = v!),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Target Calories (optional)'),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Meals', style: Theme.of(context).textTheme.headlineLarge),
                      TextButton.icon(
                        onPressed: _addMeal,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Meal'),
                      ),
                    ],
                  ),
                  ..._meals.asMap().entries.map((entry) {
                    final i = entry.key;
                    final meal = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                DropdownButton<String>(
                                  value: meal['meal'],
                                  items: _mealTypes.map((m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(m.replaceAll('_', ' ').capitalize(), style: const TextStyle(fontSize: 13)),
                                  )).toList(),
                                  onChanged: (v) => setState(() => _meals[i]['meal'] = v!),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    decoration: const InputDecoration(labelText: 'Time', isDense: true),
                                    controller: TextEditingController(text: meal['time']),
                                    onChanged: (v) => _meals[i]['time'] = v,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: GymFlowColors.error, size: 18),
                                  onPressed: () => _removeMeal(i),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Foods: ${(meal['foods'] as List).join(', ')}',
                                style: Theme.of(context).textTheme.bodySmall),
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
}

extension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
