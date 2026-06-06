import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';

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
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF9F9F9),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F1F1)),
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
                  color: isDark ? const Color(0xFF0F172A) : AppColors.white,
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F1F1),
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      month.toUpperCase(),
                      // Mapping: Special Card Text (Olive) used for the gold/olive text tone
                      style: AppFonts.poppinsBold(
                        fontSize: 13,
                        color: isDark ? const Color(0xFFC9A14A) : AppTheme.wellnessTipText,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      day,
                      // Mapping: Primary Dark Text (Headers)
                      style: AppFonts.poppinsBold(
                        fontSize: 22,
                        color: theme.colorScheme.onSurface,
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
                      style: AppFonts.poppinsSemiBold(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'with $doctorName',
                      // Mapping: Secondary Grey Text
                      style: AppFonts.poppinsRegular(
                        fontSize: 14,
                        color: theme.textTheme.bodySmall?.color ?? AppTheme.secondaryText,
                      ),
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
                            color: isDark ? const Color(0x22C9A14A) : AppTheme.wellnessTipBg,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            time,
                            // Mapping: Special Card Text (Olive)
                            style: AppFonts.poppinsSemiBold(
                              fontSize: 12,
                              color: isDark ? const Color(0xFFC9A14A) : AppTheme.wellnessTipText,
                            ),
                          ),
                        ),

                        Text(
                          '•',
                          style: AppFonts.poppinsRegular(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color ?? AppTheme.secondaryText,
                          ),
                        ),
                        Text(
                          room,
                          style: AppFonts.poppinsRegular(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color ?? AppTheme.secondaryText,
                          ),
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
                color: isDark ? Colors.white38 : AppTheme.outlineColor,
                size: 28.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}