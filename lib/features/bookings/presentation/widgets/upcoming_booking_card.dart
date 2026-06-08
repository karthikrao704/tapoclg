import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';

class UpcomingBookingCard extends StatefulWidget {
  final Map<String, dynamic>? booking;
  const UpcomingBookingCard({super.key, this.booking});

  @override
  State<UpcomingBookingCard> createState() => _UpcomingBookingCardState();
}

class _UpcomingBookingCardState extends State<UpcomingBookingCard> {
  bool isRescheduleSelected = true;

  String _formatDateString(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return "${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}";
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Establish breakpoints for dynamic scaling
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.height < 650 || size.width < 360;

    final serviceName = widget.booking?['service_name'] ?? 'Deep Tissue Revive';
    final therapistName = widget.booking?['therapist_name'] ?? 'Sarah Jennings';
    final bookingTime = widget.booking?['booking_time'] ?? '10:00 AM';
    
    String dateLabel = 'Monday, Oct 24';
    if (widget.booking?['booking_date'] != null) {
      dateLabel = _formatDateString(widget.booking!['booking_date'].toString());
    }

    // Determine image based on service name
    String imageAsset = "assets/bookings/deeptissue.png";
    final sLower = serviceName.toString().toLowerCase();
    if (sLower.contains('vedic') || sLower.contains('aroma') || sLower.contains('detox')) {
      imageAsset = "assets/bookings/leaf.png";
    } else if (sLower.contains('yoga') || sLower.contains('meditation')) {
      imageAsset = "assets/bookings/yoga.png";
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: Theme.of(context).brightness == Brightness.dark ? null : const [BoxShadow(blurRadius: 6, color: Colors.black12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(
                12,
              ), // Adjusted to match outer container radius visually
            ),
            child: Image.asset(
              imageAsset,
              // 2. Responsive image height to prevent dominating small screens
              height: isSmallScreen ? 140 : 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 3. Wrapped Title in Expanded to prevent horizontal collision with the badge
                    Expanded(
                      child: Text(
                        serviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.poppinsSemiBold(
                          fontSize: isSmallScreen ? 18 : 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 8 : 10,
                        vertical: isSmallScreen ? 3 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0x22D9A04B) : const Color.fromARGB(255, 254, 246, 230),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "CONFIRMED",
                        style: AppFonts.poppinsSemiBold(
                          fontSize: isSmallScreen ? 10 : 11,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 8 : 10),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// DATE
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: isSmallScreen ? 14 : 16,
                          color: AppColors.primaryColor,
                        ),
                        SizedBox(width: isSmallScreen ? 6 : 8),
                        Expanded(
                          // Safety wrap for long dates on max system font scaling
                          child: Text(
                            "$dateLabel • $bookingTime",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.poppinsRegular(
                              fontSize: isSmallScreen ? 13 : 14,
                              color: Theme.of(context).textTheme.bodySmall?.color ?? AppTheme.secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 6 : 8),

                    /// THERAPIST
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: isSmallScreen ? 14 : 16,
                          color: AppColors.primaryColor,
                        ),
                        SizedBox(width: isSmallScreen ? 6 : 8),
                        Expanded(
                          // Safety wrap for long names
                          child: Text(
                            "Therapist: $therapistName",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.poppinsRegular(
                              fontSize: isSmallScreen ? 13 : 14,
                              color: Theme.of(context).textTheme.bodySmall?.color ?? AppTheme.secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 20 : 27),

                /// ACTIONS ROW
                Row(
                  children: [
                    /// RESCHEDULE
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isRescheduleSelected = true;
                          });
                        },
                        child: Container(
                          height: isSmallScreen ? 40 : 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isRescheduleSelected
                                ? AppColors.primaryColor
                                : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : AppColors.white),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.primaryColor),
                          ),
                          // Optional safety wrapper inside fixed-height containers
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: Text(
                                "Reschedule",
                                style: AppFonts.poppinsSemiBold(
                                  fontSize: isSmallScreen ? 13 : 14,
                                  color: isRescheduleSelected
                                      ? AppColors.white
                                      : AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: isSmallScreen ? 8 : 12),

                    /// CANCEL
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isRescheduleSelected = false;
                          });
                        },
                        child: Container(
                          height: isSmallScreen ? 40 : 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: !isRescheduleSelected
                                ? AppColors.primaryColor
                                : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : AppColors.white),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.primaryColor),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: Text(
                                "Cancel",
                                style: AppFonts.poppinsSemiBold(
                                  fontSize: isSmallScreen ? 13 : 14,
                                  color: !isRescheduleSelected
                                      ? AppColors.white
                                      : AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ),
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
