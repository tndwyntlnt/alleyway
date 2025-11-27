import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_profile.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart'; // Pastikan file ini ada
import 'notification_screen.dart'; // Pastikan file ini ada
import 'help_support_screen.dart'; // Pastikan file ini ada
import 'privacy_security_screen.dart'; // Pastikan file ini ada

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  UserProfile? _userProfile;
  bool _isLoading = true;

  // Animation Controller
  late AnimationController _animationController;
  final List<Animation<Offset>> _slideAnimations = [];
  final List<Animation<double>> _fadeAnimations = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadProfile();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Membuat animasi berurutan untuk 5 bagian utama
    for (int i = 0; i < 5; i++) {
      double start = i * 0.15;
      double end = start + 0.5;
      if (end > 1.0) end = 1.0;

      _slideAnimations.add(
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(start, end, curve: Curves.easeOutQuart),
          ),
        ),
      );

      _fadeAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        ),
      );
    }

    _animationController.forward();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _apiService.fetchUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat profil: $e')));
      }
    }
  }

  Future<void> _handleLogout() async {
    await _apiService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // WARNA UTAMA (Disamakan dengan Home Screen)
    final Color primaryColor = const Color(0xFF1E392A);

    // Data dummy jika profile belum loaded atau null
    final defaultProfile = UserProfile(
      name: "Loading...",
      email: "-",
      phone: "-",
      birthday: "-",
      memberId: "-",
      points: 0,
      memberStatus: "Bronze",
    );

    final userToShow = _userProfile ?? defaultProfile;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // --- LAYER 1: HEADER SECTION (Curved & Gradient) ---
                  Stack(
                    children: [
                      Container(
                        height: size.height * 0.40, // Tinggi Header
                        decoration: BoxDecoration(
                          color:
                              primaryColor, // Menggunakan warna solid hijau tua
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(40),
                          ),
                        ),
                      ),

                      // Konten Header
                      Positioned.fill(
                        child: SafeArea(
                          child: Column(
                            children: [
                              // Back Button Row
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                              ),

                              // User Info Animation
                              _animatedItem(
                                0,
                                Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.person,
                                          size: 48,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      userToShow.name,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFC9A96A,
                                        ), // Warna Gold/Bronze
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        "${userToShow.memberStatus} Member",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // --- LAYER 2: PROFILE INFO CARD ---
                  Transform.translate(
                    offset: const Offset(0, -40),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _animatedItem(
                            1,
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Personal Information",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E2E2E),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _buildInfoRow(
                                    Icons.email_outlined,
                                    "Email",
                                    userToShow.email,
                                    primaryColor,
                                  ),
                                  _buildDivider(),
                                  _buildInfoRow(
                                    Icons.phone_outlined,
                                    "Phone",
                                    userToShow.phone,
                                    primaryColor,
                                  ),
                                  _buildDivider(),
                                  _buildInfoRow(
                                    Icons.cake_outlined,
                                    "Birthday",
                                    userToShow.birthday,
                                    primaryColor,
                                  ),
                                  const SizedBox(height: 24),

                                  // TOMBOL EDIT PROFILE (Navigasi)
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        // Perubahan di sini: Menunggu hasil dari EditProfileScreen
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditProfileScreen(
                                                  userProfile: userToShow,
                                                ),
                                          ),
                                        );

                                        // Jika result true (berhasil edit), reload profile
                                        if (result == true) {
                                          _loadProfile();
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: primaryColor),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Text(
                                        "Edit Profile",
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // --- LAYER 3: MENU ITEMS ---
                          _animatedItem(
                            2,
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.05),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _buildMenuItem(
                                    Icons.card_giftcard,
                                    "My Rewards",
                                    () {
                                      // TODO: Navigate to Rewards
                                    },
                                    primaryColor,
                                  ),
                                  _buildDivider(indent: 60),
                                  _buildMenuItem(
                                    Icons.notifications_none_rounded,
                                    "Notifications",
                                    () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const NotificationScreen(),
                                        ),
                                      );
                                    },
                                    primaryColor,
                                  ),
                                  _buildDivider(indent: 60),
                                  _buildMenuItem(
                                    Icons.help_outline_rounded,
                                    "Help & Support",
                                    () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const HelpSupportScreen(),
                                        ),
                                      );
                                    },
                                    primaryColor,
                                  ),
                                  _buildDivider(indent: 60),
                                  _buildMenuItem(
                                    Icons.privacy_tip_outlined,
                                    "Privacy & Security",
                                    () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const PrivacySecurityScreen(),
                                        ),
                                      );
                                    },
                                    primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // --- LOGOUT BUTTON ---
                          _animatedItem(
                            3,
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _handleLogout,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFFE47A7A),
                                  ),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.logout_rounded,
                                      color: Color(0xFFE47A7A),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Logout",
                                      style: TextStyle(
                                        color: Color(0xFFE47A7A),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // --- ANIMATION HELPER ---
  Widget _animatedItem(int index, Widget child) {
    int safeIndex = index >= _slideAnimations.length ? 0 : index;
    return FadeTransition(
      opacity: _fadeAnimations[safeIndex],
      child: SlideTransition(
        position: _slideAnimations[safeIndex],
        child: child,
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFF4F6F5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF9AA99A),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 4,
              ), // UPDATED: Jarak antara label dan value
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF2E2E2E),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String label,
    VoidCallback onTap,
    Color color,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F6F5),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF2E2E2E),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF9AA99A),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider({double indent = 0}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
      ), // UPDATED: Tambah padding vertikal
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey[100],
        indent: indent,
      ),
    );
  }
}
