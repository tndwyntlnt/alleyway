import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transactionHistory.dart'; 

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  TransactionDetailScreen({required this.transaction});

  // Format Mata Uang Rupiah
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  // Widget untuk menampilkan baris detail
  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- INFO TRANSAKSI UTAMA ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rincian Pembelian',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
                    ),
                    const Divider(),
                    _buildDetailRow('Tanggal & Waktu', transaction.date),
                    _buildDetailRow('ID Transaksi', transaction.id),
                    
                    const Divider(height: 30),
                    
                    // --- TOTAL PEMBAYARAN ---
                    _buildDetailRow(
                      'Total Pembayaran',
                      currencyFormatter.format(transaction.total),
                      isBold: true,
                      color: Colors.brown,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // --- INFO POIN ---
            Card(
              elevation: 4,
              color: Colors.green[50], 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.green.shade200)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      'Poin yang Diperoleh',
                      '+${transaction.pointsEarned} Poin',
                      isBold: true,
                      color: Colors.green.shade800,
                    ),
                    const Divider(),
                    const Text(
                      '*Poin akan terakumulasi ke saldo Anda dan siap ditukar dengan hadiah.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            
            ElevatedButton.icon(
              onPressed: () {
                // untuk membagikan/mencetak struk 
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fungsi cetak/bagikan struk diklik')),
                );
              },
              icon: const Icon(Icons.share),
              label: const Text('Bagikan Struk'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown.shade200,
                foregroundColor: Colors.brown.shade800,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}