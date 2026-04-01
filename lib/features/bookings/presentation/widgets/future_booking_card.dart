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
    // 1. Establish breakpoint for local component scaling
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.height < 650 || size.width < 360;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        // 2. Align to top so the icon stays anchored if text wraps to multiple lines
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ICON BOX
          Container(
            // 3. Dynamically shrink the icon box on tight screens
            width: isSmallScreen ? 56 : 72,
            height: isSmallScreen ? 56 : 72,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(icon, fit: BoxFit.contain),
          ),

          const SizedBox(width: 12),

          /// TEXT SECTION
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  // 4. Safely bound the title
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.poppinsSemiBold(
                    fontSize: isSmallScreen ? 15 : 17,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.poppinsRegular(
                    color: AppColors.primaryBlack40,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
                const SizedBox(height: 6),

                /// ACTIONS
                // 5. Replaced Row with Wrap!
                Wrap(
                  spacing: 12, // Horizontal spacing between items
                  runSpacing:
                      4, // Vertical spacing if "Cancel" is pushed to the next line
                  children: [
                    GestureDetector(
                      onTap: () {},
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        "Reschedule",
                        style: AppFonts.poppinsRegular(
                          color: AppColors.primaryColor,
                          fontSize: isSmallScreen ? 11.5 : 12.5,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        "Cancel",
                        style: AppFonts.poppinsRegular(
                          color: AppTheme.secondaryText,
                          fontSize: isSmallScreen ? 11.5 : 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          /// STATUS
          Text(
            status,
            style: AppFonts.poppinsSemiBold(
              fontSize: isSmallScreen ? 10 : 11,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
