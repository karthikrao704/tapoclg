import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/core/widgets/secondary_app_bar.dart';
import 'package:tapovana_mobile_app/features/services/bloc/service_cubit.dart';
import 'package:tapovana_mobile_app/features/services/bloc/service_state.dart';
import 'package:tapovana_mobile_app/features/services/data/models/service_model.dart';
import 'package:tapovana_mobile_app/features/services/data/repositories/service_repository.dart';
import 'package:tapovana_mobile_app/features/service_details/presentation/pages/service_details_page.dart';

/// A reusable screen that fetches and displays services for a given [category].
///
/// It groups services by their [subcategory] and renders each subcategory
/// as a separate tab. If a service's subcategory doesn't match any provided
/// tab label, it falls into the first ("All") tab.
class CategoryServiceListScreen extends StatelessWidget {
  /// The title displayed in the AppBar (e.g. "Body Care").
  final String title;

  /// The exact category string from the API (e.g. "Body Care", "Skin Care").
  final String apiCategory;

  /// Labels for the tab bar. The first tab should generally be "All".
  /// Remaining tabs should match the API subcategory values.
  final List<String> tabLabels;

  const CategoryServiceListScreen({
    super.key,
    required this.title,
    required this.apiCategory,
    required this.tabLabels,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceCubit(repository: ServiceRepository())
        ..fetchServicesByCategory(apiCategory),
      child: _CategoryServiceContent(
        title: title,
        tabLabels: tabLabels,
      ),
    );
  }
}

class _CategoryServiceContent extends StatelessWidget {
  final String title;
  final List<String> tabLabels;

  const _CategoryServiceContent({
    required this.title,
    required this.tabLabels,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabLabels.length,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: SecondaryAppBar(
          title: title,
          bottom: TabBar(
            labelColor: AppColors.primaryColor,
            dividerColor: Colors.transparent,
            unselectedLabelColor: AppTheme.secondaryText,
            indicatorColor: AppColors.primaryColor,
            labelStyle: AppFonts.poppinsSemiBold(fontSize: 14),
            unselectedLabelStyle: AppFonts.poppinsRegular(fontSize: 14),
            isScrollable: tabLabels.length > 3,
            tabAlignment:
                tabLabels.length > 3 ? TabAlignment.center : TabAlignment.fill,
            tabs: tabLabels.map((label) => Tab(text: label)).toList(),
          ),
        ),
        body: BlocBuilder<ServiceCubit, ServiceState>(
          builder: (context, state) {
            if (state is ServiceLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.tealBlue),
              );
            }

            if (state is ServiceError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.red.shade300, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load services',
                      style: AppFonts.poppinsSemiBold(
                        fontSize: 16,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: AppFonts.poppinsRegular(
                          fontSize: 13,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Re-trigger fetch; we access the cubit via context
                        context.read<ServiceCubit>().fetchServices();
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is ServiceLoaded) {
              final allServices = state.services;

              return TabBarView(
                children: tabLabels.map((label) {
                  // First tab ("All") shows everything; others filter by subcategory
                  final isAllTab = tabLabels.indexOf(label) == 0;
                  final filtered = isAllTab
                      ? allServices
                      : allServices
                          .where((s) =>
                              s.subcategory.toLowerCase() ==
                              label.toLowerCase())
                          .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.spa_outlined,
                              size: 48,
                              color: AppColors.primaryColor.withAlpha(100)),
                          const SizedBox(height: 12),
                          Text(
                            'No services available',
                            style: AppFonts.poppinsRegular(
                              fontSize: 15,
                              color: AppTheme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _ApiServiceCard(service: filtered[index]);
                    },
                  );
                }).toList(),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// ─── Reusable Service Card (API-driven) ─────────────────────────────────────

class _ApiServiceCard extends StatelessWidget {
  final ServiceModel service;

  const _ApiServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailsPage(serviceId: service.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withAlpha(50),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            AspectRatio(
              aspectRatio: 16 / 9,
              child: service.imageUrl != null && service.imageUrl!.isNotEmpty
                  ? Image.network(
                      service.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildPlaceholderImage(service),
                    )
                  : _buildPlaceholderImage(service),
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
                          service.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.poppinsSemiBold(
                            color: AppTheme.primaryText,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        service.formattedPrice,
                        style: AppFonts.poppinsSemiBold(
                          color: AppColors.primaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Duration and subcategory
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 14, color: AppColors.primaryBlack40),
                      const SizedBox(width: 4),
                      Text(
                        service.formattedDuration,
                        style: AppFonts.poppinsRegular(
                          color: AppColors.primaryBlack40,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('•',
                          style: AppFonts.poppinsRegular(
                              color: AppColors.primaryBlack40, fontSize: 13)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            service.subcategory,
                            style: AppFonts.poppinsSemiBold(
                              color: AppColors.primaryColor,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ServiceDetailsPage(serviceId: service.id),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('BOOK APPOINTMENT'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(ServiceModel service) {
    return Container(
      color: AppColors.tagBackground,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.spa_outlined,
              size: 40,
              color: AppColors.primaryColor.withAlpha(150),
            ),
            const SizedBox(height: 4),
            Text(
              service.subcategory,
              style: AppFonts.poppinsRegular(
                fontSize: 12,
                color: AppColors.primaryColor.withAlpha(150),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
