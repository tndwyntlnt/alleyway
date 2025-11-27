import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/recent_activity.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  late Future<List<RecentActivity>> _futureActivities;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _futureActivities = _apiService.fetchRecentActivity();
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildTransactionRow(RecentActivity activity) {
    final bool isEarned = activity.points > 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isEarned 
                  ? const Color(0xFF8AA682).withOpacity(0.2) 
                  : const Color(0xFFE47A7A).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEarned ? Icons.south_west : Icons.north_east,
              color: isEarned ? const Color(0xFF42532D) : const Color(0xFFE47A7A),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    color: Color(0xFF2E2E2E),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(activity.date),
                  style: const TextStyle(
                    color: Color(0xFF7C7F64),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isEarned ? "+" : ""}${activity.points} pts',
            style: TextStyle(
              color: isEarned ? const Color(0xFF42532D) : const Color(0xFFE47A7A),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Riwayat Aktivitas',
          style: TextStyle(
            color: Color(0xFF2E2E2E), 
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF1E392A)),
      ),
      body: FutureBuilder<List<RecentActivity>>(
        future: _futureActivities,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF42532D))
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Gagal memuat data',
                style: TextStyle(color: Colors.red.shade700),
              )
            );
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada riwayat aktivitas.'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return _buildTransactionRow(snapshot.data![index]);
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}