class Reward {
  final int id;
  final String name;
  final String? description;
  final int pointsRequired;
  final String? imageUrl;

  Reward({
    required this.id,
    required this.name,
    this.description,
    required this.pointsRequired,
    this.imageUrl,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      pointsRequired: int.tryParse(json['points_required'].toString()) ?? 0,
      imageUrl: json['image_url'],
    );
  }

  String? get fullImageUrl {
    if (imageUrl == null) return null;
    return 'https://backendalleyway.web.id/storage/$imageUrl';
  }
}