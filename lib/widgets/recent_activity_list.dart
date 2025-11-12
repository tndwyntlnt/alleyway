import 'package:flutter/material.dart';
import '../models/recent_activity.dart'; // Import model baru
import '../services/api_service.dart'; // Import ApiService

class RecentActivityList extends StatelessWidget {
  RecentActivityList({Key? key}) : super(key: key);

  // Buat instance dari ApiService
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RecentActivity>>(
      future: apiService.fetchRecentActivity(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Tampilkan loading kecil
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
          
          // Gunakan Column karena ini bagian dari ListView utama
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: activities.map((activity) {
                return _buildActivityItem(activity);
              }).toList(),
            ),
          );

        } else {
          return Container(
            height: 100,
            child: Center(
              child: Text("Belum ada aktivitas terbaru."),
            ),
          );
        }
      },
    );
  }

  // Widget ini sama seperti di versi mock, tapi sekarang menerima data asli
  Widget _buildActivityItem(RecentActivity activity) {
    bool isCredit = activity.points > 0;
    Color pointColor = isCredit ? Colors.green[700]! : Colors.red;
    IconData icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;
    Color iconColor = isCredit ? Colors.green[700]! : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  activity.date, // Gunakan tanggal yang sudah diformat
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Text(
            "${isCredit ? '+' : ''}${activity.points} pts",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: pointColor,
            ),
          ),
        ],
      ),
    );
  }
}