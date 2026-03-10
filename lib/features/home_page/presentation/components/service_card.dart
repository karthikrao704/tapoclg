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
    // Cache the theme for cleaner code
    final theme = Theme.of(context);

    return SizedBox(
      height: 300, // Fixed height to accommodate image and text
      // Elevation is 0 by the CardTheme, and shape with a border is also handled.
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16), // Match card shape for ripple
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Wrap content vertically
          children: [
            // 1. Image Section with a Stack for the tag
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(16), // Rounded corners for the image
                  ),
                  child: Image.asset(
                    imagePath,
                    width: double.infinity,
                    height: 200, // Fixed height for consistency
                    fit: BoxFit.cover, // Ensures image fills the container
                  ),
                ),
                // The dynamic tag on the top right
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onPrimary.withAlpha(200),
                      borderRadius: BorderRadius.circular(10), // Pill shape
                    ),
                    child: Text(
                      tagLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        // Golden/Tan color from the custom theme action primaryAction
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
                  Text(
                    serviceName,
                    // Inherits font size 16, bold, primaryText color
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_filled_outlined,
                        size: 16,
                        // Medium grey secondaryText color
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        duration,
                        // Inherits font size 13, w400, secondaryText color
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
