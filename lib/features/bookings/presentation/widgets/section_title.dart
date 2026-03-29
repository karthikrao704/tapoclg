import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';

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
          color: AppColors.primaryColor,
        ),

        const SizedBox(width: 6),

        Text(
          title,
          style: AppFonts.poppinsSemiBold(
            fontSize: 12,
            letterSpacing: 1.2,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }
}