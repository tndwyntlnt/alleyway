class Promo {
  final int id;
  final String title;
  final String description;
  final String? imageUrl;

  Promo({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
  });

  factory Promo.fromJson(Map<String, dynamic> json) {
    return Promo(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      imageUrl: json['image_url'],
    );
  }

  String? get fullImageUrl {
    if (imageUrl == null) return null;
    //sesuaikan dengan baseurl
    return 'http://backendalleyway.web.id/storage/$imageUrl';
  }
}