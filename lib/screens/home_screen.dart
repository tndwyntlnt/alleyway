import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_profile.dart';
import '../widgets/member_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/special_offers_list.dart';
import '../widgets/recent_activity_list.dart';
import 'activity_history_screen.dart';
import 'promo_screen.dart';
import 'input_kode.dart';
import 'profile_screen.dart';
import 'redeem_screen.dart';
import 'notification_screen.dart';

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

  Future<void> _refreshData() async {
    setState(() {
      _userProfileFuture = apiService.fetchUserProfile();
    });

    await Future.delayed(const Duration(seconds: 1));
  }

  void _onItemTapped(int index) async {
    if (index == 1) {
      bool? result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RedeemScreen()),
      );

      if (result == true) {
        _refreshData();
      }
      return;
    }

    if (index == 3) {
      bool? result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PromoScreen()),
      );

      if (result == true) {
        _refreshData();
      }
      return;
    }

    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _backToHome() {
    setState(() {
      _selectedIndex = 0;
    });
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF1E392A);
    final Color backgroundColor = const Color(0xFFF4F6F5);

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
      body: _selectedIndex == 2
          ? InputCodeScreen(onBack: _backToHome)
          : RefreshIndicator(
              // tarik buat refresh
              onRefresh: _refreshData,
              color: primaryColor,
              backgroundColor: Colors.white,
              child: FutureBuilder<UserProfile>(
                future: _userProfileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  } else if (snapshot.hasError) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: Center(
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (snapshot.hasData) {
                    final user = snapshot.data!;
                    return _buildHomeContent(user, backgroundColor);
                  } else {
                    return const Center(
                      child: Text(
                        'No data found',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                },
              ),
            ),
    );
  }

  Widget _buildHomeContent(UserProfile user, Color backgroundColor) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _buildHeader(user),
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuickActions(
                onCodeRedeemed: () {
                  _refreshData();
                },
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, "Special Offers", false),
              SpecialOffersList(
                onRedeemSuccess: () {
                  _refreshData();
                },
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, "Recent Activity", true),
              RecentActivityList(),
              const SizedBox(height: 20),
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
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Good morning,',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          Text(
            user.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          MemberCard(
            name: user.name,
            memberId: user.memberId,
            points: user.points,
            status: user.memberStatus,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    bool isActivitySection,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          TextButton(
            onPressed: () async {
              if (isActivitySection) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ActivityHistoryScreen(),
                  ),
                );
              } else {
                bool? result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PromoScreen()),
                );

                if (result == true) {
                  _refreshData();
                }
              }
            },
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
