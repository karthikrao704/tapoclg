import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';

class SecondaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearch;
  final PreferredSizeWidget? bottom;
  final List<Widget>? actions;
  final bool centerTitle;
  final double? titleSpacing;

  const SecondaryAppBar({
    super.key,
    required this.title,
    this.showSearch = true,
    this.bottom,
    this.actions,
    this.centerTitle = true,
    this.titleSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? Colors.white : const Color(0xFF333333),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: titleSpacing,
      title: Text(
        title,
        style: AppFonts.headland(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
      ),
      centerTitle: centerTitle,
      actions: [
        if (showSearch)
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.primaryColor),
            onPressed: () {}, // UI Placeholder
          ),
        if (actions != null) ...actions!,
        const SizedBox(width: 8),
      ],
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
      kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
