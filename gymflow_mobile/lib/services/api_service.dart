import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  String? _refreshToken;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(StorageKeys.token);
    _refreshToken = prefs.getString(StorageKeys.refreshToken);
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<void> _saveTokens(Map<String, dynamic> response) async {
    final prefs = await SharedPreferences.getInstance();
    if (response.containsKey('token')) {
      _token = response['token'];
      await prefs.setString(StorageKeys.token, _token!);
    }
    if (response.containsKey('refresh_token')) {
      _refreshToken = response['refresh_token'];
      await prefs.setString(StorageKeys.refreshToken, _refreshToken!);
    }
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.token);
    await prefs.remove(StorageKeys.refreshToken);
    _token = null;
    _refreshToken = null;
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$path').replace(
        queryParameters: queryParams,
      );

      late http.Response response;
      final headers = _headers;

      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported method: $method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return {};
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw ApiException(
          statusCode: response.statusCode,
          message: error['error'] ?? 'Request failed',
          details: error['details'],
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Network error: ${e.toString()}');
    }
  }

  // Auth
  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await _request('POST', '/auth/login', body: {'email': email, 'password': password});
    await _saveTokens(result);
    return result;
  }

  Future<Map<String, dynamic>> register(String email, String password, String fullName, {String? phone, String role = 'member'}) async {
    final result = await _request('POST', '/auth/register', body: {
      'email': email,
      'password': password,
      'full_name': fullName,
      'phone': phone,
      'role': role,
    });
    return result;
  }

  Future<void> forgotPassword(String email) async {
    await _request('POST', '/auth/forgot-password', body: {'email': email});
  }

  // Gym
  Future<List<dynamic>> getGyms() async {
    final result = await _request('GET', '/gyms');
    return result is List ? result : result['gyms'] ?? [];
  }

  Future<Map<String, dynamic>> selectGym(String gymId) async {
    final result = await _request('POST', '/gyms/$gymId/select');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.selectedGymId, gymId);
    return result;
  }

  // Profile
  Future<Map<String, dynamic>> getProfile() async {
    return await _request('GET', '/users/me');
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    return await _request('PUT', '/users/me', body: data);
  }

  // Dashboard
  Future<Map<String, dynamic>> getAdminDashboard({String? gymId}) async {
    return await _request('GET', '/dashboard/admin', queryParams: gymId != null ? {'gym_id': gymId} : null);
  }

  Future<Map<String, dynamic>> getTrainerDashboard({String? gymId}) async {
    return await _request('GET', '/dashboard/trainer', queryParams: gymId != null ? {'gym_id': gymId} : null);
  }

  Future<Map<String, dynamic>> getMemberDashboard({String? gymId}) async {
    return await _request('GET', '/dashboard/member', queryParams: gymId != null ? {'gym_id': gymId} : null);
  }

  // Members
  Future<List<dynamic>> getMembers({String? gymId, String? status, int page = 1}) async {
    final result = await _request('GET', '/members', queryParams: {
      if (gymId != null) 'gym_id': gymId,
      if (status != null) 'status': status,
      'page': page.toString(),
    });
    return result['members'] ?? [];
  }

  Future<Map<String, dynamic>> getMember(String id) async {
    return await _request('GET', '/members/$id');
  }

  Future<Map<String, dynamic>> createMember(Map<String, dynamic> data) async {
    return await _request('POST', '/members', body: data);
  }

  Future<Map<String, dynamic>> updateMember(String id, Map<String, dynamic> data) async {
    return await _request('PUT', '/members/$id', body: data);
  }

  Future<Map<String, dynamic>> renewMembership(String id, Map<String, dynamic> data) async {
    return await _request('POST', '/members/$id/renew', body: data);
  }

  // Trainers
  Future<List<dynamic>> getTrainers({String? gymId}) async {
    final result = await _request('GET', '/trainers', queryParams: gymId != null ? {'gym_id': gymId} : null);
    return result is List ? result : [];
  }

  Future<Map<String, dynamic>> getTrainer(String id) async {
    return await _request('GET', '/trainers/$id');
  }

  Future<Map<String, dynamic>> createTrainer(Map<String, dynamic> data) async {
    return await _request('POST', '/trainers', body: data);
  }

  // Membership Plans
  Future<List<dynamic>> getPlans({String? gymId}) async {
    final result = await _request('GET', '/membership-plans', queryParams: gymId != null ? {'gym_id': gymId} : null);
    return result is List ? result : [];
  }

  Future<Map<String, dynamic>> createPlan(Map<String, dynamic> data) async {
    return await _request('POST', '/membership-plans', body: data);
  }

  // Attendance
  Future<Map<String, dynamic>> checkIn(String gymId, {String method = 'manual'}) async {
    return await _request('POST', '/attendance/check-in', body: {'gym_id': gymId, 'method': method});
  }

  Future<Map<String, dynamic>> checkOut(String id) async {
    return await _request('PUT', '/attendance/$id/check-out');
  }

  Future<List<dynamic>> getMyAttendance() async {
    final result = await _request('GET', '/attendance/mine');
    if (result is List) return result;
    return (result as Map)['records'] ?? [];
  }

  Future<Map<String, dynamic>> getTodayAttendance({String? gymId}) async {
    return await _request('GET', '/attendance/today', queryParams: gymId != null ? {'gym_id': gymId} : null);
  }

  Future<Map<String, dynamic>> getAttendanceQR({String? gymId}) async {
    return await _request('GET', '/attendance/qr', queryParams: gymId != null ? {'gym_id': gymId} : null);
  }

  // Payments
  Future<List<dynamic>> getPayments({String? gymId, String? status}) async {
    final result = await _request('GET', '/payments', queryParams: {
      if (gymId != null) 'gym_id': gymId,
      if (status != null) 'status': status,
    });
    return result is List ? result : [];
  }

  Future<List<dynamic>> getMyPayments() async {
    final result = await _request('GET', '/payments/mine');
    return result['payments'] ?? [];
  }

  Future<Map<String, dynamic>> createPayment(Map<String, dynamic> data) async {
    return await _request('POST', '/payments', body: data);
  }

  Future<Map<String, dynamic>> createRazorpayOrder(String planId) async {
    return await _request('POST', '/payments/create-order', body: {'membership_plan_id': planId});
  }

  Future<Map<String, dynamic>> verifyRazorpayPayment(Map<String, dynamic> data) async {
    return await _request('POST', '/payments/verify', body: data);
  }

  // Workouts
  Future<List<dynamic>> getMemberAttendance(String memberId) async {
    final result = await _request('GET', '/members/$memberId/attendance');
    return result is List ? result : [];
  }

  Future<List<dynamic>> getMemberPayments(String memberId) async {
    final result = await _request('GET', '/members/$memberId/payments');
    return result is List ? result : [];
  }

  Future<List<dynamic>> getWorkouts({String? memberId, String? date}) async {
    final result = await _request('GET', '/workouts', queryParams: {
      if (memberId != null) 'member_id': memberId,
      if (date != null) 'date': date,
    });
    return result is List ? result : [];
  }

  Future<Map<String, dynamic>> getWorkout(String id) async {
    return await _request('GET', '/workouts/$id');
  }

  Future<Map<String, dynamic>> createWorkout(Map<String, dynamic> data) async {
    return await _request('POST', '/workouts', body: data);
  }

  Future<Map<String, dynamic>> completeWorkout(String id) async {
    return await _request('PUT', '/workouts/$id/complete');
  }

  Future<List<dynamic>> getExercises({String? category}) async {
    final result = await _request('GET', '/workouts/exercises/list', queryParams: category != null ? {'category': category} : null);
    return result is List ? result : [];
  }

  // Diet Plans
  Future<List<dynamic>> getDiets({String? memberId}) async {
    final result = await _request('GET', '/diet-plans', queryParams: memberId != null ? {'member_id': memberId} : null);
    return result is List ? result : [];
  }

  Future<Map<String, dynamic>> createDiet(Map<String, dynamic> data) async {
    return await _request('POST', '/diet-plans', body: data);
  }

  // Progress
  Future<Map<String, dynamic>> getMyProgress({int limit = 30}) async {
    return await _request('GET', '/progress/mine', queryParams: {'limit': limit.toString()});
  }

  Future<Map<String, dynamic>> addProgress(Map<String, dynamic> data) async {
    return await _request('POST', '/progress', body: data);
  }

  // Notifications
  Future<Map<String, dynamic>> getNotifications({bool unreadOnly = false}) async {
    return await _request('GET', '/notifications', queryParams: unreadOnly ? {'unread_only': 'true'} : null);
  }

  Future<void> markNotificationRead(String id) async {
    await _request('PUT', '/notifications/$id/read');
  }

  // Reports
  Future<Map<String, dynamic>> getRevenueReport({String? gymId, String? from, String? to}) async {
    return await _request('GET', '/reports/revenue', queryParams: {
      if (gymId != null) 'gym_id': gymId,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
    });
  }

  // Export
  Future<String> exportReport(String type) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/reports/export/$type?format=xlsx');
    if (_token == null) throw ApiException(message: 'Not authenticated');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode != 200) {
      throw ApiException(statusCode: response.statusCode, message: 'Export failed');
    }
    final dir = Directory.systemTemp;
    final file = File('${dir.path}/${type}_report.xlsx');
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  // Invoice
  Future<String> downloadInvoice(String paymentId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/payments/$paymentId/invoice/download');
    if (_token == null) throw ApiException(message: 'Not authenticated');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode != 200) {
      throw ApiException(statusCode: response.statusCode, message: 'Download failed');
    }
    final dir = Directory.systemTemp;
    final file = File('${dir.path}/invoice_$paymentId.pdf');
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }
}

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic details;

  ApiException({this.statusCode, required this.message, this.details});

  @override
  String toString() => message;
}
