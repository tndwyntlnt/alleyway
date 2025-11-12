import 'dart:convert';

class Reward {
  final int id;
  final String name;
  final int pointsRequired;
  final String imageUrl;

  Reward({
    required this.id,
    required this.name,
    required this.pointsRequired,
    required this.imageUrl,
  });

  factory Reward.fromJson(Map<String, dynamic> json, String baseUrl) {
    String finalImageUrl;
    if (json['image_url'] != null) {
      finalImageUrl = '$baseUrl/storage/${json['image_url']}';
    } else {
      finalImageUrl = 'https://via.placeholder.com/400';
    }

    return Reward(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Nama Hadiah Tidak Ada',
      pointsRequired: json['points_required'] ?? 0,
      imageUrl: finalImageUrl,
    );
  }
}