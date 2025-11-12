import 'package:intl/intl.dart';

class RecentActivity {
  final String title;
  final String date;
  final int points;

  RecentActivity({
    required this.title,
    required this.date,
    required this.points,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    // Fungsi untuk memformat tanggal
    String formattedDate(String dateString) {
      try {
        DateTime dateTime = DateTime.parse(dateString);
        return DateFormat('d MMM yyyy').format(dateTime);
      } catch (e) {
        return dateString;
      }
    }

    return RecentActivity(
      title: json['description'] ?? 'No Description',
      points: json['points'] ?? 0,
      date: formattedDate(json['created_at'] ?? ''),
    );
  }
}