import 'package:intl/intl.dart';

class RecentActivity {
  final String id;
  final String title;
  final String date;
  final String amount;
  final String type;

  RecentActivity({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    String formattedDate(String dateString) {
      if (dateString.isEmpty || dateString == '-') return '-';
      try {
        DateTime dateTime = DateTime.parse(dateString);
        return DateFormat('d MMM yyyy').format(dateTime);
      } catch (e) {
        return dateString;
      }
    }

    return RecentActivity(
      id: json['id']?.toString() ?? '0',
      title: json['title'] ?? 'No Description',
      date: formattedDate(json['date'] ?? ''),
      amount: json['amount']?.toString() ?? '0',
      type: json['type'] ?? 'earn',
    );
  }
}