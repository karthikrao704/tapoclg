import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';

/// Simple data model to hold category information
class CategoryData {
  final String title;
  final String icon;

  const CategoryData({required this.title, required this.icon});
}

class CategoriesSection extends StatelessWidget {
  final List<CategoryData> categories;
  final int selectedIndex;
  final ValueChanged<int> onCategoryTapped;

  const CategoriesSection({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategoryTapped,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(categories.length, (index) {
          final isSelected = index == selectedIndex;
          final category = categories[index];

          return Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: _CategoryItem(
              category: category,
              isSelected: isSelected,
              onTap: () => onCategoryTapped(index),
            ),
          );
        }),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final CategoryData category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          // AnimatedContainer provides a smooth transition when selection changes
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryColor.withAlpha(50)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22.0),
              child: SvgPicture.asset(
                category.icon,
                colorFilter: ColorFilter.mode(
                  AppColors.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.title,
            style: isSelected
                ? AppFonts.poppinsSemiBold(color: AppTheme.primaryText)
                : AppFonts.poppinsRegular(color: AppTheme.secondaryText),
          ),
        ],
      ),
    );
  }
}
