import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/core/widgets/notification_bell.dart';
import 'bloc/more_bloc.dart';
import 'models/more_models.dart';

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
      backgroundColor: const Color.fromARGB(255, 255, 255, 254),
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
                      if (state.featuredWorkshop != null)
                        _FeaturedWorkshopSection(
                          workshop: state.featuredWorkshop!,
                          isSmallScreen: isSmallScreen,
                        ),
                      SizedBox(height: isSmallScreen ? 20 : 28),
                      if (state.vedicPackages.isNotEmpty)
                        _VedicPackagesSection(
                          packages: state.vedicPackages,
                          isSmallScreen: isSmallScreen,
                        ),
                      SizedBox(height: isSmallScreen ? 20 : 28),
                      if (state.educationalCourses.isNotEmpty)
                        _EducationalCoursesSection(
                          courses: state.educationalCourses,
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
      backgroundColor: const Color.fromARGB(255, 253, 253, 252),
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
          color: AppTheme.primaryText,
        ),
      ),
      actions: [
        NotificationBell(size: isSmallScreen ? 34 : 40, onPressed: () {}),
        const SizedBox(width: 8),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Featured Workshop Section
// ─────────────────────────────────────────────
class _FeaturedWorkshopSection extends StatelessWidget {
  final FeaturedWorkshop workshop;
  final bool isSmallScreen;

  const _FeaturedWorkshopSection({
    required this.workshop,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Featured Workshop',
            style: AppFonts.poppinsSemiBold(
              fontSize: isSmallScreen ? 16 : 18,
              color: AppTheme.primaryText,
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 10 : 14),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Workshop image area
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: _WorkshopImagePlaceholder(
                  imagePath: workshop.imagePath,
                  isSmallScreen: isSmallScreen,
                ),
              ),

              // Workshop details
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tag + Date row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 2. Safely constrained with Flexible so tag and date don't collide
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
                            color: const Color(0xFFF9F7F2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            workshop.date,
                            style: AppFonts.poppinsMedium(
                              fontSize: isSmallScreen ? 11 : 13,
                              color: AppTheme.secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      workshop.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.poppinsSemiBold(
                        fontSize: isSmallScreen ? 16 : 20,
                        color: AppTheme.primaryText,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      workshop.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.poppinsRegular(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: AppTheme.secondaryText,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),

                    // Time + Join button
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_outlined,
                          size: 15,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        // 3. Ensuring string truncates if device scaling is extreme
                        Expanded(
                          child: Text(
                            '${workshop.time} • ${workshop.duration}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.poppinsRegular(
                              fontSize: isSmallScreen ? 11 : 13,
                              color: AppColors.primaryBlack40,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD9A04B),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 20 : 28,
                              vertical: isSmallScreen ? 10 : 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Join',
                            style: AppFonts.poppinsSemiBold(
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
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

    if (imagePath != null) {
      return Image.asset(
        imagePath!,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Vedic Life Packages',
            style: AppFonts.poppinsSemiBold(
              fontSize: isSmallScreen ? 16 : 18,
              color: AppTheme.primaryText,
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 10 : 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: packages.map((pkg) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: pkg == packages.last ? 0 : (isSmallScreen ? 8 : 12),
                  ),
                  child: _PackageCard(
                    package: pkg,
                    isSmallScreen: isSmallScreen,
                  ),
                ),
              );
            }).toList(),
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
          // 5. Scaled height so side-by-side cards don't look stretched
          height: isSmallScreen ? 100 : 140,
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
            color: AppTheme.primaryText,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          package.subtitle,
          maxLines: 2,
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
// Educational Courses Section
// ─────────────────────────────────────────────
class _EducationalCoursesSection extends StatelessWidget {
  final List<EducationalCourse> courses;
  final bool isSmallScreen;

  const _EducationalCoursesSection({
    required this.courses,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. Wrapped the title in Expanded to prevent right-side overflow
              Expanded(
                child: Text(
                  'Educational Courses',
                  // 2. Added truncation rules so it gracefully degrades
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.poppinsSemiBold(
                    fontSize: isSmallScreen ? 16 : 18,
                    color: AppTheme.primaryText,
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ), // 3. Added a small buffer between title and button
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'VIEW ALL',
                  style: AppFonts.poppinsSemiBold(
                    fontSize: isSmallScreen ? 11 : 13,
                    color: AppColors.primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 10),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: courses.asMap().entries.map((entry) {
              final idx = entry.key;
              final course = entry.value;
              return Column(
                children: [
                  _CourseRow(course: course, isSmallScreen: isSmallScreen),
                  if (idx < courses.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: const Color(0xFFF1F5F9),
                      indent: isSmallScreen ? 54 : 68,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _CourseRow extends StatelessWidget {
  final EducationalCourse course;
  final bool isSmallScreen;

  const _CourseRow({required this.course, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isSmallScreen ? 10 : 14,
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: isSmallScreen ? 36 : 44,
            height: isSmallScreen ? 36 : 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF5EDD8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                course.iconType == 'book'
                    ? Icons.menu_book_outlined
                    : Icons.self_improvement_outlined,
                color: const Color(0xFFD9A04B),
                size: isSmallScreen ? 18 : 22,
              ),
            ),
          ),
          SizedBox(width: isSmallScreen ? 10 : 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.poppinsMedium(
                    fontSize: isSmallScreen ? 13 : 15,
                    color: AppTheme.primaryText,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${course.lessons} • ${course.level}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.poppinsRegular(
                    fontSize: isSmallScreen ? 11 : 12,
                    color: AppColors.primaryBlack40,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            color: const Color(0xFFCBD5E1),
            size: isSmallScreen ? 20 : 22,
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
              color: AppTheme.primaryText,
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
              return _BlogCard(
                post: posts[index],
                cardWidth: cardWidth,
                imageHeight: imageHeight,
                isSmallScreen: isSmallScreen,
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
                  color: AppTheme.primaryText,
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
