import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/recent_activity.dart';
import '../services/api_service.dart';

class RecentActivityList extends StatelessWidget {
  RecentActivityList({Key? key}) : super(key: key);

  final ApiService apiService = ApiService();

  static final Color primaryGreen = const Color(0xFF39524A); 
  static final Color redeemedColor = const Color(0xFFE47A7A); 
  static final Color earnedBgColor = const Color(0xFF39524A).withOpacity(0.1); 

  static String formatDate(String dateString) {
     try {
       final dateTime = DateTime.parse(dateString);
       return DateFormat('d MMMM yyyy', 'id_ID').format(dateTime); 
     } catch (e) {
       return dateString;
     }
  }

  static Widget buildActivityItemRow(RecentActivity activity, {bool showCard = true}) {
    final bool isEarned = activity.points > 0;
    
    // Logika styling points/icon
    Color pointColor = isEarned ? primaryGreen : redeemedColor;
    IconData icon = isEarned ? Icons.arrow_upward : Icons.arrow_downward;
    Color iconColor = isEarned ? primaryGreen : redeemedColor;
    Color iconBgColor = isEarned ? earnedBgColor : redeemedColor.withOpacity(0.2);

    final Widget rowContent = Row(
      children: [
        Container(
          width: 40,
          height: 40,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
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
                formatDate(activity.date),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
  Widget build(BuildContext context) {
    return FutureBuilder<List<RecentActivity>>(
      future: apiService.fetchRecentActivity(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 150,
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text("Error: ${snapshot.error}"),
            ),
          );
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final List<RecentActivity> activities = snapshot.data!;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: activities.map((activity) {
                return buildActivityItemRow(activity, showCard: false);
              }).toList(),
            ),
          );

        } else {
          return Container(
            height: 100,
            child: const Center(
              child: Text("No activity history available."),
            ),
          );
        }
      },
    );
  }
}