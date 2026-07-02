class Attendance {
  final String id;
  final String userId;
  final String gymId;
  final String checkIn;
  final String? checkOut;
  final String date;
  final String method;
  final String? notes;
  final UserInfo? user;
  final UserInfo? profile;

  Attendance({
    required this.id,
    required this.userId,
    required this.gymId,
    required this.checkIn,
    this.checkOut,
    required this.date,
    required this.method,
    this.notes,
    this.user,
    this.profile,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      gymId: json['gym_id'] ?? '',
      checkIn: json['check_in'] ?? '',
      checkOut: json['check_out'],
      date: json['date'] ?? '',
      method: json['method'] ?? 'manual',
      notes: json['notes'],
      user: json['user'] != null ? UserInfo.fromJson(json['user']) : null,
      profile: json['profile'] != null ? UserInfo.fromJson(json['profile']) : null,
    );
  }

  String get duration {
    if (checkOut == null) return 'In progress';
    final inTime = DateTime.parse(checkIn);
    final outTime = DateTime.parse(checkOut!);
    final diff = outTime.difference(inTime);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}

class UserInfo {
  final String? id;
  final String? email;
  final String? fullName;
  final String? photoUrl;

  UserInfo({this.id, this.email, this.fullName, this.photoUrl});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      photoUrl: json['photo_url'],
    );
  }
}
