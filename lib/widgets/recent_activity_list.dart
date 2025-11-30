import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/recent_activity.dart';
import '../services/api_service.dart';

class RecentActivityList extends StatelessWidget {
  RecentActivityList({Key? key}) : super(key: key);

  final ApiService apiService = ApiService();

  String formatDate(String dateString) {
    if (dateString == '-' || dateString.isEmpty) return dateString;
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('d MMM yyyy', 'id_ID').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RecentActivity>>(
      future: apiService.fetchRecentActivity(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 100,
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Gagal memuat aktivitas.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final List<RecentActivity> allActivities = snapshot.data!;

          final int itemCount = allActivities.length > 5
              ? 5
              : allActivities.length;
          final List<RecentActivity> displayedActivities = allActivities
              .sublist(0, itemCount);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: displayedActivities.map((activity) {
                return _buildActivityItem(activity);
              }).toList(),
            ),
          );
        } else {
          return Container(
            height: 80,
            alignment: Alignment.center,
            child: Text(
              "Belum ada aktivitas.",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
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
      pointColor = const Color(0xFF1E392A);
      iconColor = const Color(0xFF1E392A);
      iconBgColor = const Color(0xFF1E392A).withOpacity(0.1);
      icon = Icons.arrow_downward;
    } else {
      pointColor = const Color(0xFFE47A7A);
      iconColor = const Color(0xFFE47A7A);
      iconBgColor = const Color(0xFFE47A7A).withOpacity(0.1);
      icon = Icons.card_giftcard;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatDate(activity.date),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

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
    );
  }
}
