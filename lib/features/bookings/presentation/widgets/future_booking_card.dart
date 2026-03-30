import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';

class FutureBookingCard extends StatelessWidget {
  final String title;
  final String time;
  final String status;
  final String icon;   

  const FutureBookingCard({
    super.key,
    required this.title,
    required this.time,
    required this.status,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        children: [

          /// ICON BOX
          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              icon, 
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(width: 12),

          /// TEXT SECTION
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: AppFonts.poppinsSemiBold(
                    fontSize: 17
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  time,
                  style: AppFonts.poppinsRegular(
                    color: AppColors.primaryBlack40,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [

                    Text(
                      "Reschedule",
                      style: AppFonts.poppinsRegular(
                        color: AppColors.primaryColor,
                        fontSize: 12.5,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Text(
                      "Cancel",
                      style: AppFonts.poppinsRegular(
                        color: AppTheme.secondaryText,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          /// STATUS
          Text(
            status,
            style: AppFonts.poppinsSemiBold(
              fontSize: 11,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}