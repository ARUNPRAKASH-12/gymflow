class Workout {
  final String id;
  final String? gymId;
  final String? trainerId;
  final String memberId;
  final String name;
  final String? description;
  final String? dayOfWeek;
  final String? scheduleDate;
  final List<Exercise> exercises;
  final bool isCompleted;
  final String? notes;
  final String? trainerName;
  final String? memberName;

  Workout({
    required this.id,
    this.gymId,
    this.trainerId,
    required this.memberId,
    required this.name,
    this.description,
    this.dayOfWeek,
    this.scheduleDate,
    this.exercises = const [],
    this.isCompleted = false,
    this.notes,
    this.trainerName,
    this.memberName,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    List<Exercise> exerciseList = [];
    if (json['exercises'] != null) {
      exerciseList = (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e is Map<String, dynamic> ? e : {}))
          .toList();
    }

    return Workout(
      id: json['id'] ?? '',
      gymId: json['gym_id'],
      trainerId: json['trainer_id'],
      memberId: json['member_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      dayOfWeek: json['day_of_week'],
      scheduleDate: json['schedule_date'],
      exercises: exerciseList,
      isCompleted: json['is_completed'] ?? false,
      notes: json['notes'],
      trainerName: json['trainer_profile']?['full_name'],
      memberName: json['member_profile']?['full_name'],
    );
  }
}

class Exercise {
  final String? exerciseId;
  final String? name;
  final String? category;
  final int sets;
  final int reps;
  final double? weight;
  final String? notes;
  final String? videoUrl;
  final String? imageUrl;

  Exercise({
    this.exerciseId,
    this.name,
    this.category,
    this.sets = 3,
    this.reps = 12,
    this.weight,
    this.notes,
    this.videoUrl,
    this.imageUrl,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final details = json['exercise_details'];
    return Exercise(
      exerciseId: json['exercise_id'],
      name: details?['name'] ?? json['name'],
      category: details?['category'],
      sets: json['sets'] ?? 3,
      reps: json['reps'] ?? 12,
      weight: json['weight']?.toDouble(),
      notes: json['notes'],
      videoUrl: details?['video_url'],
      imageUrl: details?['image_url'],
    );
  }
}
