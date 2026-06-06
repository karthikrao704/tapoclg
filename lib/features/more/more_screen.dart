import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tapovana_mobile_app/core/theme/theme_cubit.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/core/widgets/failed_image_cache.dart';
import 'bloc/more_bloc.dart';
import 'models/more_models.dart';
import 'vedic_package_details_page.dart';
import 'wellness_blog_details_page.dart';
import 'workshop_details_page.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MoreBloc()..add(const LoadMoreContent()),
      child: const _MoreView(),
    );
  }
}

class _MoreView extends StatelessWidget {
  const _MoreView();

  @override
  Widget build(BuildContext context) {
    // 1. Establish central breakpoints for the entire screen
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.height < 650;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<MoreBloc, MoreState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFD9A04B)),
            );
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    state.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<MoreBloc>().add(
                      const RefreshMoreContent(),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFFD9A04B),
            onRefresh: () async {
              context.read<MoreBloc>().add(const RefreshMoreContent());
              await Future.delayed(const Duration(milliseconds: 800));
            },
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context, isSmallScreen),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      if (state.workshops.isNotEmpty)
                        _FeaturedWorkshopSection(
                          workshops: state.workshops,
                          isSmallScreen: isSmallScreen,
                        ),
                      SizedBox(height: isSmallScreen ? 20 : 28),
                      if (state.vedicPackages.isNotEmpty)
                        _VedicPackagesSection(
                          packages: state.vedicPackages,
                          isSmallScreen: isSmallScreen,
                        ),
                      SizedBox(height: isSmallScreen ? 20 : 28),
                      if (state.blogPosts.isNotEmpty)
                        _WellnessBlogSection(
                          posts: state.blogPosts,
                          isSmallScreen: isSmallScreen,
                        ),
                      SizedBox(height: isSmallScreen ? 24 : 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, bool isSmallScreen) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      floating: true,
      snap: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text(
        'Explore more',
        overflow: TextOverflow.ellipsis,
        style: AppFonts.headland(
          fontSize: isSmallScreen ? 18 : 20,
          fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.amberAccent
                : AppTheme.primaryText,
          ),
          onPressed: () {
            context.read<ThemeCubit>().toggleTheme();
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Featured Workshop Section
// ─────────────────────────────────────────────
class _FeaturedWorkshopSection extends StatelessWidget {
  final List<FeaturedWorkshop> workshops;
  final bool isSmallScreen;

  const _FeaturedWorkshopSection({
    required this.workshops,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final double cardWidth = isSmallScreen ? 280.0 : 340.0;
    final double listHeight = isSmallScreen ? 320.0 : 410.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Featured Workshops',
            style: AppFonts.poppinsSemiBold(
              fontSize: isSmallScreen ? 16 : 18,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 10 : 14),
        SizedBox(
          height: listHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20, right: 4),
            itemCount: workshops.length,
            itemBuilder: (context, index) {
              final workshop = workshops[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16, bottom: 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkshopDetailsPage(workshop: workshop),
                      ),
                    );
                  },
                  child: Container(
                    width: cardWidth,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E293B)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withAlpha(20)
                            : Colors.transparent,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Workshop image area
                        _WorkshopImagePlaceholder(
                          imagePath: workshop.imagePath,
                          isSmallScreen: isSmallScreen,
                        ),

                        // Workshop details
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Tag + Date row
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            workshop.tag,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppFonts.poppinsSemiBold(
                                              fontSize: isSmallScreen ? 10 : 11,
                                              color: AppColors.primaryColor,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmallScreen ? 8 : 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).brightness == Brightness.dark
                                                ? Colors.white.withAlpha(15)
                                                : const Color(0xFFF9F7F2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            workshop.date,
                                            style: AppFonts.poppinsMedium(
                                              fontSize: isSmallScreen ? 11 : 13,
                                              color: Theme.of(context).brightness == Brightness.dark
                                                  ? Colors.white70
                                                  : AppTheme.secondaryText,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Title
                                    Text(
                                      workshop.title.replaceAll('\n', ' '),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFonts.poppinsSemiBold(
                                        fontSize: isSmallScreen ? 15 : 18,
                                        color: Theme.of(context).colorScheme.onSurface,
                                        height: 1.25,
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    // Description
                                    Text(
                                      workshop.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFonts.poppinsRegular(
                                        fontSize: isSmallScreen ? 11 : 12,
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? Colors.white70
                                            : AppTheme.secondaryText,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),

                                // Time + Join button
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_outlined,
                                      size: 15,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        '${workshop.time} • ${workshop.duration}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppFonts.poppinsRegular(
                                          fontSize: isSmallScreen ? 11 : 12,
                                          color: AppColors.primaryBlack40,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => WorkshopDetailsPage(workshop: workshop),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFD9A04B),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isSmallScreen ? 16 : 22,
                                          vertical: isSmallScreen ? 8 : 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: Text(
                                        'View',
                                        style: AppFonts.poppinsSemiBold(
                                          fontSize: isSmallScreen ? 11 : 13,
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
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WorkshopImagePlaceholder extends StatelessWidget {
  final String? imagePath;
  final bool isSmallScreen;

  const _WorkshopImagePlaceholder({
    this.imagePath,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    // 4. Responsive image bounds
    final double height = isSmallScreen ? 150 : 200;

    if (imagePath != null && imagePath!.isNotEmpty && !FailedImageCache.isFailed(imagePath)) {
      if (imagePath!.startsWith('http')) {
        return Image.network(
          imagePath!,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            FailedImageCache.markFailed(imagePath);
            return _buildFallback(height);
          },
        );
      } else {
        return Image.asset(
          imagePath!,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            FailedImageCache.markFailed(imagePath);
            return _buildFallback(height);
          },
        );
      }
    }

    return _buildFallback(height);
  }

  Widget _buildFallback(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: const Color(0xFFE8E0D0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: isSmallScreen ? 36 : 48,
            color: const Color(0xFFB0A090),
          ),
          const SizedBox(height: 8),
          Text(
            'Workshop Image',
            style: AppFonts.poppinsRegular(
              color: const Color(0xFFB0A090),
              fontSize: isSmallScreen ? 11 : 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Vedic Life Packages Section
// ─────────────────────────────────────────────
class _VedicPackagesSection extends StatelessWidget {
  final List<VedicPackage> packages;
  final bool isSmallScreen;

  const _VedicPackagesSection({
    required this.packages,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = isSmallScreen ? 130.0 : 170.0;
    final totalHeight = isSmallScreen ? 170.0 : 230.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Vedic Life Packages',
            style: AppFonts.poppinsSemiBold(
              fontSize: isSmallScreen ? 16 : 18,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 10 : 14),
        SizedBox(
          height: totalHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20, right: 8),
            itemCount: packages.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: cardWidth,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VedicPackageDetailsPage(
                            package: packages[index],
                          ),
                        ),
                      );
                    },
                    child: _PackageCard(
                      package: packages[index],
                      isSmallScreen: isSmallScreen,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  final VedicPackage package;
  final bool isSmallScreen;

  const _PackageCard({required this.package, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: isSmallScreen ? 90 : 130,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _PackageImagePlaceholder(
              imagePath: package.imagePath,
              isSmallScreen: isSmallScreen,
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 10),
        Text(
          package.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppFonts.poppinsSemiBold(
            fontSize: isSmallScreen ? 12 : 14,
            color: Theme.of(context).colorScheme.onSurface,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          package.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppFonts.poppinsRegular(
            fontSize: isSmallScreen ? 11 : 12,
            color: AppColors.primaryBlack40,
          ),
        ),
      ],
    );
  }
}

class _PackageImagePlaceholder extends StatelessWidget {
  final String? imagePath;
  final bool isSmallScreen;

  const _PackageImagePlaceholder({this.imagePath, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    if (imagePath != null) {
      return Image.asset(imagePath!, fit: BoxFit.cover, width: double.infinity);
    }
    return Container(
      width: double.infinity,
      color: const Color(0xFFD8E8C8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.nature_outlined,
            size: isSmallScreen ? 28 : 36,
            color: const Color(0xFF90A880),
          ),
          SizedBox(height: isSmallScreen ? 4 : 6),
          Text(
            'Package Image',
            style: AppFonts.poppinsRegular(
              color: const Color(0xFF90A880),
              fontSize: isSmallScreen ? 10 : 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Wellness Blog Section
// ─────────────────────────────────────────────
class _WellnessBlogSection extends StatelessWidget {
  final List<WellnessBlogPost> posts;
  final bool isSmallScreen;

  const _WellnessBlogSection({
    required this.posts,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    // 6. Dynamic Bounds calculation
    final screenWidth = MediaQuery.of(context).size.width;

    // Scale horizontal card width slightly larger on small screens to remain legible
    final cardWidth = (screenWidth - 20) * (isSmallScreen ? 0.70 : 0.60);

    // Scale the image height dynamically
    final imageHeight = isSmallScreen ? 140.0 : 180.0;

    // Scale the entire ListView buffer proportionally so text doesn't hit the floor
    final totalHeight = isSmallScreen ? 225.0 : 270.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Wellness Blog',
            style: AppFonts.poppinsSemiBold(
              fontSize: isSmallScreen ? 16 : 18,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 10 : 14),
        SizedBox(
          height: totalHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20, right: 8),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WellnessBlogDetailsPage(
                        post: posts[index],
                      ),
                    ),
                  );
                },
                child: _BlogCard(
                  post: posts[index],
                  cardWidth: cardWidth,
                  imageHeight: imageHeight,
                  isSmallScreen: isSmallScreen,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BlogCard extends StatelessWidget {
  final WellnessBlogPost post;
  final double cardWidth;
  final double imageHeight;
  final bool isSmallScreen;

  const _BlogCard({
    required this.post,
    required this.cardWidth,
    required this.imageHeight,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cardWidth,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image on top
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: post.imagePath != null
                    ? Image.asset(post.imagePath!, fit: BoxFit.fill)
                    : Container(
                        color: const Color(0xFFD0C4B0),
                        child: Center(
                          child: Icon(
                            Icons.spa_outlined,
                            size: isSmallScreen ? 28 : 36,
                            color: const Color(0xFF907060),
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 10),

            // Category label
            Text(
              post.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.poppinsSemiBold(
                fontSize: isSmallScreen ? 10 : 11,
                color: AppColors.primaryColor,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 4),

            // 1. Wrapped the title in Flexible to protect against vertical overflow!
            Flexible(
              child: Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.poppinsSemiBold(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
