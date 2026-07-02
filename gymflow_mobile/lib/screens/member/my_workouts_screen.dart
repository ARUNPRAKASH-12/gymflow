import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';
import '../../models/workout.dart';

class MyWorkoutsScreen extends ConsumerStatefulWidget {
  const MyWorkoutsScreen({super.key});

  @override
  ConsumerState<MyWorkoutsScreen> createState() => _MyWorkoutsScreenState();
}

class _MyWorkoutsScreenState extends ConsumerState<MyWorkoutsScreen> {
  final _api = ApiService();
  List<Workout> _workouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.getWorkouts();
      setState(() => _workouts = data.map((w) => Workout.fromJson(w)).toList());
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final todayWorkouts = _workouts.where((w) => w.scheduleDate == today).toList();
    final upcoming = _workouts.where((w) => w.scheduleDate != null && w.scheduleDate! > today && !w.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Workouts')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (todayWorkouts.isNotEmpty) ...[
                    Text("Today's Workouts", style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 12),
                    ...todayWorkouts.map((w) => _WorkoutCard(
                          workout: w,
                          onComplete: () async {
                            await _api.completeWorkout(w.id);
                            _load();
                          },
                        )),
                    const SizedBox(height: 24),
                  ],
                  Text('All Workouts', style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 12),
                  if (_workouts.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.fitness_center, size: 48, color: GymFlowColors.textMuted),
                              const SizedBox(height: 12),
                              Text('No workouts assigned yet', style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ..._workouts.map((w) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: w.isCompleted
                                  ? GymFlowColors.successBg
                                  : GymFlowColors.primary.withOpacity(0.1),
                              child: Icon(
                                w.isCompleted ? Icons.check_circle : Icons.fitness_center,
                                color: w.isCompleted ? GymFlowColors.success : GymFlowColors.primary,
                                size: 20,
                              ),
                            ),
                            title: Text(w.name, style: Theme.of(context).textTheme.bodyLarge),
                            subtitle: Text(
                              '${w.dayOfWeek ?? w.scheduleDate ?? 'Custom'} • ${w.exercises.length} exercises',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            trailing: w.isCompleted
                                ? const Icon(Icons.check, color: GymFlowColors.success)
                                : null,
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onComplete;
  const _WorkoutCard({required this.workout, this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(workout.name, style: Theme.of(context).textTheme.titleLarge),
                if (!workout.isCompleted)
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: onComplete,
                      child: const Text('Complete'),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: GymFlowColors.successBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Done', style: TextStyle(color: GymFlowColors.success, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            if (workout.description != null) ...[
              const SizedBox(height: 8),
              Text(workout.description!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
            Text('${workout.exercises.length} exercises',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
