import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/features/service_details/presentation/pages/service_details_page.dart';

// --- DATA MODEL ---
class ServiceItem {
  final String imageUrl;
  final String title;
  final String price;
  final String duration;
  final String description;

  ServiceItem({
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.duration,
    required this.description,
  });
}

// --- DUMMY DATA ---
final List<ServiceItem> dummyMassages = [
  ServiceItem(
    imageUrl:
        'https://picsum.photos/seed/facial4/600/300', // Replace with your actual asset/network path
    title: 'Lavender Bliss Oil Massage',
    price: '₹250',
    duration: '60 mins',
    description:
        'A calming aromatherapy experience using premium lavender essential oils to soothe your senses and melt away daily stress.',
  ),
  ServiceItem(
    imageUrl:
        'https://picsum.photos/seed/massage2/600/300', // Replace with your actual asset/network path
    title: 'Swedish Classic Massage',
    price: '₹250',
    duration: '50 mins',
    description:
        'A full-body therapeutic massage using long, gliding strokes to improve circulation and promote general relaxation.',
  ),
  ServiceItem(
    imageUrl:
        'https://picsum.photos/seed/massage3/600/300', // Replace with your actual asset/network path
    title: 'Deep Tissue Recovery',
    price: '₹250',
    duration: '90 mins',
    description:
        'Ideal for athletes or those with chronic tension, targeting deeper layers of muscle and connective tissue.',
  ),
];

// --- MAIN SCREEN ---
class BodyCareScreen extends StatelessWidget {
  const BodyCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Always use Theme.of(context)

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor, // Main Background
        appBar: AppBar(
          title: Text(
            'Body Care',
            style: AppFonts.headland(color: AppTheme.primaryText, fontSize: 20),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.search,
                color: AppColors.primaryColor,
              ), // Active Icons
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
            labelColor: AppColors.primaryColor, // Primary Actions/Active
            dividerColor: Colors.transparent,
            unselectedLabelColor:
                AppTheme.secondaryText, // Secondary Grey Text
            indicatorColor: AppColors.primaryColor,
            labelStyle: AppFonts.poppinsSemiBold(fontSize: 14),
            unselectedLabelStyle: AppFonts.poppinsRegular(fontSize: 14),
            tabs: const [
              Tab(text: 'Massages'),
              Tab(text: 'Facials'),
              Tab(text: 'Scrubs'),
              Tab(text: 'Hydrotherapy'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Massages Tab Content
            ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const WellnessHeader(
                  title: 'Wellness Massages',
                  subtitle:
                      'Indulge in our curated selection of therapeutic body treatments designed for ultimate relaxation.',
                ),
                const SizedBox(height: 16),
                ...dummyMassages.map(
                  (service) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ServiceCard(service: service),
                  ),
                ),
              ],
            ),
            // Placeholders for other tabs
            const Center(child: Text('Facials Content')),
            const Center(child: Text('Scrubs Content')),
            const Center(child: Text('Hydrotherapy Content')),
          ],
        ),
      ),
    );
  }
}

// --- REUSABLE WIDGETS ---

class WellnessHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const WellnessHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppFonts.poppinsSemiBold(color: AppTheme.primaryText, fontSize: 20), // Primary Dark Text (Headers)
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: AppFonts.poppinsRegular(color: AppTheme.secondaryText, fontSize: 14), // Supporting text based on theme mapping
        ),
      ],
    );
  }
}

class ServiceCard extends StatelessWidget {
  final ServiceItem service;

  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Always use Theme.of(context)

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor, // Main Background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline, // Borders/Dividers
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Section
          Image.network(
            service.imageUrl,
            height: 200,
            fit: BoxFit.cover,
            // Error builder in case the placeholder fails
            errorBuilder: (context, error, stackTrace) => Container(
              height: 200,
              color: theme.colorScheme.surfaceContainerHighest,
              child: const Center(child: Icon(Icons.broken_image)),
            ),
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
                  children: [
                    Expanded(
                      child: Text(
                        service.title,
                        style: AppFonts.poppinsSemiBold(color: AppTheme.primaryText, fontSize: 16), // Primary Dark Text
                      ),
                    ),
                    Text(
                      service.price,
                      style: AppFonts.poppinsSemiBold(
                        color: AppColors.primaryColor, // Price highlighted with primary color
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Duration Row
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.primaryBlack40, // Secondary Grey
                    ),
                    const SizedBox(width: 4),
                    Text(
                      service.duration,
                      style: AppFonts.poppinsRegular(color: AppColors.primaryBlack40, fontSize: 13), // Secondary Grey Text
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  service.description,
                  style: AppFonts.poppinsRegular(color: AppTheme.secondaryText, fontSize: 14), // Standard body text
                ),
                const SizedBox(height: 16),

                // Action Button - Relying on global styling
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ServiceDetailsPage(),
                      ),
                    );
                    },
                    child: const Text('BOOK APPOINTMENT'),
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
