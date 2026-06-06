import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'models/more_models.dart';

class WellnessBlogDetailsPage extends StatelessWidget {
  final WellnessBlogPost post;

  const WellnessBlogDetailsPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Collapsible Header Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.9),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.9),
                  child: IconButton(
                    icon: Icon(Icons.share_outlined, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Article link copied!"),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  post.imagePath != null
                      ? Image.asset(
                          post.imagePath!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: const Color(0xFFE2E8F0),
                          child: const Icon(
                            Icons.spa_outlined,
                            size: 64,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                  // Bottom fade overlay
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black12,
                            Colors.transparent,
                            Colors.black45,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Article Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      post.category,
                      style: AppFonts.poppinsSemiBold(
                        fontSize: 10,
                        color: AppColors.primaryColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    post.title,
                    style: AppFonts.headland(
                      fontSize: 26,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Author & Date row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primaryColor.withValues(alpha: 0.15),
                        child: Text(
                          post.author.isNotEmpty ? post.author[0].toUpperCase() : 'A',
                          style: AppFonts.poppinsSemiBold(
                            fontSize: 16,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.author,
                              style: AppFonts.poppinsSemiBold(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${post.date} • ${post.readTime}",
                              style: AppFonts.poppinsRegular(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.primaryBlack40,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : const Color(0xFFF1F5F9), thickness: 1),
                  const SizedBox(height: 16),

                  // Content Body
                  _BlogBodyRenderer(content: post.content),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlogBodyRenderer extends StatelessWidget {
  final String content;

  const _BlogBodyRenderer({required this.content});

  @override
  Widget build(BuildContext context) {
    final lines = content.split('\n');
    final List<Widget> widgets = [];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 12));
        continue;
      }

      if (line.startsWith('### ')) {
        final headingText = line.substring(4);
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(
            headingText,
            style: AppFonts.poppinsSemiBold(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ));
      } else if (line.startsWith('*') || (line.length > 2 && line.substring(1, 2) == '.' && line.contains('**'))) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: _buildRichTextLine(context, line),
        ));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 14.0),
          child: _buildRichTextLine(context, line),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildRichTextLine(BuildContext context, String line) {
    final parts = line.split('**');
    if (parts.length < 3) {
      return Text(
        line,
        style: AppFonts.poppinsRegular(
          fontSize: 15,
          color: Theme.of(context).textTheme.bodySmall?.color ?? AppTheme.secondaryText,
          height: 1.6,
        ),
      );
    }

    final spans = <TextSpan>[];
    for (var i = 0; i < parts.length; i++) {
      final isBold = i % 2 == 1;
      spans.add(TextSpan(
        text: parts[i],
        style: isBold
            ? AppFonts.poppinsSemiBold(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurface,
              )
            : AppFonts.poppinsRegular(
                fontSize: 15,
                color: Theme.of(context).textTheme.bodySmall?.color ?? AppTheme.secondaryText,
                height: 1.6,
              ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
