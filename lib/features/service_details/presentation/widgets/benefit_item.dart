import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';

class BenefitItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const BenefitItem({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Icon(
            Icons.check_circle_outline,
            size: 25,
            color: AppColors.primaryColor,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: AppFonts.poppinsSemiBold(
                    color: AppTheme.primaryText,
                    fontSize: 19,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  style: AppFonts.poppinsRegular(
                    fontSize: 15,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}