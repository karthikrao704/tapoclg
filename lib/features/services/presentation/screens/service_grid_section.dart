import 'package:flutter/material.dart';

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
    imageUrl: 'https://picsum.photos/seed/massage/400/300', // Placeholder
    isFavorite: true,
  ),
  ServiceItem(
    title: 'Vidal Sassoon Cut',
    durationAndCategory: '45 mins • Salon',
    price: '₹250',
    imageUrl: 'https://picsum.photos/seed/salon/400/300',
    isFavorite: true,
  ),
  ServiceItem(
    title: 'Hatha Yoga Session',
    durationAndCategory: '90 mins • Yoga',
    price: '₹250',
    imageUrl: 'https://picsum.photos/seed/yoga/400/300',
  ),
  ServiceItem(
    title: 'Mindfulness Intro',
    durationAndCategory: '30 mins • Meditation',
    price: '₹250',
    imageUrl: 'https://picsum.photos/seed/meditation/400/300',
  ),
];

// --- Main Grid Widget ---
class ServiceGridSection extends StatelessWidget {
  const ServiceGridSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Services')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.70, // Adjusts height vs width ratio
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
          // Top Half: Image and Favorite Button
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15.0),
                  ),
                  child: Image.network(
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
                      color: theme
                          .colorScheme
                          .primary, // Mapped to Primary Active Icons
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Half: Details
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    item.durationAndCategory,
                    style: theme.textTheme.bodySmall?.copyWith(
                      // Using the Olive map for the colored subtitle
                      color: theme.colorScheme.onSecondary.withAlpha(80),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.price,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme
                              .colorScheme
                              .onSecondary, // Mapped to Olive Text
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: theme
                              .colorScheme
                              .onSecondary, // Matches the '+' button color
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: InkWell(
                          onTap: () {
                            // Add to cart logic
                          },
                          borderRadius: BorderRadius.circular(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(
                              Icons.add,
                              color: theme.colorScheme.surface,
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
