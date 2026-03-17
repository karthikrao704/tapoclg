import 'package:flutter/material.dart';

// --- DATA MODEL ---
class HairCareItem {
  final String imageUrl;
  final String title;
  final String price;
  final String description;
  final String duration;

  const HairCareItem({
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.description,
    required this.duration,
  });
}

// --- DUMMY DATA ---
const List<HairCareItem> _mockServices = [
  HairCareItem(
    imageUrl: 'https://picsum.photos/seed/hair1/600/300',
    title: 'Signature Master Haircut',
    price: '₹250',
    description:
        'Precision cutting by our master stylists including wash, deep scalp massage, and professional blow-dry.',
    duration: '60 mins',
  ),
  HairCareItem(
    imageUrl: 'https://picsum.photos/seed/hair2/600/300',
    title: 'Ayurvedic Hair Spa',
    price: '₹250',
    description:
        'Intense hydration treatment using organic oils and herbs to restore shine, strength, and scalp health.',
    duration: '90 mins',
  ),
  HairCareItem(
    imageUrl: 'https://picsum.photos/seed/hair3/600/300',
    title: 'Global Balayage',
    price: 'From ₹250',
    description:
        'Custom hand-painted highlights for a sun-kissed, natural look. Includes toner and style.',
    duration: '150 mins',
  ),
  HairCareItem(
    imageUrl: 'https://picsum.photos/seed/hair4/600/300',
    title: 'Keratin Smoothening',
    price: '₹250',
    description:
        'Long-lasting frizz control and mirror-like shine using premium formaldehyde-free keratin complex.',
    duration: '180 mins',
  ),
];

// --- MAIN SCREEN ---
class HairCareScreen extends StatelessWidget {
  const HairCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate a dynamic height for the filter row based on system text scaling
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final filterRowHeight = 50.0 + (20.0 * (textScale - 1.0).clamp(0.0, 3.0));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Hair Care'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: theme.colorScheme.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Row - now dynamically sized
          SizedBox(
            height: filterRowHeight,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              children: const [
                _FilterChip(label: 'All', isActive: true),
                SizedBox(width: 8),
                _FilterChip(label: 'Haircut', hasDropdown: true),
                SizedBox(width: 8),
                _FilterChip(label: 'Styling', hasDropdown: true),
                SizedBox(width: 8),
                _FilterChip(label: 'Hair Spa', hasDropdown: true),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const _PromoBanner(),
                const SizedBox(height: 16),
                ..._mockServices.map(
                  (service) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: HairCareCard(item: service),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- REUSABLE WIDGETS ---

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool hasDropdown;

  const _FilterChip({
    required this.label,
    this.isActive = false,
    this.hasDropdown = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.primary.withAlpha(50),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.primary.withAlpha(80),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isActive
                  ? theme.colorScheme.onPrimary
                  : theme.textTheme.bodyMedium?.color,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (hasDropdown) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: theme.textTheme.bodySmall?.color,
            ),
          ],
        ],
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      // Replaced fixed height with BoxConstraints for text scaling safety
      constraints: const BoxConstraints(minHeight: 140),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: NetworkImage('https://picsum.photos/seed/promo/600/300'),
          fit: BoxFit.cover,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withAlpha(50), Colors.black.withAlpha(150)],
          ),
        ),
        alignment: Alignment.center,
        // Added padding to ensure text doesn't hit edges when scaled
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'EXCLUSIVE EXPERIENCE',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Premium Hair Rituals',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HairCareCard extends StatelessWidget {
  final HairCareItem item;

  const HairCareCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(50)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Section: AspectRatio prevents distortion and scales gracefully
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(item.imageUrl, fit: BoxFit.cover),
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Price Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      item.price,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  item.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 16),

                // Duration and Action Button Wrap (Replaced Row for responsiveness)
                // 1. Force the container to take the full width of the card
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    // 2. Now spaceBetween has room to push the elements to the edges
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    // 3. spacing acts as a minimum safety gap right before it wraps to a new line
                    spacing: 16.0,
                    runSpacing: 12.0,
                    children: [
                      // --- Duration Element ---
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 4),
                          Text(item.duration, style: theme.textTheme.bodySmall),
                        ],
                      ),

                      // --- Action Button Element ---
                      ElevatedButton(
                        onPressed: () {
                          // Booking logic
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.0 * textScale.clamp(1.0, 1.5),
                            vertical: 12.0 * textScale,
                          ),
                          minimumSize: const Size(64, 48),
                        ),
                        child: const Text(
                          'Book Now',
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
