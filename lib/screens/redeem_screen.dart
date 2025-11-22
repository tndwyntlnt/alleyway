import 'package:alleyway/models/user_profile.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/reward.dart';

class AppColors {
  static const Color darkGreen = Color(0xFF285b34);
  static const Color lightGreen = Color(0xFF74bc84);
  static const Color lighterGreen = Color(0xFF95d5a3);
}

class RedeemScreen extends StatefulWidget {
  const RedeemScreen({super.key});

  @override
  State<RedeemScreen> createState() => _RedeemScreenState();
}

class _RedeemScreenState extends State<RedeemScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Reward>> _rewardsFuture;
  late Future<UserProfile> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _rewardsFuture = _apiService.fetchRewards();

    _userProfileFuture = _apiService.fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: FutureBuilder<List<Reward>>(
              future: _rewardsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.darkGreen));
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error loading rewards.\nCheck your internet connection.", textAlign: TextAlign.center));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No rewards available."));
                }

                final rewards = snapshot.data!;
                
                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75, // Controls height of cards
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: rewards.length,
                  itemBuilder: (context, index) {
                    return _buildRewardCard(rewards[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: const [
                Icon(Icons.arrow_back, color: Colors.white),
                SizedBox(width: 8),
                Text("Back", style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Redeem Rewards",
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Choose your reward",
                    style: TextStyle(color: AppColors.lighterGreen, fontSize: 14),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children:[
                const Text("Your Points", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  // Static for now, can be connected to UserProfile later
                  FutureBuilder<UserProfile>(
                    future: _userProfileFuture,
                    builder: (context,snapshot){
                      if(snapshot.hasData){
                        return Text(
                          "${snapshot.data!.points}",
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)
                        );
                      } else {
                        return const Text("...", style: TextStyle(color: Colors.white, fontSize: 28));
                      }
                    },
                  ), 
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(Reward reward) {
    return Container(
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
          // IMAGE SECTION
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                reward.imageUrl, // Using the field from your reward.dart
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image fails to load
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.coffee, size: 40, color: Colors.grey)),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.name, // Using exact field name
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "${reward.pointsRequired} pts", // FIXED: Changed from .points to .pointsRequired
                  style: const TextStyle(color: AppColors.lightGreen, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async{
                      bool success = await _apiService.redeemReward(reward.id);

                      if(success) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Successfully redeemed ${reward.name}!")),
                        );
                        setState(() {
                          _userProfileFuture = _apiService.fetchUserProfile();
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(backgroundColor: Colors.red, content:  Text("Failed to redeem, not enough points?")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      elevation: 0,
                    ),
                    child: const Text("Redeem", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}