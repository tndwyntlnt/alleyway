import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E392A);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F5),
      appBar: AppBar(
        title: const Text(
          "Help & Support",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Frequently Asked Questions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E2E2E),
              ),
            ),
            const SizedBox(height: 16),

            // Daftar FAQ
            _buildFAQItem(
              "Bagaimana cara menukarkan poin?",
              "Anda dapat menukarkan poin di halaman 'Rewards'. Pilih voucher yang Anda inginkan dan klik tombol 'Redeem'.",
            ),
            _buildFAQItem(
              "Apakah poin saya bisa hangus?",
              "Poin akan hangus jika tidak ada aktivitas transaksi selama 12 bulan berturut-turut.",
            ),
            _buildFAQItem(
              "Bagaimana cara mengubah password?",
              "Masuk ke menu Profile > Privacy & Security > Change Password.",
            ),
            _buildFAQItem(
              "Saya lupa password, apa yang harus saya lakukan?",
              "Gunakan fitur 'Forgot Password' di halaman Login untuk mereset password Anda melalui email.",
            ),

            const SizedBox(height: 30),

            const Text(
              "Still need help?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E2E2E),
              ),
            ),
            const SizedBox(height: 16),

            // Contact Us Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildContactItem(
                    Icons.email_outlined,
                    "Email Support",
                    "support@alleyway.com",
                    primaryColor,
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildContactItem(
                    Icons.phone_outlined,
                    "Call Center",
                    "+62 812 3456 7890",
                    primaryColor,
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildContactItem(
                    Icons.chat_bubble_outline,
                    "Live Chat",
                    "Available 09:00 - 17:00",
                    primaryColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Terms link
            Center(
              child: TextButton(
                onPressed: () {
                  // Navigasi ke Terms of Service jika ada
                },
                child: Text(
                  "Terms of Service & Privacy Policy",
                  style: TextStyle(
                    color: Colors.grey[600],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E2E2E),
              fontSize: 14,
            ),
          ),
          iconColor: const Color(0xFF1E392A),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: const TextStyle(
                  color: Color(0xFF555555),
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
      onTap: () {
        // Implementasi aksi kontak (buka email/telepon)
      },
    );
  }
}
