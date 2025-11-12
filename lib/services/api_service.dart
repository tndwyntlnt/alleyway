// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/user_profile.dart';
// import '../models/reward.dart';
// import '../models/recent_activity.dart';

// class ApiService {
//   // Ganti 'your-api-base-url' dengan URL backend Laravel Anda
//   // Contoh: 'http://10.0.2.2:8000' jika di emulator Android
//   // final String _baseUrl = "http://10.0.2.2:8000";
//   final String _baseUrl = "http://192.168.100.6:8000";
  
//   // Ganti 'YOUR_AUTH_TOKEN' dengan token (misal: Bearer token)
//   // yang didapat saat login.
//   final String _authToken = "12|atiQ5w4xEWHvjncELuVHtWP13yWtG6HzDdBBOp3Uf33f6c3c"; 

//   Future<UserProfile> fetchUserProfile() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$_baseUrl/api/profile'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $_authToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         // Jika sukses, parse JSON dan kembalikan UserProfile
//         // Asumsi data user ada di dalam key 'data'
//         // Jika tidak, ganti `json.decode(response.body)['data']`
//         // menjadi `json.decode(response.body)`
//         print("===== RESPON JSON DARI /api/profile =====");
//         print(response.body);
//         var data = json.decode(response.body);
//         return UserProfile.fromJson(data['customer']);
//       } else {
//         // Jika gagal, lempar error
//         throw Exception('Failed to load profile. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       // Menangani error koneksi atau lainnya
//       print(e.toString());
      
//       // *** PENTING: Mengembalikan MOCK DATA jika API Gagal ***
//       // Ini agar UI tetap bisa di-build saat development
//       // Hapus ini di produksi
//       return UserProfile(
//         name: "Alex Johnson (Mock)",
//         memberId: "AM2025-12345",
//         points: 250,
//         memberStatus: "Silver Member",
//       );
//     }
//   }

//   // ... di dalam file lib/services/api_service.dart
// // ... di bawah method fetchUserProfile()

//   Future<List<Reward>> fetchRewards() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$_baseUrl/api/rewards'), // Panggil endpoint rewards
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $_authToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         // ===============================================
//         // == TAMBAHKAN PRINT INI UNTUK DEBUGGING ==
//         print("===== RESPON JSON DARI /api/rewards =====");
//         print(response.body);
//         // ===============================================

//         // API ini akan mengembalikan LIST, bukan 1 objek
//         // Kita asumsikan list-nya ada di dalam key 'data'
//         // Jika tidak, Anda perlu menyesuaikannya
        
//         var data = json.decode(response.body);
        
//         // Ubah list dinamis (List<dynamic>) menjadi list reward (List<Reward>)
//         // Asumsi list ada di key 'data'
//         List<dynamic> rewardListJson = data['rewards']; 
        
//         List<Reward> rewards = rewardListJson
//             .map((item) => Reward.fromJson(item, _baseUrl))
//             .toList();
            
//         return rewards;

//       } else {
//         throw Exception('Failed to load rewards. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print(e.toString());
//       // Kembalikan list kosong jika error
//       return []; 
//     }
//   }

//   Future<List<RecentActivity>> fetchRecentActivity() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$_baseUrl/api/activity-history'), // Panggil endpoint baru
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $_authToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         print("===== RESPON JSON DARI /api/activity-history =====");
//         print(response.body);

//         var data = json.decode(response.body);
        
//         // Ambil list dari key 'data' (sesuai respon PHP kita)
//         List<dynamic> activityListJson = data['data']; 
        
//         List<RecentActivity> activities = activityListJson
//             .map((item) => RecentActivity.fromJson(item))
//             .toList();
            
//         return activities;

//       } else {
//         throw Exception('Failed to load activity history. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print(e.toString());
//       return []; // Kembalikan list kosong jika error
//     }
//   }

//   // Anda bisa tambahkan method lain di sini nanti
//   // Future<List<SpecialOffer>> fetchSpecialOffers() async { ... }
//   // Future<List<RecentActivity>> fetchRecentActivity() async { ... }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Import semua model Anda
import '../models/user_profile.dart';
import '../models/reward.dart';
import '../models/recent_activity.dart';

class ApiService {
  // Ganti 'your-api-base-url' dengan IP Anda (misal: 'http://192.168.100.6:8000')
  final String _baseUrl = "http://192.168.100.6:8000";

  // Buat instance secure storage
  final _storage = const FlutterSecureStorage();

  // --- HELPER UNTUK OTENTIKASI ---

  // Private helper untuk mengambil token
  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Private helper untuk mengambil header dengan token
  Future<Map<String, String>> _getAuthHeaders() async {
    String? token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- METHOD OTENTIKASI (LOGIN/REGISTER/LOGOUT) ---

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
      // Jika sukses, simpan token
      await _storage.write(key: 'auth_token', value: data['token']);
      return data; // Kembalikan data (termasuk token)
    } else {
      // Kembalikan pesan error
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
      // Jika sukses, simpan token
      await _storage.write(key: 'auth_token', value: data['token']);
      return data;
    } else {
      // Kembalikan error (termasuk error validasi)
      return data; 
    }
  }

  Future<void> logout() async {
    try {
      // Panggil API /logout di server
      await http.post(
        Uri.parse('$_baseUrl/api/logout'),
        headers: await _getAuthHeaders(), // Kirim token untuk logout
      );
    } finally {
      // Selalu hapus token di sisi klien, apa pun yang terjadi
      await _storage.delete(key: 'auth_token');
    }
  }

  // --- METHOD API YANG SUDAH ADA (DIMODIFIKASI) ---

  Future<UserProfile> fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/profile'),
        headers: await _getAuthHeaders(), // Gunakan header baru
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return UserProfile.fromJson(data['customer']);
      } else {
        throw Exception('Failed to load profile. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Mengembalikan data mock jika GAGAL (opsional, tapi bagus untuk dev)
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
        headers: await _getAuthHeaders(), // Gunakan header baru
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
        headers: await _getAuthHeaders(), // Gunakan header baru
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

  // --- METHOD UNTUK QUICK ACTIONS (YANG AKAN KITA BUAT NANTI) ---

  // Kita akan isi ini nanti
  Future<Map<String, dynamic>> redeemCode(String code) async {
    // ...
    return {'message': 'Not implemented yet'};
  }
}