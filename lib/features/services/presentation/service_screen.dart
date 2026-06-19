import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/features/services/presentation/components/custom_search_bar.dart';
import 'package:tapovana_mobile_app/features/services/presentation/screens/service_list_section.dart';
import 'package:tapovana_mobile_app/core/theme/theme_cubit.dart';
import 'package:tapovana_mobile_app/features/services/bloc/service_cubit.dart';
import 'package:tapovana_mobile_app/features/services/bloc/service_state.dart';
import 'package:tapovana_mobile_app/features/services/data/repositories/service_repository.dart';
import 'package:tapovana_mobile_app/features/services/data/models/service_model.dart';
import 'package:tapovana_mobile_app/features/service_details/presentation/pages/service_details_page.dart';
import 'package:tapovana_mobile_app/features/appointments/presentation/pages/appointment_booking_page.dart';
import 'package:tapovana_mobile_app/core/widgets/media_helper.dart';

class ServiceScreen extends StatelessWidget {
  const ServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceCubit(repository: ServiceRepository())..fetchServices(),
      child: const ServiceScreenContent(),
    );
  }
}

class ServiceScreenContent extends StatefulWidget {
  const ServiceScreenContent({super.key});

  @override
  State<ServiceScreenContent> createState() => _ServiceScreenContentState();
}

class _ServiceScreenContentState extends State<ServiceScreenContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSearching = _searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Wellness Services',
          style: AppFonts.headland(
            fontSize: 22,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: theme.brightness == Brightness.dark
                  ? Colors.amberAccent
                  : AppTheme.primaryText,
            ),
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: CustomSearchBar(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  onClear: _clearSearch,
                ),
              ),
            ),
            if (!isSearching)
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: theme.colorScheme.primary,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorWeight: 3.0,
                    dividerColor: Colors.transparent,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.colorScheme.outline,
                    labelStyle: AppFonts.poppinsSemiBold(fontSize: 14),
                    unselectedLabelStyle: AppFonts.poppinsRegular(fontSize: 14),
                    isScrollable: false,
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                    tabs: const [
                      Tab(text: "All Services"),
                      Tab(text: "Popular"),
                      Tab(text: "Packages"),
                      Tab(text: "Offers"),
                    ],
                  ),
                  backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF0F172A) : Colors.white,
                ),
              ),
          ];
        },
        body: isSearching
            ? _buildSearchResults(context)
            : TabBarView(
                controller: _tabController,
                children: const [
                  ListScreen(),
                  _PopularTab(),
                  _PackagesTab(),
                  _OffersTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    return BlocBuilder<ServiceCubit, ServiceState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        if (state is ServiceLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.tealBlue,
            ),
          );
        }

        if (state is ServiceError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Failed to load services",
                    style: AppFonts.poppinsRegular(
                      color: Colors.redAccent,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      context.read<ServiceCubit>().fetchServices();
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text("Retry"),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is ServiceLoaded) {
          final query = _searchQuery.toLowerCase();
          final filtered = state.services.where((s) {
            return s.name.toLowerCase().contains(query) ||
                s.category.toLowerCase().contains(query) ||
                s.subcategory.toLowerCase().contains(query);
          }).toList();

          if (filtered.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.spa_outlined,
                      size: 64,
                      color: AppColors.primaryColor.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No services found",
                      style: AppFonts.poppinsSemiBold(
                        fontSize: 18,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Try searching for something else, e.g. 'massage' or 'hair'",
                      textAlign: TextAlign.center,
                      style: AppFonts.poppinsRegular(
                        fontSize: 14,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white70
                            : AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _SearchServiceCard(service: filtered[index]);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//   Sub-tabs Content Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _PopularTab extends StatelessWidget {
  const _PopularTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceCubit, ServiceState>(
      builder: (context, state) {
        if (state is ServiceLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.tealBlue,
            ),
          );
        }

        if (state is ServiceError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Failed to load popular services",
                  style: AppFonts.poppinsRegular(
                    color: Colors.redAccent,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    context.read<ServiceCubit>().fetchServices();
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text("Retry"),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is ServiceLoaded) {
          // Curate first 6 services as Popular
          final popularServices = state.services.take(6).toList();

          if (popularServices.isEmpty) {
            return Center(
              child: Text(
                "No popular services available",
                style: AppFonts.poppinsRegular(
                  color: AppColors.primaryBlack40,
                  fontSize: 14,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: popularServices.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _SearchServiceCard(
                service: popularServices[index],
                isPopular: true,
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _PackagesTab extends StatelessWidget {
  const _PackagesTab();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: _spaPackages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final package = _spaPackages[index];
        final theme = Theme.of(context);

        return Container(
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF1E293B)
                : theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withAlpha(20)
                  : theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image/Header Banner
              Stack(
                children: [
                  Image.asset(
                    package.image,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      color: AppColors.tagBackground,
                      child: Center(
                        child: Icon(
                          Icons.spa_outlined,
                          size: 48,
                          color: AppColors.primaryColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "WELLNESS PACKAGE",
                        style: AppFonts.poppinsSemiBold(
                          color: Colors.white,
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            package.duration,
                            style: AppFonts.poppinsMedium(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Content Details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.title,
                      style: AppFonts.poppinsSemiBold(
                        fontSize: 18,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      package.description,
                      style: AppFonts.poppinsRegular(
                        fontSize: 13,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white70
                            : AppTheme.secondaryText,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "What's Included:",
                      style: AppFonts.poppinsSemiBold(
                        fontSize: 12,
                        color: AppColors.primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Inclusions
                    Column(
                      children: package.inclusions.map((inclusion) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: Color(0xFFC9A14A),
                                size: 14,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  inclusion,
                                  style: AppFonts.poppinsRegular(
                                    fontSize: 13,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const Divider(height: 24, thickness: 0.5),

                    // Price & Booking Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "PACKAGE VALUE",
                              style: AppFonts.poppinsRegular(
                                fontSize: 9,
                                letterSpacing: 0.5,
                                color: AppColors.primaryBlack40,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  package.price,
                                  style: AppFonts.poppinsSemiBold(
                                    fontSize: 20,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  package.originalPrice,
                                  style: AppFonts.poppinsRegular(
                                    fontSize: 13,
                                    color: AppColors.primaryBlack40,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(
                                builder: (_) => AppointmentBookingPage(
                                  serviceName: package.title,
                                  price: package.price,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "BOOK NOW",
                            style: AppFonts.poppinsSemiBold(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OffersTab extends StatelessWidget {
  const _OffersTab();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: _wellnessOffers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final offer = _wellnessOffers[index];
        final theme = Theme.of(context);

        return Container(
          height: 150,
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF1E293B)
                : theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withAlpha(20)
                  : theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              // Left Badge
              Container(
                width: 100,
                color: const Color(0xFFC9A14A),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      offer.icon,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      offer.discount.split(' ')[0],
                      style: AppFonts.poppinsSemiBold(
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      offer.discount.split(' ').skip(1).join(' '),
                      style: AppFonts.poppinsRegular(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                width: 1,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(vertical: 10),
              ),

              // Content details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.poppinsSemiBold(
                              fontSize: 15,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            offer.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.poppinsRegular(
                              fontSize: 11,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.white70
                                  : AppTheme.secondaryText,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => _copyPromoCode(context, offer.code),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white.withAlpha(15)
                                    : const Color(0xFFF7F5F0),
                                border: Border.all(
                                  color: const Color(0xFFC9A14A).withValues(alpha: 0.3),
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    offer.code,
                                    style: AppFonts.poppinsSemiBold(
                                      color: const Color(0xFFC9A14A),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.copy,
                                    size: 12,
                                    color: Color(0xFFC9A14A),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            offer.expiryDate,
                            style: AppFonts.poppinsRegular(
                              fontSize: 10,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
      },
    );
  }

  void _copyPromoCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Promo code $code copied to clipboard!"),
        backgroundColor: AppColors.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//   Shared Search / Popular Card Widget
// ─────────────────────────────────────────────────────────────────────────────

class _SearchServiceCard extends StatelessWidget {
  final ServiceModel service;
  final bool isPopular;

  const _SearchServiceCard({
    required this.service,
    this.isPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => ServiceDetailsPage(serviceId: service.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF1E293B)
              : theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withAlpha(20)
                : theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: MediaHelper.buildServiceImage(
                      service.imageUrl,
                      fit: BoxFit.cover,
                      fallbackWidget: _buildPlaceholderImage(service),
                    ),
                  ),
                  if (isPopular)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC9A14A),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "POPULAR",
                              style: AppFonts.poppinsSemiBold(
                                color: Colors.white,
                                fontSize: 9,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
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
                            color: AppColors.primaryColor.withValues(alpha: 0.1),
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
                        Navigator.of(context, rootNavigator: true).push(
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
              color: AppColors.primaryColor.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 4),
            Text(
              service.subcategory,
              style: AppFonts.poppinsRegular(
                fontSize: 12,
                color: AppColors.primaryColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _StickyTabBarDelegate(this.tabBar, {required this.backgroundColor});

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//   Data Models & Playlists
// ─────────────────────────────────────────────────────────────────────────────

class _SpaPackage {
  final String title;
  final String description;
  final List<String> inclusions;
  final String duration;
  final String price;
  final String originalPrice;
  final String image;

  const _SpaPackage({
    required this.title,
    required this.description,
    required this.inclusions,
    required this.duration,
    required this.price,
    required this.originalPrice,
    required this.image,
  });
}

final List<_SpaPackage> _spaPackages = [
  const _SpaPackage(
    title: 'Rejuvenating Escape',
    description: 'The ultimate body and mind reset. Ideal for releasing stress and reviving tired muscles.',
    inclusions: [
      'Aromatherapy Massage (60 Mins)',
      'Organic Walnut Body Scrub (30 Mins)',
      'Hydrating Ayurvedic Facial (30 Mins)',
      'Complimentary Chamomile Herbal Tea'
    ],
    duration: '120 Mins',
    price: '₹2,499',
    originalPrice: '₹3,500',
    image: 'assets/images/body_care.png',
  ),
  const _SpaPackage(
    title: 'Total Scalp & Hair Therapy',
    description: 'Traditional herbal therapy formulated to nourish hair roots, boost shine, and relax the head and neck.',
    inclusions: [
      'Warm Herbal Oil Infusion',
      'Organic Hydrating Scalp Mask',
      'Deep Head & Shoulder Massage',
      'Revitalizing Hair Wash & Blow Dry'
    ],
    duration: '90 Mins',
    price: '₹1,899',
    originalPrice: '₹2,600',
    image: 'assets/images/hair_care.png',
  ),
  const _SpaPackage(
    title: 'Ayurvedic Detox Ritual',
    description: 'A traditional wellness cleansing ceremony designed to eliminate deep toxins and restore internal energy flow.',
    inclusions: [
      'Abhyanga Massage (60 Mins)',
      'Shirodhara Oil Therapy (60 Mins)',
      'Steam Bath & Herbal Body Wash',
      'Warm Detoxifying Ginger Drink'
    ],
    duration: '150 Mins',
    price: '₹3,299',
    originalPrice: '₹4,800',
    image: 'assets/images/skin_care.png',
  ),
  const _SpaPackage(
    title: 'Deep Muscular Recovery',
    description: 'Designed for active individuals. Focuses on releasing deep muscle tension and improving body flexibility.',
    inclusions: [
      'Deep Tissue Massage (60 Mins)',
      'Warm Stones Therapy (30 Mins)',
      'Acupressure Foot Therapy (30 Mins)',
      'Organic Electrolyte Infusion'
    ],
    duration: '120 Mins',
    price: '₹2,799',
    originalPrice: '₹3,800',
    image: 'assets/images/body_care.png',
  ),
  const _SpaPackage(
    title: 'Radiant Bridal Glow',
    description: 'A complete top-to-toe beautifying treatment designed to restore natural skin glow and peace of mind.',
    inclusions: [
      'Brightening Gold Facial (60 Mins)',
      'Honey-Almond Body Polish (45 Mins)',
      'Nourishing Hair Spa Ritual (45 Mins)',
      'Rosewater & Saffron Elixir'
    ],
    duration: '150 Mins',
    price: '₹3,999',
    originalPrice: '₹5,500',
    image: 'assets/images/skin_care.png',
  ),
  const _SpaPackage(
    title: 'Calm & Sleep Therapy',
    description: 'A relaxing therapy focusing on calming the nervous system, promoting healthy sleep patterns and mental clarity.',
    inclusions: [
      'Shirodhara Warm Oil Therapy (45 Mins)',
      'Kansa Wand Foot Massage (30 Mins)',
      'Calming Head & Neck Shiro-abhyanga (15 Mins)',
      'Lavender-Chamomile Tea'
    ],
    duration: '90 Mins',
    price: '₹2,199',
    originalPrice: '₹3,000',
    image: 'assets/images/hair_care.png',
  ),
];

class _WellnessOffer {
  final String code;
  final String discount;
  final String title;
  final String description;
  final String expiryDate;
  final IconData icon;

  const _WellnessOffer({
    required this.code,
    required this.discount,
    required this.title,
    required this.description,
    required this.expiryDate,
    required this.icon,
  });
}

final List<_WellnessOffer> _wellnessOffers = [
  const _WellnessOffer(
    code: 'WELCOME20',
    discount: '20% OFF',
    title: 'First Booking Special',
    description: 'Get a 20% discount on any therapy or grooming session. Applicable for new accounts on their first checkout.',
    expiryDate: 'Expires 30 Jun, 2026',
    icon: Icons.card_giftcard,
  ),
  const _WellnessOffer(
    code: 'RENEW15',
    discount: '15% OFF',
    title: 'Midweek Renewal',
    description: 'Reclaim your peace. Enjoy 15% off on all wellness treatments booked between Monday and Thursday (9:00 AM - 1:00 PM).',
    expiryDate: 'Ongoing Promotion',
    icon: Icons.wb_sunny_outlined,
  ),
  const _WellnessOffer(
    code: 'AYUSH30',
    discount: '30% OFF',
    title: 'Ayurvedic Special',
    description: 'Book Shirodhara or Abhyanga treatments and get 30% discount on your second checkout of the same category.',
    expiryDate: 'Expires 15 Jun, 2026',
    icon: Icons.spa_outlined,
  ),
];
