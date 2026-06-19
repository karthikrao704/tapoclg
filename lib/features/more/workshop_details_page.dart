import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/core/widgets/failed_image_cache.dart';
import 'package:tapovana_mobile_app/core/widgets/custom_video_player.dart';
import 'package:tapovana_mobile_app/core/widgets/review_section.dart';
import 'models/more_models.dart';

class WorkshopDetailsPage extends StatefulWidget {
  final FeaturedWorkshop workshop;

  const WorkshopDetailsPage({super.key, required this.workshop});

  @override
  State<WorkshopDetailsPage> createState() => _WorkshopDetailsPageState();
}

class _WorkshopDetailsPageState extends State<WorkshopDetailsPage> {
  bool _hasStartedPlaying = false;

  Widget _buildHeaderFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5EDD8), Color(0xFFE8D5B0)],
        ),
      ),
      child: const Icon(
        Icons.self_improvement_outlined,
        size: 64,
        color: Color(0xFFD9A04B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Collapsible Image Header
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.workshop.imagePath != null && widget.workshop.imagePath!.isNotEmpty && !FailedImageCache.isFailed(widget.workshop.imagePath)
                      ? (widget.workshop.imagePath!.startsWith('http')
                          ? Image.network(
                              widget.workshop.imagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                FailedImageCache.markFailed(widget.workshop.imagePath);
                                return _buildHeaderFallback();
                              },
                            )
                          : Image.asset(
                              widget.workshop.imagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                FailedImageCache.markFailed(widget.workshop.imagePath);
                                return _buildHeaderFallback();
                              },
                            ))
                      : _buildHeaderFallback(),
                  // Dark bottom overlay
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black26,
                            Colors.transparent,
                            Colors.black87,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Title overlay
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.workshop.tag,
                            style: AppFonts.poppinsSemiBold(
                              color: Colors.white,
                              fontSize: 9,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.workshop.title.replaceAll('\n', ' '),
                          style: AppFonts.headland(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.workshop.time} • ${widget.workshop.duration}',
                          style: AppFonts.poppinsMedium(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description Section
                  if (widget.workshop.description.isNotEmpty) ...[
                    _sectionHeader("Description"),
                    const SizedBox(height: 10),
                    Text(
                      widget.workshop.description,
                      style: AppFonts.poppinsRegular(
                        color: AppTheme.secondaryText,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Video Section
                  if (widget.workshop.youtubeVideoUrl.isNotEmpty) ...[
                    _sectionHeader("Video Tutorial & Practice"),
                    const SizedBox(height: 12),
                    _buildVideoCard(context),
                    const SizedBox(height: 28),
                  ],

                  // Participant Feedback Section
                  ReviewSection(
                    title: "Participant Feedback",
                    reviews: MockReviews.workshopFeedback,
                    averageRating: 4.8,
                    moduleType: 'workshop',
                    itemTitle: widget.workshop.title,
                  ),
                  const SizedBox(height: 28),

                  // Enroll Now Button
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Enrollment functionality coming soon!")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Enroll Now",
                        style: AppFonts.poppinsSemiBold(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildVideoCard(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Native Custom Video Player (only mounted when user starts playing)
          if (_hasStartedPlaying && widget.workshop.youtubeVideoUrl.isNotEmpty)
            CustomVideoPlayer(videoUrl: widget.workshop.youtubeVideoUrl)
          else
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  if (widget.workshop.youtubeVideoUrl.isNotEmpty) {
                    setState(() {
                      _hasStartedPlaying = true;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No video tutorial available for this workshop.")),
                    );
                  }
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Thumbnail background
                    widget.workshop.imagePath != null && widget.workshop.imagePath!.isNotEmpty && !FailedImageCache.isFailed(widget.workshop.imagePath)
                        ? (widget.workshop.imagePath!.startsWith('http')
                            ? Image.network(
                                widget.workshop.imagePath!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  FailedImageCache.markFailed(widget.workshop.imagePath);
                                  return Container(color: const Color(0xFFCBD5E1));
                                },
                              )
                            : Image.asset(
                                widget.workshop.imagePath!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  FailedImageCache.markFailed(widget.workshop.imagePath);
                                  return Container(color: const Color(0xFFCBD5E1));
                                },
                              ))
                        : Container(color: const Color(0xFFCBD5E1)),
                    // Dark overlay
                    Container(color: Colors.black45),
                    // Custom Play Button
                    Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    // Video title & hint at the bottom
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 12,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Tap to play video tutorial",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.poppinsMedium(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }



  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 1.5,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppFonts.poppinsSemiBold(
            color: AppTheme.primaryText,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
