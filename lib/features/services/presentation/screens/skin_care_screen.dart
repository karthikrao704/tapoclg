import 'package:flutter/material.dart';

// --- DATA MODEL ---
class SkinCareItem {
  final String imageUrl;
  final String title;
  final String duration;
  final String description;
  final String benefits;
  final String price;

  const SkinCareItem({
    required this.imageUrl,
    required this.title,
    required this.duration,
    required this.description,
    required this.benefits,
    required this.price,
  });
}

// --- DUMMY DATA ---
const List<SkinCareItem> _mockFacials = [
  SkinCareItem(
    imageUrl: 'https://picsum.photos/seed/facial1/600/300', // Placeholder
    title: 'Deep Cleansing Facial',
    duration: '60 mins',
    description:
        'A revitalizing treatment that removes impurities and refreshes tired skin using organic botanical extracts.',
    benefits: 'Glowing skin, unclogged pores, and intense hydration.',
    price: '₹250',
  ),
  SkinCareItem(
    imageUrl: 'https://picsum.photos/seed/facial2/600/300',
    title: 'Ayurvedic Glow Facial',
    duration: '75 mins',
    description:
        'Holistic therapy using ancient herbal pastes tailored to your specific dosha for ultimate radiance.',
    benefits:
        'Balances skin tone, reduces fine lines, and promotes inner calm.',
    price: '₹250',
  ),
  SkinCareItem(
    imageUrl: 'https://picsum.photos/seed/facial3/600/300',
    title: 'Anti-Pollution Detox',
    duration: '45 mins',
    description:
        'Specifically designed for urban dwellers to combat environmental damage and oxidation.',
    benefits: 'Oxygenates skin cells and creates a protective barrier.',
    price: '₹250',
  ),
];

// --- MAIN SCREEN ---
class SkinCareScreen extends StatelessWidget {
  const SkinCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor, // Main Background
        appBar: AppBar(
          title: const Text('Skin Care'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.search,
                color: theme.colorScheme.primary,
              ), // Active Icons
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
            labelColor: theme.colorScheme.primary, // Primary Actions/Active
            unselectedLabelColor:
                theme.textTheme.bodySmall?.color, // Secondary Grey
            dividerColor: Colors.transparent,
            indicatorColor: theme.colorScheme.primary,
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            tabs: const [
              Tab(text: 'Facials'),
              Tab(text: 'Detan Treatment'),
              Tab(text: 'Bleach'),
              Tab(text: 'Waxing'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Facials Tab Content
            ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _SectionHeader(
                  title: 'Facial Therapies',
                  subtitle: 'SIGNATURE TREATMENTS',
                ),
                const SizedBox(height: 16),
                ..._mockFacials.map(
                  (service) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: SkinCareCard(item: service),
                  ),
                ),
              ],
            ),
            // Placeholders for other tabs
            const Center(child: Text('Detan Treatment Content')),
            const Center(child: Text('Bleach Content')),
            const Center(child: Text('Waxing Content')),
          ],
        ),
      ),
    );
  }
}

// --- REUSABLE WIDGETS ---

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.textTheme.bodySmall?.color, // Secondary Grey Text
            letterSpacing: 2.0, // Spaced out for the specific design look
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class SkinCareCard extends StatelessWidget {
  final SkinCareItem item;

  const SkinCareCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor, // Main Background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha(50),
        ), // Borders/Dividers
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Section
          Image.network(item.imageUrl, height: 180, fit: BoxFit.cover),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Duration Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ), // Primary Dark Text
                      ),
                    ),
                    const SizedBox(width: 8),
                    _DurationBadge(duration: item.duration),
                  ],
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  item.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme
                        .textTheme
                        .bodySmall
                        ?.color, // Secondary Grey Text mapping
                  ),
                ),
                const SizedBox(height: 16),

                // Benefits Box (Utilizing Special Card mapping)
                _BenefitsBox(benefitsText: item.benefits),
                const SizedBox(height: 16),

                // Price and Action Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.price,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary, // Price highlighted
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Implement booking action
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Book Now'),
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

class _DurationBadge extends StatelessWidget {
  final String duration;

  const _DurationBadge({required this.duration});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(
          100,
        ), // Subtle background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        duration,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.textTheme.bodySmall?.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BenefitsBox extends StatelessWidget {
  final String benefitsText;

  const _BenefitsBox({required this.benefitsText});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Using the mapped "Special Card Bg" and "Special Card Text"
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withAlpha(
          30,
        ), // Light Green mapping (softened)
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BENEFITS',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSecondary, // Olive mapping
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            benefitsText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSecondary.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }
}
