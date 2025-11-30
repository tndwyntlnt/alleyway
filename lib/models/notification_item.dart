class NotificationItem {
  final String id;
  final String type;
  final String status;
  final String title;
  final String message;
  final String date;
  final String amount;

  NotificationItem({
    required this.id,
    required this.type,
    required this.status,
    required this.title,
    required this.message,
    required this.date,
    required this.amount,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString() ?? '0',
      type: json['type'] ?? 'earn',
      status: json['status'] ?? 'claimed',
      title: json['title'] ?? 'Info',
      message: json['message'] ?? '-',
      date: json['date'] ?? DateTime.now().toIso8601String(),
      amount: json['amount']?.toString() ?? '0',
    );
  }
}