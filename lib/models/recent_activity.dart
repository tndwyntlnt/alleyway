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
        // Format: 12 Nov 2025
        return DateFormat('d MMM yyyy').format(dateTime);
      } catch (e) {
        return dateString; // Kembalikan string asli jika format gagal
      }
    }

    return RecentActivity(
      // Key ini HARUS SAMA dengan alias 'as' di query PHP
      title: json['description'] ?? 'No Description',
      points: json['points'] ?? 0,
      date: formattedDate(json['created_at'] ?? ''),
    );
  }
}