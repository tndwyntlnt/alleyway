import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '../models/reward.dart';
import 'reward_detail_screen.dart';

class RedeemScreen extends StatefulWidget {
  const RedeemScreen({Key? key}) : super(key: key);

  @override
  State<RedeemScreen> createState() => _RedeemScreenState();
}

class _RedeemScreenState extends State<RedeemScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Reward>> _rewardsFuture;

  int _userPoints = 0;
  bool _loadingPoints = true;

  final Color primaryGreen = const Color(0xFF1E392A);
  final Color goldColor = const Color(0xFFC9A96A);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _rewardsFuture = _apiService.fetchRewards();
    });

    _loadUserPoints();
  }

  Future<void> _loadUserPoints() async {
    try {
      final profile = await _apiService.fetchUserProfile();
      if (mounted) {
        setState(() {
          _userPoints = profile.points;
          _loadingPoints = false;
        });
      }
    } catch (e) {
      print("Gagal memuat poin: $e");
      if (mounted) setState(() => _loadingPoints = false);
    }
  }

  Future<void> _handleRedeem(Reward reward) async {
    if (_userPoints < reward.pointsRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Poin Anda tidak mencukupi!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: Text(
          "Tukar ${reward.pointsRequired} poin untuk ${reward.name}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
            child: const Text("Tukar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    bool success = await _apiService.redeemReward(reward.id);
    Navigator.pop(context); 

    if (success) {
      _loadUserPoints();

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 50),
          title: const Text("Berhasil!"),
          content: const Text(
            "Hadiah berhasil ditukar. Cek menu 'My Rewards'.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal menukar hadiah."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: const Text(
          "Redeem Rewards",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Poin Kamu",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.stars, color: goldColor, size: 32),
                    const SizedBox(width: 12),
                    _loadingPoints
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "$_userPoints",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    const SizedBox(width: 8),
                    const Text(
                      "pts",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Reward>>(
              future: _rewardsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("Belum ada hadiah tersedia."),
                  );
                }

                final rewards = snapshot.data!;

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: rewards.length,
                  itemBuilder: (context, index) {
                    final reward = rewards[index];
                    return _buildRewardCard(reward);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(Reward reward) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RewardDetailScreen(reward: reward),
          ),
        ).then((value) {
          if (value == true) {
            _loadUserPoints();
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  color: Colors.grey.shade100,
                  child: Hero(
                    tag: "reward_${reward.id}",
                    child: (reward.fullImageUrl != null)
                        ? CachedNetworkImage(
                            imageUrl: reward.fullImageUrl!,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.image, color: Colors.grey),
                          )
                        : const Icon(
                            Icons.card_giftcard,
                            size: 40,
                            color: Colors.grey,
                          ),
                  ),
                ),
              ),
            ),

            // INFO
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: primaryGreen,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${reward.pointsRequired} Poin",
                    style: TextStyle(
                      color: (_userPoints >= reward.pointsRequired)
                          ? Colors
                                .orange 
                          : Colors.grey, 
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => _handleRedeem(reward),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (_userPoints >= reward.pointsRequired)
                            ? primaryGreen
                            : Colors
                                  .grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        "Tukar",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
