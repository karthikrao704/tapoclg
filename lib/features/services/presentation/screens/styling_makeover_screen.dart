import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/core/widgets/secondary_app_bar.dart';

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
    final theme = Theme.of(context);

    // 1. Central breakpoint logic
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.width < 360 || size.height < 650;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: const SecondaryAppBar(title: 'Styling & Makeover'),
        body: Column(
          children: [
            // Static Hero Banner
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: isSmallScreen ? 4.0 : 8.0,
              ),
              child: _HeroBanner(isSmallScreen: isSmallScreen),
            ),

            // Tab Bar
            TabBar(
              // 2. Prevent horizontal squeezing on tight phones
              isScrollable: isSmallScreen,
              tabAlignment: isSmallScreen
                  ? TabAlignment.start
                  : TabAlignment.center,
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: AppTheme.secondaryText,
              dividerColor: Colors.transparent,
              indicatorColor: AppColors.primaryColor,
              labelStyle: AppFonts.poppinsSemiBold(
                fontSize: isSmallScreen ? 12 : 14,
              ),
              unselectedLabelStyle: AppFonts.poppinsRegular(
                fontSize: isSmallScreen ? 12 : 14,
              ),
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
                        height: isSmallScreen ? 40 : 50,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.05,
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
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.05,
                            vertical: isSmallScreen ? 8.0 : 16.0,
                          ),
                          itemCount: _mockStylingServices.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                          itemBuilder: (context, index) {
                            return StylingCard(
                              item: _mockStylingServices[index],
                              isSmallScreen: isSmallScreen,
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
  final bool isSmallScreen;

  const _HeroBanner({required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Scaled hero height
      height: isSmallScreen ? 120 : 160,
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withAlpha(180)],
            stops: const [0.4, 1.0],
          ),
        ),
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        // 1. Removed `alignment: Alignment.bottomLeft` from here to let the Column manage the space
        child: Column(
          // 2. Set the Column to push items to the bottom
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3. Wrapped in Flexible to safely shrink if height runs out
            Flexible(
              child: Text(
                'COUTURE BEAUTY',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.poppinsSemiBold(
                  color: AppColors.primaryColor,
                  fontSize: isSmallScreen ? 10 : 12,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // 4. Safely bound the main title to 2 lines max
            Flexible(
              child: Text(
                'Styling & Makeover',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.poppinsSemiBold(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 20 : 24,
                  height: 1.2, // Tighter line height for large text
                ),
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
    final isSmallScreen = MediaQuery.sizeOf(context).height < 650;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppFonts.poppinsSemiBold(
              color: AppTheme.primaryText,
              fontSize: isSmallScreen ? 9 : 10,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down,
            size: isSmallScreen ? 12 : 14,
            color: AppTheme.secondaryText,
          ),
        ],
      ),
    );
  }
}

class StylingCard extends StatelessWidget {
  final StylingItem item;
  final bool isSmallScreen;

  const StylingCard({
    super.key,
    required this.item,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          // Image Section with Badges
          Stack(
            children: [
              Image.network(
                item.imageUrl,
                // 4. Shrink image height so it doesn't crowd text on small phones
                height: isSmallScreen ? 150 : 200,
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
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.categoryTag,
                        style: AppFonts.poppinsSemiBold(
                          color: Colors.white,
                          fontSize: 10,
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
                        color: Colors.black.withAlpha(180),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.durationTag,
                        style: AppFonts.poppinsSemiBold(
                          color: Colors.white,
                          fontSize: 10,
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
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Price Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 5. Bound the title to avoid horizontal crushing
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.poppinsSemiBold(
                          color: AppTheme.primaryText,
                          fontSize: isSmallScreen ? 14 : 16,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.price,
                      style: AppFonts.poppinsSemiBold(
                        color: AppColors.primaryColor,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),

                // Description
                Text(
                  item.description,
                  style: AppFonts.poppinsRegular(
                    color: AppTheme.secondaryText,
                    fontSize: isSmallScreen ? 13 : 14,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // 6. Prevent clipping inside the button via minimumSize
                      minimumSize: Size(
                        double.infinity,
                        isSmallScreen ? 44 : 50,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 12 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
                    child: Text(
                      'BOOK STYLING SESSION',
                      style: AppFonts.poppinsSemiBold(
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
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
