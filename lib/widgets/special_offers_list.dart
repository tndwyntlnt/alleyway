import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../services/api_service.dart';
import '../models/promo.dart';
import '../screens/promo_detail_screen.dart';

class SpecialOffersList extends StatefulWidget {
  final VoidCallback? onRedeemSuccess;

  const SpecialOffersList({Key? key, this.onRedeemSuccess}) : super(key: key);

  @override
  State<SpecialOffersList> createState() => _SpecialOffersListState();
}

class _SpecialOffersListState extends State<SpecialOffersList> {
  final ApiService _apiService = ApiService();
  late Future<List<Promo>> _promosFuture;

  @override
  void initState() {
    super.initState();
    _promosFuture = _apiService.fetchPromos();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Promo>>(
      future: _promosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return SizedBox(
            height: 200,
            child: Center(child: Text("Error: ${snapshot.error}")),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final promos = snapshot.data!;

        return CarouselSlider.builder(
          itemCount: promos.length,
          itemBuilder: (context, index, realIndex) {
            final promo = promos[index];
            
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PromoDetailScreen(promo: promo),
                  ),
                );
              },
              child: _buildPromoCard(promo),
            );
          },
          options: CarouselOptions(
            height: 240, 
            autoPlay: true, 
            autoPlayInterval: const Duration(seconds: 4), 
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            pauseAutoPlayOnTouch: true, 
            enlargeCenterPage: true, 
            viewportFraction: 0.85,
            aspectRatio: 16/9,
            enableInfiniteScroll: true,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 150,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.local_offer_outlined, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text("No special offers right now", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPromoCard(Promo promo) {
    return Container(
      width: double.infinity, 
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade100,
                child: Hero(
                  tag: "promo_${promo.id}_home",
                  child: (promo.fullImageUrl != null)
                      ? Image.network(
                          promo.fullImageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, err, stack) =>
                              const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                          loadingBuilder: (ctx, child, progress) {
                            if (progress == null) return child;
                            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                          },
                        )
                      : const Center(child: Icon(Icons.image, color: Colors.grey)),
                ),
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    promo.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1E392A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    promo.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}