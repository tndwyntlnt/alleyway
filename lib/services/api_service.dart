import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_profile.dart';
import '../models/reward.dart';
import '../models/recent_activity.dart';

class ApiService {
  // Pilihan Base URL (Sesuaikan dengan environment Anda)
  // final String _baseUrl = "http://backendalleyway.test";
  // final String _baseUrl = "http://10.134.40.142:8000";
  // final String _baseUrl = "https://10.54.235.142:8000";
  // Gunakan 10.0.2.2 jika menggunakan Android Emulator bawaan
  // final String _baseUrl = "http://10.0.2.2:8000";
  final String _baseUrl = "http://192.168.56.1:8000";

  final _storage = const FlutterSecureStorage();

  // --- HELPER METHODS ---

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    String? token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- AUTHENTICATION (LOGIN & REGISTER) ---

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      var data = json.decode(response.body);

      if (response.statusCode == 200 && data.containsKey('token')) {
        await _storage.write(key: 'auth_token', value: data['token']);
        return data;
      } else {
        return {'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'message': 'Connection error: $e'};
    }
  }

  // PERBAIKAN DI SINI: Menambahkan parameter phone dan birthday agar tersimpan saat registrasi
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String phone, // Ditambahkan
    String birthday, // Ditambahkan
    String password,
    String passwordConfirmation,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone, // Kirim ke backend
          'birthday': birthday, // Kirim ke backend
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      var data = json.decode(response.body);

      if (response.statusCode == 201 && data.containsKey('token')) {
        await _storage.write(key: 'auth_token', value: data['token']);
        return data;
      } else {
        return data;
      }
    } catch (e) {
      return {'message': 'Connection error: $e'};
    }
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/api/logout'),
        headers: await _getAuthHeaders(),
      );
    } catch (e) {
      // Ignore errors on logout
    } finally {
      await _storage.delete(key: 'auth_token');
    }
  }

  // --- USER DATA & FEATURES ---

  Future<UserProfile> fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/profile'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        // Pastikan struktur JSON sesuai, misal: data['customer'] atau data['user']
        // Sesuaikan dengan respon API backend Anda
        return UserProfile.fromJson(data['customer'] ?? data['user']);
      } else {
        throw Exception(
          'Failed to load profile. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print(e.toString());
      // PERBAIKAN: Menambahkan field email, phone, dan birthday agar sesuai dengan UserProfile
      return UserProfile(
        name: "Error Loading",
        email: "-",
        phone: "-",
        birthday: "-",
        memberId: "N/A",
        points: 0,
        memberStatus: "Error",
      );
    }
  }

  // --- FUNGSI BARU: Update User Profile ---
  Future<bool> updateUserProfile(
    String name,
    String email,
    String phone,
    String birthday,
  ) async {
    try {
      // Pastikan endpoint ini sesuai dengan backend Anda (misal: /api/profile/update)
      final response = await http.post(
        Uri.parse('$_baseUrl/api/profile/update'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'birthday': birthday,
        }),
      );

      if (response.statusCode == 200) {
        return true; // Berhasil update
      } else {
        print("Update failed: ${response.body}");
        return false; // Gagal update
      }
    } catch (e) {
      print("Update error: $e");
      return false;
    }
  }

  Future<List<Reward>> fetchRewards() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/rewards'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<dynamic> rewardListJson = data['rewards'];
        List<Reward> rewards = rewardListJson
            .map((item) => Reward.fromJson(item, _baseUrl))
            .toList();
        return rewards;
      } else {
        throw Exception(
          'Failed to load rewards. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<List<RecentActivity>> fetchRecentActivity() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/activity-history'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<dynamic> activityListJson = data['data'];
        List<RecentActivity> activities = activityListJson
            .map((item) => RecentActivity.fromJson(item))
            .toList();
        return activities;
      } else {
        throw Exception(
          'Failed to load activity. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<Map<String, dynamic>> redeemCode(String code) async {
    return {'message': 'Not implemented yet'};
  }

  // --- FORGOT PASSWORD FEATURES (Dipertahankan & Disesuaikan) ---

  // 1. Request Token (Kirim Email)
  Future<Map<String, dynamic>> sendResetToken(String email) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$_baseUrl/api/forgot-password',
        ), // Path disesuaikan dengan _baseUrl
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          throw Exception("Gagal mengirim token: ${response.statusCode}");
        }
      }
    } catch (e) {
      throw Exception("Koneksi error: $e");
    }
  }

  // 2. Verifikasi Token
  Future<bool> verifyToken(String email, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/verify-token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'token': token}),
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 3. Reset Password Baru
  Future<Map<String, dynamic>> resetPassword(
    String email,
    String token,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'token': token,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception("Koneksi error: $e");
    }
  }
}
