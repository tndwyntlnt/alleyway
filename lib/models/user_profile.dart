import 'dart:convert';

class UserProfile {
  final String name;
  final String memberId;
  final int points;
  final String memberStatus;

  UserProfile({
    required this.name,
    required this.memberId,
    required this.points,
    required this.memberStatus,
  });

  // Ini adalah factory constructor untuk membuat instance dari JSON
  // Sesuaikan 'jsonKey' dengan apa yang ada di respon API Laravel Anda
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? 'Guest', // 'name' sudah benar
      memberId: json['id'].toString() ?? 'N/A', // Ganti 'member_id' menjadi 'id' (dan ubah ke String)
      points: json['points_balance'] ?? 0, // Ganti 'points' menjadi 'points_balance'
      
      // Key 'member_status' tidak ada di API Anda. 
      // Kita akan gunakan nilai default 'Bronze' untuk sementara.
      memberStatus: json['member_status'] ?? 'Bronze', 
    );
  }
}