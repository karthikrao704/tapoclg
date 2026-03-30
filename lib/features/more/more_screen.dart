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
                _buildAppBar(context),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      if (state.featuredWorkshop != null)
                        _FeaturedWorkshopSection(
                          workshop: state.featuredWorkshop!,
                        ),
                      const SizedBox(height: 28),
                      if (state.vedicPackages.isNotEmpty)
                        _VedicPackagesSection(packages: state.vedicPackages),
                      const SizedBox(height: 28),
                      if (state.educationalCourses.isNotEmpty)
                        _EducationalCoursesSection(
                          courses: state.educationalCourses,
                        ),
                      const SizedBox(height: 28),
                      if (state.blogPosts.isNotEmpty)
                        _WellnessBlogSection(posts: state.blogPosts),
                      const SizedBox(height: 32),
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

  SliverAppBar _buildAppBar(BuildContext context) {
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
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: AppTheme.primaryText,
        ),
      ),
      actions: [
        NotificationBell(
          size: 40,
          onPressed: () {},
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
  final FeaturedWorkshop workshop;
  const _FeaturedWorkshopSection({required this.workshop});

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
              fontSize: 18,
              color: AppTheme.primaryText,
            ),
          ),
        ),
        const SizedBox(height: 14),
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
                child: _WorkshopImagePlaceholder(imagePath: workshop.imagePath),
              ),

              // Workshop details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tag + Date row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          workshop.tag,
                          style: AppFonts.poppinsSemiBold(
                            fontSize: 11,
                            color: AppColors.primaryColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F7F2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            workshop.date,
                            style: AppFonts.poppinsMedium(
                              fontSize: 13,
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
                      style: AppFonts.poppinsSemiBold(
                        fontSize: 20,
                        color: AppTheme.primaryText,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      workshop.description,
                      style: AppFonts.poppinsRegular(
                        fontSize: 13,
                        color: AppTheme.secondaryText,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Time + Join button
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_outlined,
                          size: 15,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${workshop.time} • ${workshop.duration}',
                          style: AppFonts.poppinsRegular(
                            fontSize: 13,
                            color: AppColors.primaryBlack40,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD9A04B),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Join',
                            style: AppFonts.poppinsSemiBold(
                              fontSize: 14,
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

/// Image placeholder for workshop — swap imagePath when user provides images
class _WorkshopImagePlaceholder extends StatelessWidget {
  final String? imagePath;
  const _WorkshopImagePlaceholder({this.imagePath});

  @override
  Widget build(BuildContext context) {
    if (imagePath != null) {
      return Image.asset(
        imagePath!,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    // Placeholder shown until real image is provided
    return Container(
      height: 200,
      width: double.infinity,
      color: const Color(0xFFE8E0D0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_outlined, size: 48, color: Color(0xFFB0A090)),
          const SizedBox(height: 8),
          Text(
            'Workshop Image',
            style: AppFonts.poppinsRegular(
              color: const Color(0xFFB0A090),
              fontSize: 13,
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
  const _VedicPackagesSection({required this.packages});

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
              fontSize: 18,
              color: AppTheme.primaryText,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: packages.map((pkg) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: pkg == packages.last ? 0 : 12,
                  ),
                  child: _PackageCard(package: pkg),
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
  const _PackageCard({required this.package});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image area — fixed height so both cards are always identical
        SizedBox(
          height: 140,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _PackageImagePlaceholder(imagePath: package.imagePath),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          package.title,
          style: AppFonts.poppinsSemiBold(
            fontSize: 14,
            color: AppTheme.primaryText,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          package.subtitle,
          style: AppFonts.poppinsRegular(
            fontSize: 12,
            color: AppColors.primaryBlack40,
          ),
        ),
      ],
    );
  }
}

/// Image placeholder for packages — swap imagePath when user provides images
class _PackageImagePlaceholder extends StatelessWidget {
  final String? imagePath;
  const _PackageImagePlaceholder({this.imagePath});

  @override
  Widget build(BuildContext context) {
    if (imagePath != null) {
      return Image.asset(imagePath!, fit: BoxFit.cover, width: double.infinity);
    }
    return Container(
      height: 140,
      width: double.infinity,
      color: const Color(0xFFD8E8C8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.nature_outlined, size: 36, color: Color(0xFF90A880)),
          const SizedBox(height: 6),
          Text(
            'Package Image',
            style: AppFonts.poppinsRegular(
              color: const Color(0xFF90A880),
              fontSize: 11,
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
  const _EducationalCoursesSection({required this.courses});

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
              Text(
                'Educational Courses',
                style: AppFonts.poppinsSemiBold(
                  fontSize: 18,
                  color: AppTheme.primaryText,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'VIEW ALL',
                  style: AppFonts.poppinsSemiBold(
                    fontSize: 13,
                    color: AppColors.primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
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
                  _CourseRow(course: course),
                  if (idx < courses.length - 1)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF1F5F9),
                      indent: 68,
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
  const _CourseRow({required this.course});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 44,
            height: 44,
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
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: AppFonts.poppinsMedium(
                    fontSize: 15,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${course.lessons} • ${course.level}',
                  style: AppFonts.poppinsRegular(
                    fontSize: 12,
                    color: AppColors.primaryBlack40,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 22),
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
  const _WellnessBlogSection({required this.posts});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 20) * 0.60;
    const imageHeight = 180.0;
    const totalHeight = 260.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Wellness Blog',
            style: AppFonts.poppinsSemiBold(
              fontSize: 18,
              color: AppTheme.primaryText,
            ),
          ),
        ),
        const SizedBox(height: 14),
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
  const _BlogCard({
    required this.post,
    required this.cardWidth,
    required this.imageHeight,
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
                        child: const Center(
                          child: Icon(
                            Icons.spa_outlined,
                            size: 36,
                            color: Color(0xFF907060),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            // Category label below image
            Text(
              post.category,
              style: AppFonts.poppinsSemiBold(
                fontSize: 11,
                color: AppColors.primaryColor,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 4),
            // Title below category
            Text(
              post.title,
              style: AppFonts.poppinsSemiBold(
                fontSize: 16,
                color: AppTheme.primaryText,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
