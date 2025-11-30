class MyReward {
  final int id;
  final String status;
  final String expiresAt;
  final String rewardName;
  final String? rewardImage;
  final String? description;

  MyReward({
    required this.id,
    required this.status,
    required this.expiresAt,
    required this.rewardName,
    this.rewardImage,
    this.description,
  });

  factory MyReward.fromJson(Map<String, dynamic> json) {
    final rewardDetail = json['reward'] ?? {};

    return MyReward(
      id: json['id'],
      status: json['status'],
      expiresAt: json['expires_at'] ?? '-',
      rewardName: rewardDetail['name'] ?? 'Unknown Reward',
      description: rewardDetail['description'],
      rewardImage: rewardDetail['image_url'],
    );
  }

  String? get fullImageUrl {
    if (rewardImage == null) return null;
    //sesaiin sama baseurl
    return 'http://backendalleyway.web.id/storage/$rewardImage';
  }
}