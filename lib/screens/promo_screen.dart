import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/reward.dart'; 
import '../services/api_service.dart'; 

class PromoScreen extends StatefulWidget {
  const PromoScreen({super.key});

  @override
  State<PromoScreen> createState() => _PromoScreenState();
}

class _PromoScreenState extends State<PromoScreen> {
  // Color Definitions (Cleaned up from invisible characters)
  final Color primaryGreenDark = const Color(0xFF1E3932);
  final Color primaryGreenLight = const Color(0xFF3C6E47);
  final Color lightGreenText = const Color(0xFF8FB996);
  final Color darkText = const Color(0xFF2E2E2E);
  final Color mutedText = const Color(0xFF9AA99A);
  final Color accentBadge = const Color(0xFFC9A96A);
  final Color bgColor = const Color(0xFFF7F8F5);
  final Color lightBgCard = const Color(0xFFF7F8F5); 

  // API Fetching Variables
  late Future<List<Reward>> _futureRewards;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _futureRewards = _apiService.fetchRewards();
  }

  Widget _buildRewardGridCard(BuildContext context, Reward reward) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          CachedNetworkImage(
            imageUrl: reward.imageUrl,
            height: 120, 
            width: double.infinity,
            fit: BoxFit.contain, 
            placeholder: (context, url) => Container(
              height: 120,
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(color: primaryGreenLight, strokeWidth: 2),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: 120,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.broken_image, size: 30, color: Colors.grey),
              ),
            ),
          ),
          
          // Content Section
          Expanded(
            child: Container(
              color: lightBgCard, 
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title 
                  Text(
                    reward.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: darkText, 
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4), 
                  
                  // Description / Points Required
                  Text(
                    '${reward.pointsRequired} Points Required', 
                    style: TextStyle(
                      fontSize: 12,
                      color: darkText, 
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
          
                  // Detail Rewards Label
                  Row(
                    children: [
                      Icon(Icons.star, size: 10, color: mutedText), 
                      SizedBox(width: 1),
                      Text(
                        'Rewards', 
                        style: TextStyle(
                          fontSize: 10,
                          color: mutedText, 
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // 1. Header 
          Container(
            padding: const EdgeInsets.only(top: 48, bottom: 32, left: 24, right: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryGreenDark, primaryGreenLight],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, size: 20, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Back',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                const Text(
                  'Special Offers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Description
                Text(
                  'Exclusive deals for members',
                  style: TextStyle(
                    color: lightGreenText,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          // 2. Promos List 
          Expanded(
            child: FutureBuilder<List<Reward>>(
              future: _futureRewards,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: primaryGreenLight)
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text('Failed to load rewards. Error: ${snapshot.error}'),
                    )
                  );
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final rewards = snapshot.data!;
                  
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      crossAxisSpacing: 16, 
                      mainAxisSpacing: 16, 
                      childAspectRatio: 0.85, 
                    ),
                    itemCount: rewards.length,
                    itemBuilder: (context, index) {
                      final reward = rewards[index];
                      return _buildRewardGridCard(context, reward);
                    },
                  );
                } else {
                  return const Center(
                    child: Text('No offers/rewards available at the moment.'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}