import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_profile.dart';
// Import widget-widget yang akan kita buat
import '../widgets/member_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/special_offers_list.dart';
import '../widgets/recent_activity_list.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Panggil ApiService
  final ApiService apiService = ApiService();
  // Future untuk menyimpan data profile
  late Future<UserProfile> _userProfileFuture;
  int _selectedIndex = 0; // Untuk BottomNavigationBar

  @override
  void initState() {
    super.initState();
    // Ambil data profile saat halaman pertama kali dibuka
    _userProfileFuture = apiService.fetchUserProfile();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Tambahkan navigasi di sini nanti
    // if (index == 1) { Navigator.push(context, ...); }
  }

  @override
  Widget build(BuildContext context) {
    // Warna utama dari desain
    final Color primaryColor = Color(0xFF1E392A); // Contoh warna hijau tua
    final Color backgroundColor = Color(0xFFF4F6F5); // Contoh warna abu-abu muda

    return Scaffold(
      backgroundColor: primaryColor, // Warna background atas (hijau)
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Redeem'),
          BottomNavigationBarItem(icon: Icon(Icons.numbers), label: 'Input'),
          BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: 'Promo'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor, // Warna ikon yang aktif
        unselectedItemColor: Colors.grey, // Warna ikon yang tidak aktif
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Agar 5 item muat
      ),
      body: FutureBuilder<UserProfile>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Tampilkan loading di tengah
            return Center(
                child: CircularProgressIndicator(color: Colors.white));
          } else if (snapshot.hasError) {
            // Tampilkan error jika gagal
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.white)));
          } else if (snapshot.hasData) {
            // Jika data sukses didapat, build UI-nya
            final user = snapshot.data!;
            return _buildHomeContent(user, backgroundColor);
          } else {
            return Center(
                child: Text('No data found',
                    style: TextStyle(color: Colors.white)));
          }
        },
      ),
    );
  }

  // Widget ini berisi konten utama halaman
  Widget _buildHomeContent(UserProfile user, Color backgroundColor) {
    return ListView(
      children: [
        // --- Bagian Header Hijau ---
        _buildHeader(user),

        // --- Bagian Konten Putih ---
        Container(
          decoration: BoxDecoration(
            color: backgroundColor, // Warna background konten (abu-abu muda)
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuickActions(), // Widget untuk "Quick Actions"
              SizedBox(height: 24),
              _buildSectionHeader(context, "Special Offers"),
              SpecialOffersList(), // Widget untuk list horizontal "Special Offers"
              SizedBox(height: 24),
              _buildSectionHeader(context, "Recent Activity"),
              RecentActivityList(), // Widget untuk list "Recent Activity"
              SizedBox(height: 20), // Spasi di bawah
            ],
          ),
        ),
      ],
    );
  }

  // Widget untuk "Good morning" dan Kartu Member
  Widget _buildHeader(UserProfile user) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20), // Untuk status bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Good morning,',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              // Icon(Icons.notifications, color: Colors.white),
              IconButton(
                icon: Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  // Panggil ApiService
                  final apiService = ApiService();
                  await apiService.logout();
                  
                  if (!mounted) return;
                  // Navigasi kembali ke Login dan hapus semua halaman sebelumnya
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false, // Hapus semua rute
                  );
                },
              ),
            ],
          ),
          Text(
            user.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          // Ini adalah kartu member
          MemberCard(
            name: user.name,
            memberId: user.memberId,
            points: user.points,
            status: user.memberStatus,
          ),
          SizedBox(height: 10), // Jarak antara kartu dan konten putih
        ],
      ),
    );
  }

  // Widget untuk judul section ("Special Offers", "Recent Activity")
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              "View All",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}