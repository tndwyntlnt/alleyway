import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart'; // Pastikan import ini sesuai dengan file projectmu

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Warna tema (Diambil dari sample logo/gambar)
  final Color _accentGold = const Color(0xFFC9A96A);
  final Color _textWhite = Colors.white;
  // Warna hijau muda logo untuk tint (opsional, jika ingin logo berwarna putih/emas)
  final Color _logoColor = const Color(0xFFA8C5A5);

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Premium Coffee\nExperience",
      "desc":
          "Rasakan kenikmatan biji kopi pilihan yang diseduh sempurna untuk menemani harimu.",
    },
    {
      "title": "Brewed with\nPassion",
      "desc":
          "Setiap cangkir diracik oleh barista profesional kami untuk memberikan rasa yang otentik.",
    },
    {
      "title": "Order & Earn\nExclusive Rewards",
      "desc":
          "Pesan tanpa antri, kumpulkan poin di setiap transaksi, dan tukarkan dengan promo menarik.",
    },
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // LAYER 1: BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg', // Pastikan background ada
              fit: BoxFit.cover,
            ),
          ),

          // LAYER 2: DARK OVERLAY
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(
                      0xFF1E392A,
                    ).withOpacity(0.6), // Hijau gelap transparan
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),

          // LAYER 3: CONTENT
          SafeArea(
            child: Column(
              children: [
                // --- BAGIAN LOGO YANG DIUBAH ---
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Baris 1: Since - Logo - 2023
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Since",
                            style: TextStyle(
                              color: _textWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),

                          // Gambar Logo di tengah
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            child: Image.asset(
                              'assets/images/logo.png', // Ganti path sesuai lokasi logo kamu
                              height: 40, // Ukuran logo disesuaikan
                            ),
                          ),

                          Text(
                            "2023",
                            style: TextStyle(
                              color: _textWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Baris 2: Judul Besar "Alleyway Muse"
                      Text(
                        "Alleyway Muse",
                        style: TextStyle(
                          color: _textWhite,
                          fontSize: 36, // Ukuran font besar
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Serif',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // --- Carousel Content ---
                SizedBox(
                  height: 300,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (value) =>
                        setState(() => _currentPage = value),
                    itemCount: _onboardingData.length,
                    itemBuilder: (context, index) => _buildPageContent(
                      title: _onboardingData[index]["title"]!,
                      desc: _onboardingData[index]["desc"]!,
                    ),
                  ),
                ),

                // --- Footer (Tombol & Indikator) ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    children: [
                      // Tombol Sign In / Next
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage == _onboardingData.length - 1) {
                              _finishOnboarding();
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF8AA682,
                            ), // Hijau Sage
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                30,
                              ), // Lebih bulat
                            ),
                          ),
                          child: Text(
                            _currentPage == _onboardingData.length - 1
                                ? "Get Started"
                                : "Next",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Indikator Titik
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _onboardingData.length,
                          (index) => _buildDot(index),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Sign Up Text
                      GestureDetector(
                        onTap: _finishOnboarding,
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                              color: _textWhite.withOpacity(0.7),
                            ),
                            children: [
                              TextSpan(
                                text: "Sign Up",
                                style: TextStyle(
                                  color: _textWhite,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent({required String title, required String desc}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 40,
              height: 1.1,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            desc,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.85),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? _accentGold
            : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
