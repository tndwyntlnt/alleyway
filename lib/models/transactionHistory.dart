import 'package:intl/intl.dart';

class Transaction {
  final String id;
  final String date;
  final double total;
  final int pointsEarned;

  Transaction({
    required this.id,
    required this.date,
    required this.total,
    required this.pointsEarned,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    // Fungsi untuk memformat tanggal
    String formattedDate(String dateString) {
      try {
        DateTime dateTime = DateTime.parse(dateString);
        return DateFormat('d MMM yyyy').format(dateTime);
      } catch (e) {
        return dateString;
      }
    }

    return Transaction(
      id: json['id'] as String? ?? '',
      date: formattedDate(json['created_at'] ?? ''),
      total: json['total']?.toDouble() ?? 0.0, 
      pointsEarned: json['pointsEarned'] as int? ?? 0,
    );
  }
}
