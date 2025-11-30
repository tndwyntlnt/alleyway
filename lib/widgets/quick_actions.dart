import 'package:flutter/material.dart';
import '../screens/redeem_screen.dart';
import '../screens/promo_screen.dart';
import '../screens/input_kode.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback? onCodeRedeemed;

  const QuickActions({super.key, this.onCodeRedeemed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Quick Actions",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionItem(
                context,
                Icons.numbers,
                "Input Code",
                const Color(0xFF1E392A),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InputCodeScreen(
                        onBack: () {
                          Navigator.pop(context);
                          
                          if (onCodeRedeemed != null) {
                            onCodeRedeemed!();
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
              
              _buildActionItem(
                context,
                Icons.card_giftcard,
                "Redeem",
                const Color(0xFF1E392A),
                () async {
                  final bool? result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RedeemScreen()),
                  );
                  
                  if (result == true && onCodeRedeemed != null) {
                    onCodeRedeemed!();
                  }
                },
              ),
              
              _buildActionItem(
                context,
                Icons.local_offer,
                "Promos",
                const Color(0xFFC7A158),
                () async {
                  final bool? result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PromoScreen()),
                  );
                  
                  if (result == true && onCodeRedeemed != null) {
                    onCodeRedeemed!();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String label, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}