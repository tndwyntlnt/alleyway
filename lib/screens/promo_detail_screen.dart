import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/promo.dart';

class PromoDetailScreen extends StatelessWidget {
  final Promo promo;

  const PromoDetailScreen({super.key, required this.promo});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    
    final Color primaryGreenDark = const Color(0xFF1E3932);
    final Color primaryGreenLight = const Color(0xFF3C6E47);
    final Color goldColor = const Color(0xFFC9A96A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- LAYER 1: HERO IMAGE (FULL SCREEN TOP) ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.55,
            child: Hero(
              tag: "promo_${promo.id}",
              child: Container(
                color: Colors.grey[100],
                child: promo.fullImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: promo.fullImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(color: primaryGreenDark),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(Icons.local_offer, size: 80, color: Colors.grey),
              ),
            ),
          ),

          // --- LAYER 2: TOMBOL BACK ---
          Positioned(
            top: 50,
            left: 20,
            child: _buildGlassButton(
              icon: Icons.arrow_back_ios_new,
              onTap: () => Navigator.pop(context),
            ),
          ),

          // --- LAYER 3: KONTEN BOTTOM SHEET ---
          Positioned(
            top: size.height * 0.45, 
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Indikator Drag 
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryGreenLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Special Offer",
                        style: TextStyle(
                          color: primaryGreenLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      promo.title,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: primaryGreenDark,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    Divider(color: Colors.grey[100], thickness: 1),
                    const SizedBox(height: 24),

                    // Deskripsi Header
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Isi Deskripsi
                    Text(
                      promo.description,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Syarat & Ketentuan
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Syarat & Ketentuan",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryGreenDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildBulletPoint("Promo berlaku selama persediaan masih ada."),
                          _buildBulletPoint("Tunjukkan aplikasi ini kepada kasir."),
                          _buildBulletPoint("Tidak dapat digabung dengan promo lain."),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40), // Jarak bawah agar tidak mentok
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildGlassButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF1E3932), size: 20),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}