class User {
  final String id;
  final String email;
  final String? phone;
  final String role;
  final String? avatarUrl;
  final bool isVerified;
  final String? selectedGymId;
  final bool isActive;
  final String? lastLogin;
  final String? createdAt;

  User({
    required this.id,
    required this.email,
    this.phone,
    required this.role,
    this.avatarUrl,
    this.isVerified = false,
    this.selectedGymId,
    this.isActive = true,
    this.lastLogin,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'member',
      avatarUrl: json['avatar_url'],
      isVerified: json['is_verified'] ?? false,
      selectedGymId: json['selected_gym_id'],
      isActive: json['is_active'] ?? true,
      lastLogin: json['last_login'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'phone': phone,
        'role': role,
        'avatar_url': avatarUrl,
        'selected_gym_id': selectedGymId,
      };

  bool get isAdmin => role == 'admin' || role == 'superadmin';
  bool get isTrainer => role == 'trainer';
  bool get isMember => role == 'member';
}

class UserProfile {
  final String id;
  final String userId;
  final String fullName;
  final String? dob;
  final String? gender;
  final String? address;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? medicalConditions;
  final String? allergies;
  final String? bloodGroup;
  final String? photoUrl;

  UserProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    this.dob,
    this.gender,
    this.address,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.medicalConditions,
    this.allergies,
    this.bloodGroup,
    this.photoUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      fullName: json['full_name'] ?? '',
      dob: json['dob'],
      gender: json['gender'],
      address: json['address'],
      emergencyContactName: json['emergency_contact_name'],
      emergencyContactPhone: json['emergency_contact_phone'],
      medicalConditions: json['medical_conditions'],
      allergies: json['allergies'],
      bloodGroup: json['blood_group'],
      photoUrl: json['photo_url'],
    );
  }

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'dob': dob,
        'gender': gender,
        'address': address,
        'emergency_contact_name': emergencyContactName,
        'emergency_contact_phone': emergencyContactPhone,
        'medical_conditions': medicalConditions,
        'allergies': allergies,
        'blood_group': bloodGroup,
      };
}

class Gym {
  final String id;
  final String name;
  final String? slug;
  final String? address;
  final String? city;
  final String? state;
  final String? phone;
  final String? email;
  final String? logoUrl;
  final bool isActive;

  Gym({
    required this.id,
    required this.name,
    this.slug,
    this.address,
    this.city,
    this.state,
    this.phone,
    this.email,
    this.logoUrl,
    this.isActive = true,
  });

  factory Gym.fromJson(Map<String, dynamic> json) {
    return Gym(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      phone: json['phone'],
      email: json['email'],
      logoUrl: json['logo_url'],
      isActive: json['is_active'] ?? true,
    );
  }
}
