import 'package:flutter/material.dart';

// --- DATA MODEL ---
class StylingItem {
  final String imageUrl;
  final String title;
  final String price;
  final String description;
  final String categoryTag;
  final String durationTag;

  const StylingItem({
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.description,
    required this.categoryTag,
    required this.durationTag,
  });
}

// --- DUMMY DATA ---
const List<StylingItem> _mockStylingServices = [
  StylingItem(
    imageUrl: 'https://picsum.photos/seed/style1/600/300', // Placeholder
    title: 'Signature Evening Glow',
    price: '\$120',
    description:
        'Sophisticated glam for high-end evening events, featuring our signature radiant finish and contouring.',
    categoryTag: 'PARTY',
    durationTag: '60 MIN',
  ),
  StylingItem(
    imageUrl: 'https://picsum.photos/seed/style2/600/300',
    title: 'Royal Bridal Aura',
    price: '\$350',
    description:
        'Luxury bridal transformation including trial session and premium waterproof HD products.',
    categoryTag: 'WEDDING',
    durationTag: '120 MIN',
  ),
  StylingItem(
    imageUrl: 'https://picsum.photos/seed/style3/600/300',
    title: 'Minimalist Chic',
    price: '\$85',
    description:
        'Clean, natural makeup focusing on skin health and subtle enhancements for day-time events.',
    categoryTag: 'EVENT',
    durationTag: '45 MIN',
  ),
];

// --- MAIN SCREEN ---
class StylingMakeoverScreen extends StatelessWidget {
  const StylingMakeoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Always use Theme.of(context)

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor, // Main Background
        appBar: AppBar(
          title: const Text('Styling & Makeover'),
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
        ),
        body: Column(
          children: [
            // Static Hero Banner
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _HeroBanner(),
            ),

            // Tab Bar
            TabBar(
              labelColor: theme.colorScheme.primary, // Primary Actions/Active
              unselectedLabelColor:
                  theme.textTheme.bodySmall?.color, // Secondary Grey Text
              dividerColor: Colors.transparent, // Remove default divider
              indicatorColor: theme.colorScheme.primary,
              tabs: const [
                Tab(text: 'Makeup'),
                Tab(text: 'Bridal Makeover'),
                Tab(text: 'Hair Styling'),
              ],
            ),

            // Tab Bar Content
            Expanded(
              child: TabBarView(
                children: [
                  // Makeup Tab Content
                  Column(
                    children: [
                      // Filter Row
                      SizedBox(
                        height: 50,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          children: const [
                            _FilterDropdownChip(label: 'WEDDING'),
                            SizedBox(width: 8),
                            _FilterDropdownChip(label: 'PARTY'),
                            SizedBox(width: 8),
                            _FilterDropdownChip(label: 'EVENT'),
                          ],
                        ),
                      ),

                      // Scrollable List
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _mockStylingServices.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16.0),
                          itemBuilder: (context, index) {
                            return StylingCard(
                              item: _mockStylingServices[index],
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  // Placeholders for other tabs
                  const Center(child: Text('Bridal Makeover Content')),
                  const Center(child: Text('Hair Styling Content')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- REUSABLE WIDGETS ---

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: NetworkImage(
            'https://picsum.photos/seed/stylehero/800/400',
          ), // Placeholder
          fit: BoxFit.cover,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        // Gradient to ensure text pops against any image
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withAlpha(180)],
            stops: const [0.4, 1.0],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'COUTURE BEAUTY',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary, // Highlight accent
                letterSpacing: 2.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Styling & Makeover',
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

class _FilterDropdownChip extends StatelessWidget {
  final String label;

  const _FilterDropdownChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor, // Main Background
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha(50), // Borders/Dividers
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.textTheme.bodyMedium?.color, // Standard text color
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down,
            size: 14,
            color: theme.textTheme.bodySmall?.color, // Secondary Grey
          ),
        ],
      ),
    );
  }
}

class StylingCard extends StatelessWidget {
  final StylingItem item;

  const StylingCard({super.key, required this.item});

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
          // Image Section with Badges
          Stack(
            children: [
              Image.network(
                item.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              // Dual Badges positioned at Top Left
              Positioned(
                top: 12,
                left: 12,
                child: Row(
                  children: [
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primary, // Primary action color
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.categoryTag,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Duration Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(
                          180,
                        ), // Dark overlay mapping
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.durationTag,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                        color: theme.colorScheme.primary, // Price mapping
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
                    color:
                        theme.textTheme.bodySmall?.color, // Secondary Grey Text
                  ),
                ),
                const SizedBox(height: 16),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('BOOK STYLING SESSION'),
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
