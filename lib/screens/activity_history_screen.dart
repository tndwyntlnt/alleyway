import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../services/api_service.dart';
import '../models/recent_activity.dart';
import '../widgets/recent_activity_list.dart'; 

// Definisikan tipe aktivitas untuk filtering
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

  final Color primaryGreen = const Color(0xFF39524A); 
  
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

  // Widget untuk memfilter dan menampilkan list
  Widget _buildActivityList(List<RecentActivity> activities, ActivityType type) {
    final filteredActivities = activities.where((activity) {
      if (type == ActivityType.earned) {
        return activity.points > 0;
      } else if (type == ActivityType.redeemed) {
        return activity.points < 0;
      }
      return true; 
    }).toList();

    if (filteredActivities.isEmpty) {
      return const Center(child: Text('No history in this category.'));
    }

    return ListView.builder(
      itemCount: filteredActivities.length,
      itemBuilder: (context, index) {
        return RecentActivityList.buildActivityItemRow(
          filteredActivities[index],
          showCard: true, 
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Transaction History', 
          style: TextStyle(
            color: Color(0xFF2E2E2E), 
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true, 
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: primaryGreen), 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); 
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close), 
            onPressed: () {
              Navigator.of(context).pop(); 
            },
          ),
        ],
        // BAGIAN TAB BAR
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
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
                'Failed to load data from API',
                style: TextStyle(color: Colors.red.shade700),
              )
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