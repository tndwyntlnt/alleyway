class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String birthday;
  final String memberId;
  final int points;
  final String memberStatus; // Bronze, Silver, Gold

  UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.birthday,
    required this.memberId,
    required this.points,
    required this.memberStatus,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? 'Guest',
      // Field ini tetap ada untuk mendukung tampilan UI Profile
      email: json['email'] ?? '-',
      phone: json['phone'] ?? '-',
      birthday: json['birthday'] ?? '-',

      // Update sesuai request Anda (menggunakan 'id' dan 'points_balance')
      memberId: json['id']?.toString() ?? 'N/A',
      points: int.tryParse(json['points_balance']?.toString() ?? '0') ?? 0,
      memberStatus: json['member_status'] ?? 'Bronze',
    );
  }
}
