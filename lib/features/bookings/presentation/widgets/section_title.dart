import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const SectionTitle({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        Icon(
          icon,
          size: 18,
          color: const Color(0xFFC9A14A),
        ),

        const SizedBox(width: 6),

        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 1.2,
            color: Color(0xFFC9A14A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}