import 'package:flutter/material.dart';

// --- DATA MODEL ---
class NailCareItem {
  final String imageUrl;
  final String title;
  final String price;
  final String duration;
  final String featureTag;
  final String description;
  final bool isBestseller;

  const NailCareItem({
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.duration,
    required this.featureTag,
    required this.description,
    this.isBestseller = false,
  });
}

// --- DUMMY DATA ---
const List<NailCareItem> _mockNailServices = [
  NailCareItem(
    imageUrl: 'https://picsum.photos/seed/nail1/600/300', // Placeholder
    title: 'Signature Spa Manicure',
    price: '₹250',
    duration: '60 mins',
    featureTag: 'Aromatherapy Soak',
    description:
        'A rejuvenating hand ritual featuring a botanical soak, organic sugar exfoliation, and a deep-tissue hand massage.',
    isBestseller: true,
  ),
  NailCareItem(
    imageUrl: 'https://picsum.photos/seed/nail2/600/300',
    title: 'Luxury Stone Pedicure',
    price: '₹250',
    duration: '75 mins',
    featureTag: 'Hot Stone Massage',
    description:
        'Deep hydration treatment using warm essential oils and basalt stones to release tension in tired feet and calves.',
  ),
  NailCareItem(
    imageUrl: 'https://picsum.photos/seed/nail3/600/300',
    title: 'Gel Polish Perfection',
    price: '₹250',
    duration: '45 mins',
    featureTag: 'Long-lasting Shine',
    description:
        'Precision shaping and cuticle care finished with high-performance vegan gel polish for two weeks of chip-free wear.',
  ),
];

// --- MAIN SCREEN ---
class NailCareScreen extends StatelessWidget {
  const NailCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Always use Theme.of(context)

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor, // Main Background
        appBar: AppBar(
          title: const Text('Nail Care'),
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
                theme.textTheme.bodySmall?.color, // Secondary Grey Text
            dividerColor: Colors.transparent, // Remove default divider
            indicatorColor: theme.colorScheme.primary,
            tabAlignment: TabAlignment.center,
            tabs: const [
              Tab(text: 'All Services'),
              Tab(text: 'Manicure'),
              Tab(text: 'Pedicure'),
              Tab(text: 'Nail Art'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // All Services Tab Content
            ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: _mockNailServices.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 16.0),
              itemBuilder: (context, index) {
                return NailCareCard(item: _mockNailServices[index]);
              },
            ),
            // Placeholders for other tabs
            const Center(child: Text('Manicure Content')),
            const Center(child: Text('Pedicure Content')),
            const Center(child: Text('Nail Art Content')),
          ],
        ),
      ),
    );
  }
}

// --- REUSABLE WIDGETS ---

class NailCareCard extends StatelessWidget {
  final NailCareItem item;

  const NailCareCard({super.key, required this.item});

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
          // Image Section with optional Bestseller Badge
          Stack(
            children: [
              Image.network(
                item.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              if (item.isBestseller)
                const Positioned(top: 12, right: 12, child: _BestsellerBadge()),
            ],
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
                        ), // Primary Dark Text
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.price,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme
                            .colorScheme
                            .primary, // Mapped active/primary color
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Metadata Row (Duration & Feature Tag)
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: theme
                          .textTheme
                          .bodySmall
                          ?.color, // Secondary Grey Text
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.duration,
                      style: theme.textTheme.bodySmall, // Secondary Grey Text
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '•',
                        style: theme.textTheme.bodySmall, // Secondary Grey Text
                      ),
                    ),
                    Text(
                      item.featureTag,
                      style: theme.textTheme.bodySmall, // Secondary Grey Text
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  item.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme
                        .textTheme
                        .bodySmall
                        ?.color, // Utilizing secondary grey for body text
                  ),
                ),
                const SizedBox(height: 16),

                // Action Button - Relies on global Elevated Button theme
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement booking action
                    },
                    child: const Text('BOOK SERVICE'),
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

class _BestsellerBadge extends StatelessWidget {
  const _BestsellerBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withAlpha(
          230,
        ), // Semi-transparent overlay
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'BESTSELLER',
        style: theme.textTheme.labelSmall?.copyWith(
          color:
              theme.colorScheme.primary, // Primary color mapping for attention
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
