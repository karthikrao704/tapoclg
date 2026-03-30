import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';

// --- Data Model ---
class ServiceItem {
  final String title;
  final String durationAndCategory;
  final String price;
  final String imageUrl;
  final bool isFavorite;

  const ServiceItem({
    required this.title,
    required this.durationAndCategory,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });
}

// --- Sample Data ---
const List<ServiceItem> _mockServices = [
  ServiceItem(
    title: 'Deep Tissue Massage',
    durationAndCategory: '60 mins • Spa',
    price: '₹250',
    imageUrl: 'assets/images/deep_massage_bg.png',
    isFavorite: true,
  ),
  ServiceItem(
    title: 'Vidal Sassoon Cut',
    durationAndCategory: '45 mins • Salon',
    price: '₹250',
    imageUrl: 'assets/images/vidal_sasson_cut_bg.png',
    isFavorite: true,
  ),
  ServiceItem(
    title: 'Hatha Yoga Session',
    durationAndCategory: '90 mins • Yoga',
    price: '₹250',
    imageUrl: 'assets/images/hatha_yoga_session_bg.png',
  ),
  ServiceItem(
    title: 'Mindfulness Intro',
    durationAndCategory: '30 mins • Meditation',
    price: '₹250',
    imageUrl: 'assets/images/mindfulness_intro_bg.png',
  ),
];

// --- Main Grid Widget ---
class ServiceGridSection extends StatelessWidget {
  const ServiceGridSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 1. Fetch the text scaling factor from device accessibility settings
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    // 2. Calculate a safe card height.
    // Image height is roughly 150. Text area base is roughly 100, multiplied by text scale.
    final double estimatedCardHeight = 150.0 + (110.0 * textScale);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Services',
          style: AppFonts.headland(color: AppTheme.primaryText, fontSize: 20),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        // 3. Use MaxCrossAxisExtent for responsive column counts
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent:
              250, // Card will be max 250px wide. Drops to 1 col on small phones.
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          mainAxisExtent: estimatedCardHeight, // Replaces childAspectRatio
        ),
        itemCount: _mockServices.length,
        itemBuilder: (context, index) {
          return _ServiceCard(item: _mockServices[index]);
        },
      ),
    );
  }
}

// --- Individual Card Widget ---
class _ServiceCard extends StatelessWidget {
  final ServiceItem item;

  const _ServiceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4. Top Half: Image and Favorite Button using AspectRatio
          AspectRatio(
            aspectRatio:
                16 /
                10, // Gives the image a stable size regardless of card height
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15.0),
                  ),
                  child: Image.asset(
                    item.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8.0,
                  right: 8.0,
                  child: CircleAvatar(
                    backgroundColor: theme.colorScheme.surface,
                    radius: 16.0,
                    child: Icon(
                      item.isFavorite ? Icons.star : Icons.star_border,
                      size: 20.0,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 5. Bottom Half: Details take the remaining calculated space
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.poppinsSemiBold(
                      color: AppTheme.primaryText,
                      fontSize: 14,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    item.durationAndCategory,
                    style: AppFonts.poppinsRegular(
                      color: AppTheme.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.price,
                        style: AppFonts.poppinsSemiBold(
                          color: AppColors.primaryColor,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: InkWell(
                          onTap: () {
                            // Add to cart logic
                          },
                          borderRadius: BorderRadius.circular(8.0),
                          child: const Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
