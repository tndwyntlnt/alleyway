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

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? 'Guest',
      memberId: json['id'].toString() ?? 'N/A',
      points: json['points_balance'] ?? 0,
      memberStatus: json['member_status'] ?? 'Bronze', 
    );
  }
}