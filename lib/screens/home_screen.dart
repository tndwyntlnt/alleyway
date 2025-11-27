import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_profile.dart';
import '../widgets/member_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/special_offers_list.dart';
import '../widgets/recent_activity_list.dart';
// Hapus duplikat import api_service
import 'login_screen.dart';
import 'input_kode.dart';
import 'profile_screen.dart'; // TAMBAHAN: Import halaman profil
import 'input_kode.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  late Future<UserProfile> _userProfileFuture;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _userProfileFuture = apiService.fetchUserProfile();
  }

  void _onItemTapped(int index) {
    // PERBAIKAN: Logika Navigasi
    if (index == 4) {
      // Index 4 adalah Profile
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
      return; // Jangan ubah _selectedIndex agar tetap di home saat kembali
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _backToHome() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF1E392A);
    final Color backgroundColor = Color(0xFFF4F6F5);

    return Scaffold(
      backgroundColor: primaryColor,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Redeem',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.numbers), label: 'Input'),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'Promo',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
      // body: FutureBuilder<UserProfile>(
      //   future: _userProfileFuture,
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return Center(
      //           child: CircularProgressIndicator(color: Colors.white));
      //     } else if (snapshot.hasError) {
      //       return Center(
      //           child: Text('Error: ${snapshot.error}',
      //               style: TextStyle(color: Colors.white)));
      //     } else if (snapshot.hasData) {
      //       final user = snapshot.data!;
      //       return _buildHomeContent(user, backgroundColor);
      //     } else {
      //       return Center(
      //           child: Text('No data found',
      //               style: TextStyle(color: Colors.white)));
      //     }
      //   },
      // ),

      body: _selectedIndex == 2
          ? InputCodeScreen(onBack: _backToHome)
          : FutureBuilder<UserProfile>(
              future: _userProfileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(color: Colors.white));
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.white)));
                } else if (snapshot.hasData) {
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

  Widget _buildHomeContent(UserProfile user, Color backgroundColor) {
    return ListView(
      children: [
        _buildHeader(user),
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuickActions(),
              SizedBox(height: 24),
              _buildSectionHeader(context, "Special Offers"),
              SpecialOffersList(),
              SizedBox(height: 24),
              _buildSectionHeader(context, "Recent Activity"),
              RecentActivityList(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(UserProfile user) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
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
                  final apiService = ApiService();
                  await apiService.logout();

                  if (!mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (Route<dynamic> route) => false,
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
          MemberCard(
            name: user.name,
            memberId: user.memberId,
            points: user.points,
            status: user.memberStatus,
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

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
