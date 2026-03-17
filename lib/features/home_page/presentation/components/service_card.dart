// lib/presentation/widgets/service_card.dart

import 'package:flutter/material.dart';

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
    // Cache the theme and text scaler for cleaner code
    final theme = Theme.of(context);
    final textScaler = MediaQuery.textScalerOf(context);

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
                    color: theme.colorScheme.onPrimary.withAlpha(200),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tagLabel,
                    // Fallback to text theme so scaling applies naturally
                    style:
                        theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ) ??
                        TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
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
                Text(serviceName, style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                Row(
                  // Align to start in case the duration text wraps to two lines
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.access_time,
                      // Scale the icon proportionally to the system font size
                      size: textScaler.scale(16),
                      color: theme.colorScheme.onSurface,
                    ),
                    const SizedBox(width: 4),
                    // Expanded prevents horizontal overflow by pushing long text to the next line
                    Expanded(
                      child: Text(duration, style: theme.textTheme.bodySmall),
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
