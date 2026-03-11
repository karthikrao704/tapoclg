import 'package:flutter/material.dart';

class AppointmentCard extends StatelessWidget {
  final String month;
  final String day;
  final String title;
  final String doctorName;
  final String time;
  final String room;
  final VoidCallback? onTap;

  const AppointmentCard({
    super.key,
    required this.month,
    required this.day,
    required this.title,
    required this.doctorName,
    required this.time,
    required this.room,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            // Mapping: Main Background
            color: theme.colorScheme.tertiary,
            // Mapping: Borders/Dividers
            border: Border.all(color: theme.colorScheme.outline.withAlpha(77)),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Side: Date Box
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  border: Border.all(
                    color: theme.colorScheme.outline.withAlpha(77),
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      month.toUpperCase(),
                      // Mapping: Special Card Text (Olive) used for the gold/olive text tone
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      day,
                      // Mapping: Primary Dark Text (Headers)
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16.0),

              // Middle: Details Content
              // Expanded ensures the text column shrinks/grows gracefully on different screen sizes
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      // Mapping: Primary Dark Text
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'with $doctorName',
                      // Mapping: Secondary Grey Text
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12.0),

                    // Bottom Row: Time and Room Details
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        // Time Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            // Mapping: Special Card Bg (Light Green)
                            color: theme.colorScheme.secondary,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            time,
                            // Mapping: Special Card Text (Olive)
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        Text(
                          '•',
                          // Mapping: Secondary Grey Text
                          style: theme.textTheme.bodySmall,
                        ),

                        Text(
                          room,
                          // Mapping: Secondary Grey Text
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8.0),

              // Right Side: Trailing Icon
              Icon(
                Icons.chevron_right_rounded,
                // Mapping: Borders/Dividers (used here for neutral grey icon tint)
                color: theme.colorScheme.outline,
                size: 28.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
