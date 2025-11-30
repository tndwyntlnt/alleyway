import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/promo.dart';
import '../services/api_service.dart';
import 'promo_detail_screen.dart';

class PromoScreen extends StatefulWidget {
  const PromoScreen({super.key});

  @override
  State<PromoScreen> createState() => _PromoScreenState();
}

class _PromoScreenState extends State<PromoScreen> {
  final Color primaryGreenDark = const Color(0xFF1E3932);
  final Color primaryGreenLight = const Color(0xFF3C6E47);
  final Color secondaryTextGreen = const Color(0xFF6B9071);
  final Color bgColor = const Color(0xFFF7F8F5);

  final ApiService _apiService = ApiService();

  List<Promo> _allPromos = [];
  List<Promo> _filteredPromos = [];
  bool _isLoading = true;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPromos();
  }

  Future<void> _loadPromos() async {
    try {
      final promos = await _apiService.fetchPromos();
      setState(() {
        _allPromos = promos;
        _filteredPromos = promos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error loading promos: $e");
    }
  }

  void _filterPromos(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredPromos = _allPromos;
      } else {
        _filteredPromos = _allPromos.where((promo) {
          return promo.title.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        color: primaryGreenDark,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 16),
              const Text(
                'Special Offers',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _searchController,
            onChanged: _filterPromos,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Cari promo spesial...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: primaryGreenLight),
                  )
                : _filteredPromos.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? "Gagal memuat data."
                          : "Promo tidak ditemukan.",
                      style: TextStyle(color: primaryGreenDark),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.70,
                        ),
                    itemCount: _filteredPromos.length,
                    itemBuilder: (context, index) {
                      final promo = _filteredPromos[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PromoDetailScreen(promo: promo),
                            ),
                          );
                        },
                        child: _buildPromoGridCard(context, promo),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoGridCard(BuildContext context, Promo promo) {
    return Container(
      margin: const EdgeInsets.all(5),
      
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 1, 
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: promo.fullImageUrl ?? "",
              height: 120, 
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[200]),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
            
            // KONTEN TEKS
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // JUDUL PROMO
                    Text(
                      promo.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryGreenDark,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    
                    // DESKRIPSI
                    Expanded(
                      child: Text(
                        promo.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // LABEL 'Special Offer'
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryGreenLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Special Offer",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: primaryGreenLight,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
