import 'dart:convert';

class Reward {
  final int id;
  final String name;
  final int pointsRequired;
  final String imageUrl; // Asumsi ada URL gambar

  Reward({
    required this.id,
    required this.name,
    required this.pointsRequired,
    required this.imageUrl,
  });

  factory Reward.fromJson(Map<String, dynamic> json, String baseUrl) {
    // ==========================================================
    // !!! PENTING: SESUAIKAN KEY JSON DI BAWAH INI !!!
    // ==========================================================
    
    String finalImageUrl;
    if (json['image_url'] != null) {
      // GABUNGKAN baseUrl DENGAN path gambar
      // Asumsi path Anda ada di folder 'storage' publik.
      // Jika bukan 'storage', ganti bagian '/storage/'
      finalImageUrl = '$baseUrl/storage/${json['image_url']}';
    } else {
      // Jika null, gunakan placeholder
      finalImageUrl = 'https://via.placeholder.com/400';
    }

    return Reward(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Nama Hadiah Tidak Ada',
      pointsRequired: json['points_required'] ?? 0,
      imageUrl: finalImageUrl, // Gunakan URL yang sudah lengkap
    );
  }
}