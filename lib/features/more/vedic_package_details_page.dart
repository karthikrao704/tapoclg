import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/features/appointments/presentation/pages/appointment_booking_page.dart';
import 'package:tapovana_mobile_app/core/widgets/media_helper.dart';
import 'package:tapovana_mobile_app/core/widgets/review_section.dart';
import 'models/more_models.dart';

class VedicPackageDetailsPage extends StatelessWidget {
  final VedicPackage package;

  const VedicPackageDetailsPage({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Collapsible Image Header Banner
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.9),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  MediaHelper.buildServiceImage(
                    package.imagePath,
                    fit: BoxFit.cover,
                    fallbackWidget: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFD8E8C8),
                            Color(0xFFB0C898),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.nature_outlined,
                        size: 64,
                        color: Color(0xFF688050),
                      ),
                    ),
                  ),
                  // Gradient Overlay
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black26,
                            Colors.transparent,
                            Colors.black87,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Tags and Subtitle overlay at bottom of image
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          spacing: 8,
                          children: package.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag,
                                style: AppFonts.poppinsSemiBold(
                                  color: Colors.white,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          package.title.replaceAll('\n', ' '),
                          style: AppFonts.headland(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          package.subtitle,
                          style: AppFonts.poppinsMedium(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Badges (Duration & Focus)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  color: Color(0xFFC9A14A), size: 20),
                              const SizedBox(height: 6),
                              Text(
                                "DURATION",
                                style: AppFonts.poppinsRegular(
                                  fontSize: 10,
                                  color: AppColors.primaryBlack40,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                package.duration,
                                style: AppFonts.poppinsSemiBold(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.spa_outlined,
                                  color: Color(0xFFC9A14A), size: 20),
                              const SizedBox(height: 6),
                              Text(
                                "PROGRAM FOCUS",
                                style: AppFonts.poppinsRegular(
                                  fontSize: 10,
                                  color: AppColors.primaryBlack40,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                package.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.poppinsSemiBold(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Description
                  _sectionHeader(context, "Program Philosophy"),
                  const SizedBox(height: 10),
                  Text(
                    package.description,
                    style: AppFonts.poppinsRegular(
                      color: Theme.of(context).textTheme.bodySmall?.color ?? AppTheme.secondaryText,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Benefits
                  _sectionHeader(context, "Key Benefits"),
                  const SizedBox(height: 12),
                  Column(
                    children: package.benefits.map((benefit) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFFC9A14A),
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                benefit,
                                style: AppFonts.poppinsMedium(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // Inclusions
                  _sectionHeader(context, "What's Included"),
                  const SizedBox(height: 12),
                  Column(
                    children: package.whatsIncluded.map((inclusion) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFFC9A14A),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                inclusion,
                                style: AppFonts.poppinsRegular(
                                  fontSize: 14,
                                  color: Theme.of(context).textTheme.bodySmall?.color ?? AppTheme.secondaryText,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Testimonials Section
                  ReviewSection(
                    title: "Testimonials",
                    reviews: MockReviews.packageTestimonials,
                    averageRating: 4.75,
                    moduleType: 'vedic_life',
                    itemTitle: package.title,
                  ),
                  const SizedBox(height: 32),

                  // Value & Call to Action Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0x1AD9A04B) : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFD9A04B).withAlpha(50) : const Color(0xFFFDE68A),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "TOTAL PROGRAM VALUE",
                                  style: AppFonts.poppinsRegular(
                                    fontSize: 10,
                                    color: AppColors.primaryBlack40,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      package.price,
                                      style: AppFonts.poppinsSemiBold(
                                        fontSize: 24,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      package.originalPrice,
                                      style: AppFonts.poppinsRegular(
                                        fontSize: 15,
                                        color: AppColors.primaryBlack40,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark ? const Color(0x33B45309) : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "SAVE 30%+",
                                style: AppFonts.poppinsSemiBold(
                                  fontSize: 10,
                                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFF59E0B) : const Color(0xFFB45309),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AppointmentBookingPage(
                                    serviceName: package.title.replaceAll('\n', ' '),
                                    price: package.price,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "BOOK PACKAGE",
                              style: AppFonts.poppinsSemiBold(
                                fontSize: 15,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 1.5,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppFonts.poppinsSemiBold(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
