import 'package:flutter/material.dart';

// --- Data Model ---
class CardItem {
  final String overline;
  final String title;
  final String subtitle;
  final String imageUrl;

  const CardItem({
    required this.overline,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });
}

// --- Sample Data ---
const List<CardItem> _mockCategories = [
  CardItem(
    overline: 'RELAXATION',
    title: 'Body Care',
    subtitle: 'Massages, scrubs & wraps',
    imageUrl: 'https://picsum.photos/seed/bodycare/600/400', // Placeholder
  ),
  CardItem(
    overline: 'REJUVENATION',
    title: 'Skincare',
    subtitle: 'Facials, peels & specialized care',
    imageUrl: 'https://picsum.photos/seed/skincare/600/400',
  ),
  CardItem(
    overline: 'VITALITY',
    title: 'Haircare',
    subtitle: 'Cuts, color & organic treatments',
    imageUrl: 'https://picsum.photos/seed/haircare/600/400',
  ),
  CardItem(
    overline: 'DETAILING',
    title: 'Nail Care',
    subtitle: 'Manicures & restorative pedicures',
    imageUrl: 'https://picsum.photos/seed/nailcare/600/400',
  ),
  CardItem(
    overline: 'EXCELLENCE',
    title: 'Styling',
    subtitle: 'Event makeup & personal styling',
    imageUrl: 'https://picsum.photos/seed/styling/600/400',
  ),
];

// --- Main Page Widget ---
class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: _mockCategories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16.0),
      itemBuilder: (context, index) {
        return _CategoryCard(item: _mockCategories[index]);
      },
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

    return Container(
      height: 180, // Fixed height to match the aspect ratio in the design
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        // Fallback border color utilizing the theme outline
        border: Border.all(color: theme.colorScheme.outline.withAlpha(50)),
        image: DecorationImage(
          image: NetworkImage(item.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        // Gradient overlay to ensure text readability
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withAlpha(40),
              Colors.black.withAlpha(90),
            ],
            stops: const [0.3, 0.7, 1.0], // Pushes the dark gradient lower
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.overline,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme
                    .colorScheme
                    .onSecondary, // Mapped to the Olive requirement
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              item.title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white, // Forced white for image contrast
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              item.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withAlpha(85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
