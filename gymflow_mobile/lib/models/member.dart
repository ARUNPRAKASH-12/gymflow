import 'user.dart';

class Member {
  final String id;
  final String userId;
  final String gymId;
  final String? membershipPlanId;
  final String? startDate;
  final String? endDate;
  final String status;
  final String? assignedTrainerId;
  final String? joinDate;
  final String? referralSource;
  final String? notes;
  final User? user;
  final UserProfile? profile;
  final MembershipPlan? plan;
  final User? trainer;
  final List<dynamic>? recentAttendance;
  final List<dynamic>? recentPayments;

  Member({
    required this.id,
    required this.userId,
    required this.gymId,
    this.membershipPlanId,
    this.startDate,
    this.endDate,
    required this.status,
    this.assignedTrainerId,
    this.joinDate,
    this.referralSource,
    this.notes,
    this.user,
    this.profile,
    this.plan,
    this.trainer,
    this.recentAttendance,
    this.recentPayments,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      gymId: json['gym_id'] ?? '',
      membershipPlanId: json['membership_plan_id'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['status'] ?? 'pending',
      assignedTrainerId: json['assigned_trainer_id'],
      joinDate: json['join_date'],
      referralSource: json['referral_source'],
      notes: json['notes'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      profile: json['profile'] != null ? UserProfile.fromJson(json['profile']) : null,
      plan: json['plan'] != null ? MembershipPlan.fromJson(json['plan']) : null,
      trainer: json['trainer'] != null ? User.fromJson(json['trainer']) : null,
      recentAttendance: json['recent_attendance'],
      recentPayments: json['recent_payments'],
    );
  }

  bool get isActive => status == 'active';
  bool get isExpired => status == 'expired';
  bool get isExpiringSoon {
    if (endDate == null) return false;
    final end = DateTime.parse(endDate!);
    final diff = end.difference(DateTime.now()).inDays;
    return diff >= 0 && diff <= 7;
  }
}

class MembershipPlan {
  final String id;
  final String? gymId;
  final String name;
  final int durationDays;
  final double price;
  final double? discountedPrice;
  final String? description;
  final List<String>? features;
  final String? color;
  final bool isActive;

  MembershipPlan({
    required this.id,
    this.gymId,
    required this.name,
    required this.durationDays,
    required this.price,
    this.discountedPrice,
    this.description,
    this.features,
    this.color,
    this.isActive = true,
  });

  factory MembershipPlan.fromJson(Map<String, dynamic> json) {
    return MembershipPlan(
      id: json['id'] ?? '',
      gymId: json['gym_id'],
      name: json['name'] ?? '',
      durationDays: json['duration_days'] ?? 30,
      price: (json['price'] ?? 0).toDouble(),
      discountedPrice: json['discounted_price']?.toDouble(),
      description: json['description'],
      features: json['features'] != null ? List<String>.from(json['features']) : null,
      color: json['color'],
      isActive: json['is_active'] ?? true,
    );
  }

  double get effectivePrice => discountedPrice ?? price;
  String get durationText {
    if (durationDays >= 365) return 'Annual';
    if (durationDays >= 180) return 'Half-Yearly';
    if (durationDays >= 90) return 'Quarterly';
    return 'Monthly';
  }
}
