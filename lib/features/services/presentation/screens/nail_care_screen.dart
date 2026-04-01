import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/core/widgets/secondary_app_bar.dart';

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

    // 1. Establish breakpoint
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.width < 360 || size.height < 650;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor, // Main Background
        appBar: SecondaryAppBar(
          title: 'Nail Care',
          bottom: TabBar(
            // 2. Make tabs scrollable on narrow screens to prevent horizontal squishing
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
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: isSmallScreen ? 12.0 : 16.0,
              ),
              itemCount: _mockNailServices.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: isSmallScreen ? 12.0 : 16.0),
              itemBuilder: (context, index) {
                return NailCareCard(
                  item: _mockNailServices[index],
                  isSmallScreen: isSmallScreen,
                );
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
  final bool isSmallScreen;

  const NailCareCard({
    super.key,
    required this.item,
    required this.isSmallScreen,
  });

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
                // 3. Scale image height dynamically
                height: isSmallScreen ? 150 : 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              if (item.isBestseller)
                Positioned(
                  top: 12,
                  right: 12,
                  child: _BestsellerBadge(isSmallScreen: isSmallScreen),
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

                // 4. Replaced Row with Wrap to prevent right-side clipping on long tags
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: isSmallScreen ? 12 : 14,
                      color: AppColors.primaryBlack40,
                    ),
                    Text(
                      item.duration,
                      style: AppFonts.poppinsRegular(
                        color: AppColors.primaryBlack40,
                        fontSize: isSmallScreen ? 11 : 12,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        '•',
                        style: AppFonts.poppinsRegular(
                          color: AppColors.primaryBlack40,
                          fontSize: isSmallScreen ? 11 : 12,
                        ),
                      ),
                    ),
                    Text(
                      item.featureTag,
                      style: AppFonts.poppinsRegular(
                        color: AppColors.primaryBlack40,
                        fontSize: isSmallScreen ? 11 : 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),

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
                      // 5. Responsive minimum height
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
                    onPressed: () {
                      // TODO: Implement booking action
                    },
                    child: Text(
                      'BOOK SERVICE',
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

class _BestsellerBadge extends StatelessWidget {
  final bool isSmallScreen;

  const _BestsellerBadge({required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6 : 8,
        vertical: isSmallScreen ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withAlpha(230),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'BESTSELLER',
        style: AppFonts.poppinsSemiBold(
          color: AppColors.primaryColor,
          fontSize: isSmallScreen ? 9 : 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
