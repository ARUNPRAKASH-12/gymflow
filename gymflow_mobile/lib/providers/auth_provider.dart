import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../config/constants.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final User? user;
  final UserProfile? profile;
  final String? token;
  final String? role;
  final List<Gym> gyms;
  final String? selectedGymId;
  final String? selectedGymName;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.user,
    this.profile,
    this.token,
    this.role,
    this.gyms = const [],
    this.selectedGymId,
    this.selectedGymName,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    User? user,
    UserProfile? profile,
    String? token,
    String? role,
    List<Gym>? gyms,
    String? selectedGymId,
    String? selectedGymName,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
      profile: profile ?? this.profile,
      token: token ?? this.token,
      role: role ?? this.role,
      gyms: gyms ?? this.gyms,
      selectedGymId: selectedGymId ?? this.selectedGymId,
      selectedGymName: selectedGymName ?? this.selectedGymName,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api;

  AuthNotifier(this._api) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageKeys.token);
    final role = prefs.getString(StorageKeys.userRole);
    final gymId = prefs.getString(StorageKeys.selectedGymId);
    final gymName = prefs.getString(StorageKeys.selectedGymName);

    if (token != null) {
      try {
        state = state.copyWith(isLoading: true);
        final profile = await _api.getProfile();
        final userData = profile['user'];
        final profileData = profile['profile'];
        final gymsData = profile['gyms'];

        final user = userData != null ? User.fromJson(userData) : null;
        final userProfile = profileData != null ? UserProfile.fromJson(profileData) : null;
        final gyms = gymsData != null ? (gymsData as List).map((g) => Gym.fromJson(g)).toList() : <Gym>[];

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: user,
          profile: userProfile,
          role: user?.role ?? role,
          gyms: gyms,
          selectedGymId: gymId,
          selectedGymName: gymName,
        );
      } catch (e) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _api.login(email, password);
      final user = User.fromJson(result['user']);
      final gyms = result['gyms'] != null ? (result['gyms'] as List).map((g) => Gym.fromJson(g)).toList() : <Gym>[];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.userRole, user.role);
      await prefs.setString(StorageKeys.userId, user.id);

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: user,
        role: user.role,
        gyms: gyms,
        error: null,
      );

      if (gyms.isNotEmpty) {
        await selectGym(gyms.first.id);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> register(String email, String password, String fullName, {String? phone, String role = 'member'}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _api.register(email, password, fullName, phone: phone, role: role);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> selectGym(String gymId, {String? gymName}) async {
    try {
      await _api.selectGym(gymId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.selectedGymId, gymId);
      if (gymName != null) {
        await prefs.setString(StorageKeys.selectedGymName, gymName);
      }
      state = state.copyWith(selectedGymId: gymId, selectedGymName: gymName);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final result = await _api.updateProfile(data);
      final updatedProfile = UserProfile.fromJson(result['profile']);
      state = state.copyWith(profile: updatedProfile);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    await _api.clearTokens();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ApiService());
});
