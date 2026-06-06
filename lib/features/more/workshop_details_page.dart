import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/core/widgets/failed_image_cache.dart';
import 'package:tapovana_mobile_app/core/widgets/custom_video_player.dart';
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
                  // Progress section
                  _buildProgressSection(context),
                  const SizedBox(height: 28),

                  // Video Section
                  _sectionHeader("Video Tutorial & Practice"),
                  const SizedBox(height: 12),
                  _buildVideoCard(context),
                  const SizedBox(height: 28),

                  // Theory Section
                  _sectionHeader("Theory & Core Principles"),
                  const SizedBox(height: 10),
                  Text(
                    widget.workshop.theory,
                    style: AppFonts.poppinsRegular(
                      color: AppTheme.secondaryText,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Modules checklist
                  _sectionHeader("Workshop Syllabus"),
                  const SizedBox(height: 14),
                  _buildModulesList(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    final percent = (widget.workshop.progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Workshop Progress",
                style: AppFonts.poppinsSemiBold(
                  fontSize: 14,
                  color: AppTheme.primaryText,
                ),
              ),
              Text(
                "$percent% Complete",
                style: AppFonts.poppinsSemiBold(
                  fontSize: 14,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: widget.workshop.progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
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

  Widget _buildModulesList(BuildContext context) {
    return Column(
      children: List.generate(widget.workshop.modules.length, (index) {
        final moduleTitle = widget.workshop.modules[index];
        final isCompleted = widget.workshop.moduleCompleted[index];
        final isInProgress = !isCompleted &&
            (index == 0 || widget.workshop.moduleCompleted[index - 1]);
        final isLocked = !isCompleted && !isInProgress;

        Color itemBgColor = Colors.white;
        Color borderCol = const Color(0xFFE2E8F0);
        Widget trailingWidget;

        if (isCompleted) {
          itemBgColor = const Color(0xFFF0FDF4);
          borderCol = const Color(0xFFDCFCE7);
          trailingWidget = const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 22);
        } else if (isInProgress) {
          itemBgColor = const Color(0xFFFFFBEB);
          borderCol = const Color(0xFFFEF3C7);
          trailingWidget = Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "IN PROGRESS",
              style: AppFonts.poppinsSemiBold(
                fontSize: 9,
                color: const Color(0xFFD97706),
              ),
            ),
          );
        } else {
          trailingWidget = const Icon(Icons.lock_outline, color: Color(0xFF94A3B8), size: 20);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: itemBgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderCol),
          ),
          child: Row(
            children: [
              // Index
              Text(
                (index + 1).toString().padLeft(2, '0'),
                style: AppFonts.poppinsSemiBold(
                  fontSize: 16,
                  color: isLocked ? const Color(0xFF94A3B8) : AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 16),

              // Title
              Expanded(
                child: Text(
                  moduleTitle,
                  style: AppFonts.poppinsMedium(
                    fontSize: 14,
                    color: isLocked ? const Color(0xFF94A3B8) : AppTheme.primaryText,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Status indicator
              trailingWidget,
            ],
          ),
        );
      }),
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
