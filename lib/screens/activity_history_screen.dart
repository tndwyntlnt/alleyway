import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/recent_activity.dart';

enum ActivityType { all, earned, redeemed }

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> with SingleTickerProviderStateMixin {
  late Future<List<RecentActivity>> _futureActivities;
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  final Color primaryGreen = const Color(0xFF1E392A);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _futureActivities = _apiService.fetchRecentActivity();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildActivityList(List<RecentActivity> activities, ActivityType type) {
    final filteredActivities = activities.where((activity) {
      if (type == ActivityType.earned) {
        return activity.type == 'earn'; 
      } else if (type == ActivityType.redeemed) {
        return activity.type == 'spend';
      }
      return true;
    }).toList();

    if (filteredActivities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No history in this category.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredActivities.length,
      itemBuilder: (context, index) {
        return _buildActivityItem(filteredActivities[index]);
      },
    );
  }

  Widget _buildActivityItem(RecentActivity activity) {
    final bool isEarn = activity.type == 'earn';
    final bool isPending = activity.amount.toLowerCase().contains('pending');

    Color pointColor;
    Color iconColor;
    Color iconBgColor;
    IconData icon;

    if (isPending) {
      pointColor = Colors.orange;
      iconColor = Colors.orange;
      iconBgColor = Colors.orange.withOpacity(0.1);
      icon = Icons.access_time_filled;
    } else if (isEarn) {
      pointColor = primaryGreen;
      iconColor = primaryGreen;
      iconBgColor = primaryGreen.withOpacity(0.1);
      icon = Icons.arrow_downward;
    } else {
      pointColor = const Color(0xFFE47A7A);
      iconColor = const Color(0xFFE47A7A);
      iconBgColor = const Color(0xFFE47A7A).withOpacity(0.1);
      icon = Icons.card_giftcard;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isPending ? Border.all(color: Colors.orange.withOpacity(0.3)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: const TextStyle(
                      color: Color(0xFF2E2E2E),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.date,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            
            Text(
              isPending ? activity.amount : "${activity.amount} pts",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: pointColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F5),
      appBar: AppBar(
        title: const Text(
          'Transaction History',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryGreen),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: primaryGreen,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black54,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Earned'),
                  Tab(text: 'Redeemed'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<RecentActivity>>(
        future: _futureActivities,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryGreen));
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load data',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('No activity history available.'));
          } else if (snapshot.hasData) {
            final activities = snapshot.data!;

            return TabBarView(
              controller: _tabController,
              children: [
                _buildActivityList(activities, ActivityType.all),
                _buildActivityList(activities, ActivityType.earned),
                _buildActivityList(activities, ActivityType.redeemed),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}