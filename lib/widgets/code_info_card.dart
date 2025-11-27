import 'package:flutter/material.dart';

class CodeInfoCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final bool isTip;

  const CodeInfoCard({
    Key? key, 
    required this.message,
    this.icon = Icons.auto_awesome,
    this.isTip = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isTip) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
             const Text("💡 ", style: TextStyle(fontSize: 16)),
             Expanded(
               child: Text(
                message,
                style: const TextStyle(
                  color: Color(0xFF9AA99A),
                  fontSize: 12,
                ),
                       ),
             ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF8FB996).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 32,
            color: const Color(0xFF3C6E47),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF9AA99A),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}