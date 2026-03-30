import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tapovana_mobile_app/core/routing/route_constants.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';

// --- Data Model ---
class CardItem {
  final String overline;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String routePath; // Updated to use a string path for go_router

  const CardItem({
    required this.overline,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.routePath,
  });
}

// --- Sample Data ---
final List<CardItem> _mockCategories = [
  const CardItem(
    overline: 'RELAXATION',
    title: 'Body Care',
    subtitle: 'Massages, scrubs & wraps',
    imageUrl: 'assets/images/body_care.png',
    routePath: RouteConstants.bodyCare, // Target route
  ),
  const CardItem(
    overline: 'REJUVENATION',
    title: 'Skincare',
    subtitle: 'Facials, peels & specialized care',
    imageUrl: 'assets/images/skin_care.png',
    routePath: RouteConstants.skinCare,
  ),
  const CardItem(
    overline: 'VITALITY',
    title: 'Haircare',
    subtitle: 'Cuts, color & organic treatments',
    imageUrl: 'assets/images/hair_care.png',
    routePath: RouteConstants.hairCare,
  ),
  const CardItem(
    overline: 'DETAILING',
    title: 'Nail Care',
    subtitle: 'Manicures & restorative pedicures',
    imageUrl: 'assets/images/nail_care.png',
    routePath: RouteConstants.nailCare,
  ),
  const CardItem(
    overline: 'EXCELLENCE',
    title: 'Styling',
    subtitle: 'Event makeup & personal styling',
    imageUrl: 'assets/images/styling_care.png',
    routePath: RouteConstants.styling,
  ),
];

// --- Main Page Widget ---
class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Services',
          style: AppFonts.headland(color: AppTheme.primaryText, fontSize: 20),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: _mockCategories.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16.0),
        itemBuilder: (context, index) {
          return _CategoryCard(item: _mockCategories[index]);
        },
      ),
    );
  }
}

// --- Individual Card Widget ---
class _CategoryCard extends StatelessWidget {
  final CardItem item;

  const _CategoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Wrapped in Material and InkWell for the ripple touch effect
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Use go_router to push the new route
          context.push(item.routePath);
        },
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline.withAlpha(50)),
            borderRadius: BorderRadius.circular(12.0),
            image: DecorationImage(
              image: AssetImage(item.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              // --- Gradient Overlay ---
              // Transparent at the top, dark at the bottom
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent, // Top is fully transparent
                  Colors.black.withAlpha(50), // Middle starts darkening
                  Colors.black.withAlpha(100), // Bottom is dark
                ],
                // Fine-tune where the gradient colors start/end
                stops: const [0.4, 0.7, 1.0],
              ),
              // --------------------------
            ),
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.overline,
                  style: AppFonts.poppinsSemiBold(
                    color: AppColors.primaryColor,
                    fontSize: 12,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  item.title,
                  style: AppFonts.poppinsSemiBold(
                    color: AppColors.white,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  item.subtitle,
                  style: AppFonts.poppinsRegular(
                    color: AppColors.white.withAlpha(200),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
