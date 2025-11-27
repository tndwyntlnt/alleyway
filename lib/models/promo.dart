import 'package:intl/intl.dart';

class Promo {
  final String id;
  final String title;
  final String description;
  final String promoCode;
  final String validityPeriod; 
  final bool isActive;

  Promo({
    required this.id,
    required this.title,
    required this.description,
    required this.promoCode,
    required this.validityPeriod,
    required this.isActive,
  });

  factory Promo.fromJson(Map<String, dynamic> json) {
    // Fungsi untuk memformat tanggal kedaluwarsa
    String formatExpiryDate(String dateString) {
      try {
        DateTime dateTime = DateTime.parse(dateString);
        return 'Berlaku hingga ${DateFormat('d MMMM yyyy').format(dateTime)}'; 
      } catch (e) {
        return 'Tanggal kedaluwarsa tidak diketahui';
      }
    }
    
    return Promo(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Promo Tanpa Judul',
      description: json['description'] as String? ?? 'Detail promo tidak tersedia.',
      promoCode: json['code'] as String? ?? 'TIDAK_ADA_KODE',
      validityPeriod: formatExpiryDate(json['expiry_date'] as String? ?? ''),
      isActive: json['is_active'] as bool? ?? false, // menandakan promo masih aktif atau tidak
    );
  }
}