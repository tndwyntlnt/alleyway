class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String birthday;
  final String memberId;
  final int points;
  final String memberStatus;
  final String? profilePhotoPath;

  UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.birthday,
    required this.memberId,
    required this.points,
    required this.memberStatus,
    this.profilePhotoPath,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? 'Guest',
      email: json['email'] ?? '-',
      phone: json['phone_number'] ?? '-',
      birthday: json['birthday'] ?? '-',
      memberId: json['id']?.toString() ?? 'N/A',
      points: int.tryParse(json['points_balance']?.toString() ?? '0') ?? 0,
      memberStatus: json['member_status'] ?? 'Bronze',
      profilePhotoPath: json['profile_photo_path'],
    );
  }
  String? get fullProfilePhotoUrl {
    if (profilePhotoPath == null) return null;
    return 'http://backendalleyway.web.id/storage/$profilePhotoPath';
  }
}
