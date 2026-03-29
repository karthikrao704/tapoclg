// lib/presentation/widgets/service_card.dart

import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';

class ServiceCard extends StatelessWidget {
  final String imagePath;
  final String tagLabel;
  final String serviceName;
  final String duration;
  final VoidCallback? onTap;

  const ServiceCard({
    super.key,
    required this.imagePath,
    required this.tagLabel,
    required this.serviceName,
    required this.duration,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Removed the fixed height SizedBox to allow dynamic vertical growth
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Card hugs its content vertically
        children: [
          // 1. Image Section with a Stack for the tag
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                // AspectRatio ensures the image scales gracefully on wider screens
                child: AspectRatio(
                  aspectRatio:
                      1.1, // Adjust this ratio to match your specific design needs
                  child: Image.asset(
                    imagePath,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // The dynamic tag on the top right
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.tagBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tagLabel,
                    style: AppFonts.poppinsSemiBold(
                      fontSize: 12,
                      color: AppTheme.wellnessTipText,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 2. Text Section in a Column below the image
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceName,
                  style: AppFonts.poppinsSemiBold(
                    fontSize: 16,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  // Align to start in case the duration text wraps to two lines
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.access_time,
                      // Scale the icon proportionally to the system font size
                      size: 16,
                      color: AppColors.primaryBlack40,
                    ),
                    const SizedBox(width: 4),
                    // Expanded prevents horizontal overflow by pushing long text to the next line
                    Expanded(
                      child: Text(
                        duration,
                        style: AppFonts.poppinsRegular(
                          fontSize: 13,
                          color: AppColors.primaryBlack40,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
