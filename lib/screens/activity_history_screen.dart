import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/recent_activity.dart';

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
  final Color redeemedColor = const Color(0xFFE47A7A);
  final Color earnedBgColor = const Color(0xFF39524A).withOpacity(0.1);

  // Fungsi Format Tanggal (untuk implementasi lokal)
  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('d MMMM yyyy', 'id_ID').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  // Fungsi Item Row Lokal dengan Logika Ikon yang Benar
  Widget _buildActivityItemRow(
    RecentActivity activity, {
    bool showCard = true,
  }) {
    final bool isEarned = activity.points > 0;

    // Logika styling points/icon
    Color pointColor = isEarned ? primaryGreen : redeemedColor;
    IconData icon = isEarned ? Icons.arrow_downward : Icons.arrow_upward;
    Color iconColor = isEarned ? primaryGreen : redeemedColor;
    Color iconBgColor = isEarned
        ? earnedBgColor
        : redeemedColor.withOpacity(0.2);

    final Widget rowContent = Row(
      children: [
        Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        // Title and Date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.title,
                style: const TextStyle(
                  color: Color(0xFF2E2E2E),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                _formatDate(activity.date),
                style: const TextStyle(fontSize: 14, color: Color(0xFF7C7F64)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Points
        Text(
          '${isEarned ? "+" : ""}${activity.points} Points',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: pointColor,
          ),
        ),
      ],
    );

    if (showCard) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.zero,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: rowContent,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: rowContent,
    );
  }

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
  Widget _buildActivityList(
    List<RecentActivity> activities,
    ActivityType type,
  ) {
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
        return _buildActivityItemRow(filteredActivities[index], showCard: true);
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
            fontWeight: FontWeight.bold,
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
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 8.0,
            ),
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
            return Center(
              child: CircularProgressIndicator(color: primaryGreen),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load data from API',
                style: TextStyle(color: Colors.red.shade700),
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
