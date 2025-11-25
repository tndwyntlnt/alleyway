import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; // Untuk fungsi menyalin ke clipboard
import '../models/promo.dart'; 

class PromoScreen extends StatefulWidget {
  final String userAuthToken;

  const PromoScreen({Key? key, required this.userAuthToken}) : super(key: key);

  @override
  State<PromoScreen> createState() => _PromoScreenState();
}

class _PromoScreenState extends State<PromoScreen> {
  
  late Future<List<Promo>> _promosFuture;
  
  // URL endpoint API untuk mendapatkan semua promo
  final String _apiUrl = 'https://api.caffinityapp.com/v1/promos';// nanti diubah 

  @override
  void initState() {
    super.initState();
    _promosFuture = _fetchPromos();
  }

  /// Mengambil daftar promo dari API
  Future<List<Promo>> _fetchPromos() async {
    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.userAuthToken}', 
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> promoListJson = jsonResponse['data']; 
        
        return promoListJson
            .map((json) => Promo.fromJson(json))
            .where((promo) => promo.isActive) 
            .toList();
      } else {
        throw Exception('Gagal memuat daftar promo. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi: $e');
    }
  }

  // Fungsi untuk menyalin kode promo ke clipboard
  void _copyPromoCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kode "$code" berhasil disalin!'),
        backgroundColor: Colors.green,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Promo & Diskon 🏷️'),
        backgroundColor: Colors.brown,
      ),
      body: FutureBuilder<List<Promo>>(
        future: _promosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.brown));
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
              ),
            );
          }

          if (snapshot.hasData) {
            final promos = snapshot.data!;
            if (promos.isEmpty) {
              return const Center(
                child: Text('Saat ini belum ada promo aktif.'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: promos.length,
              itemBuilder: (context, index) {
                return _buildPromoCard(context, promos[index]);
              },
            );
          }
          
          return const Center(child: Text('Memuat Data...'));
        },
      ),
    );
  }
  
  // Widget untuk menampilkan setiap kartu promo
  Widget _buildPromoCard(BuildContext context, Promo promo) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Judul Promo ---
            Text(
              promo.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 8),

            // --- Deskripsi ---
            Text(
              promo.description,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),

            // --- Periode Berlaku ---
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.green[700]),
                const SizedBox(width: 5),
                Text(
                  promo.validityPeriod,
                  style: TextStyle(fontSize: 12, color: Colors.green[700], fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Divider(height: 25),

            // --- Kode Promo & Tombol Salin ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gunakan Kode:', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.brown.shade100,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.brown.shade200),
                      ),
                      child: Text(
                        promo.promoCode,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: Colors.brown,
                        ),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _copyPromoCode(context, promo.promoCode),
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Salin Kode'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}