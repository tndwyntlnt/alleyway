import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_profile.dart';
import '../models/reward.dart';
import '../models/recent_activity.dart';

class ApiService {
  // final String _baseUrl = "http://192.168.100.6:8000";
  // final String _baseUrl = "http://192.168.1.15:8000";
  // final String _baseUrl = "http://10.10.25.31:8000";
  // final String _baseUrl = "http://10.35.33.137";
  // final String _baseUrl = "http://10.231.113.137:8000";
  final String _baseUrl = "http://192.168.1.6:8000";

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

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    var data = json.decode(response.body);

    if (response.statusCode == 200 && data.containsKey('token')) {
      await _storage.write(key: 'auth_token', value: data['token']);
      return data;
    } else {
      return {'message': data['message'] ?? 'Login failed'};
    }
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password, String passwordConfirmation) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/register'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
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
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/api/logout'),
        headers: await _getAuthHeaders(),
      );
    } finally {
      await _storage.delete(key: 'auth_token');
    }
  }

  Future<UserProfile> fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/profile'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return UserProfile.fromJson(data['customer']);
      } else {
        throw Exception('Failed to load profile. Status: ${response.statusCode}');
      }
    } catch (e) {
      print(e.toString());
      return UserProfile(
        name: "Error Loading",
        memberId: "N/A",
        points: 0,
        memberStatus: "Error",
      );
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
        throw Exception('Failed to load rewards. Status: ${response.statusCode}');
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
        throw Exception('Failed to load activity. Status: ${response.statusCode}');
      }
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<Map<String, dynamic>> redeemCode(String code) async {
    return {'message': 'Not implemented yet'};
  }

  // api/rewards/redeem (ini ketrin's redeem page)
  // ini cek poin user cukup ga, kalo cukup reduct.
  Future<bool> redeemReward(int rewardId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/rewards/redeem'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'reward_id': rewardId,
        }),
      );

      if (response.statusCode == 200) {
        return true; // Success!
      } else {
        print ("Redeem failed : ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error redeeming : $e");
      return false;
    }
  }
}