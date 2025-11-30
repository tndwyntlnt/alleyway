import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_profile.dart';
import '../models/reward.dart';
import '../models/recent_activity.dart';
import '../models/promo.dart';
import '../models/my_reward.dart';
import '../models/notification_item.dart';

class ApiService {
  // final String _baseUrl = "http://10.145.66.89:8000";
  final String _baseUrl = "https://backendalleyway.web.id";

  final _storage = const FlutterSecureStorage();

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

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String phone,
    String birthday,
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
          'phone': phone,
          'birthday': birthday,
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
      //
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
        return UserProfile.fromJson(data['customer'] ?? data['user']);
      } else {
        throw Exception(
          'Failed to load profile. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print(e.toString());
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

  Future<Map<String, dynamic>> updateUserProfile(
    String name,
    String email,
    String phone,
    String birthday,
    File? imageFile,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl/api/profile/update');

      final request = http.MultipartRequest('POST', url);

      final token = await _getToken();
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['phone'] = phone;
      request.fields['birthday'] = birthday;

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo',
            imageFile.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final body = jsonDecode(response.body);
        String msg = body['message'] ?? 'Gagal update profil';
        if (body['errors'] != null) {
          msg = body['errors'].values.first[0];
        }
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      print("Update error: $e");
      return {'success': false, 'message': 'Terjadi kesalahan koneksi'};
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
            .map((item) => Reward.fromJson(item))
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
        Uri.parse('$_baseUrl/api/notifications'),
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
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/redeem-code'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({'transaction_code': code}),
      );

      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Code redeemed successfully!',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to redeem code',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }


  Future<Map<String, dynamic>> sendResetToken(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengirim token',
        };
      }
    } catch (e) {
      return {'success': false, 'message': "Koneksi error: $e"};
    }
  }

  Future<Map<String, dynamic>> verifyToken(String email, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/verify-token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'token': token}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Token valid'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Token tidak valid',
        };
      }
    } catch (e) {
      return {'success': false, 'message': "Koneksi error: $e"};
    }
  }

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

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        String msg = data['message'] ?? 'Gagal reset password';
        if (data['password'] != null) msg = data['password'][0];
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {'success': false, 'message': "Koneksi error: $e"};
    }
  }

  Future<bool> redeemReward(int rewardId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/rewards/redeem'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({'reward_id': rewardId}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Redeem failed : ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error redeeming : $e");
      return false;
    }
  }

  Future<List<Promo>> fetchPromos() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/promos'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<dynamic> listJson = data['promos'];

        return listJson.map((item) => Promo.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load promos');
      }
    } catch (e) {
      print("Error fetching promos: $e");
      return [];
    }
  }

  Future<List<MyReward>> fetchMyRewards() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/my-rewards'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<dynamic> listJson = data['data'];

        return listJson.map((item) => MyReward.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load my rewards');
      }
    } catch (e) {
      print("Error fetching my rewards: $e");
      return [];
    }
  }

  Future<List<NotificationItem>> fetchNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/notifications'),
        headers: await _getAuthHeaders(),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<dynamic> listJson = data['data'];

        return listJson.map((item) => NotificationItem.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching notifications: $e");
      return [];
    }
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/change-password'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation':
              confirmPassword,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Gagal ganti password: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
}
