import 'package:flutter/material.dart';
import '../models/reward.dart'; // Import model baru kita
import '../services/api_service.dart'; // Import ApiService
import 'package:cached_network_image/cached_network_image.dart';

class SpecialOffersList extends StatelessWidget {
  SpecialOffersList({Key? key}) : super(key: key);

  // Buat instance dari ApiService
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Reward>>(
      // Panggil method fetchRewards()
      future: apiService.fetchRewards(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Tampilkan loading indicator di tengah
          return Container(
            height: 220,
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
          );
        } else if (snapshot.hasError) {
          // Tampilkan pesan error
          return Container(
            height: 220,
            child: Center(
              child: Text("Error: ${snapshot.error}"),
            ),
          );
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          // Jika data ada dan tidak kosong, build list-nya
          final List<Reward> rewards = snapshot.data!;
          return Container(
            height: 220, // Tentukan tinggi untuk list horizontal
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: rewards.length,
              itemBuilder: (context, index) {
                final reward = rewards[index];
                // Tambahkan padding untuk item pertama dan terakhir
                final double leftPadding = (index == 0) ? 20.0 : 8.0;
                final double rightPadding =
                    (index == rewards.length - 1) ? 20.0 : 8.0;

                return Padding(
                  padding: EdgeInsets.only(left: leftPadding, right: rightPadding),
                  child: _buildRewardCard(reward), // Ganti ke reward card
                );
              },
            ),
          );
        } else {
          // Tampilkan jika tidak ada data
          return Container(
            height: 220,
            child: Center(
              child: Text("Tidak ada hadiah tersedia saat ini."),
            ),
          );
        }
      },
    );
  }

  // Kita ubah _buildOfferCard menjadi _buildRewardCard
  Widget _buildRewardCard(Reward reward) {
    print("Mencoba memuat URL gambar: ${reward.imageUrl}");
    return Container(
      width: 280, // Lebar kartu
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias, // Agar gambar terpotong rapi
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: reward.imageUrl, // Gunakan gambar dari API
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 150,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 150,
                    child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  ),
                ),
                // Tampilkan Poin yang Dibutuhkan
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${reward.pointsRequired} Poin", // Tampilkan poin
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                reward.name, // Tampilkan nama hadiah dari API
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}