import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/features/services/presentation/screens/category_service_list_screen.dart';

/// Skin Care screen — fetches services with category "Skin Care" from the API
/// and groups them by subcategory tabs (Facials, Detain Treatment, Bleach, Waxing).
class SkinCareScreen extends StatelessWidget {
  const SkinCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryServiceListScreen(
      title: 'Skin Care',
      apiCategory: 'Skin Care',
      tabLabels: ['All', 'Facials', 'Detain Treatment', 'Bleach', 'Waxing'],
    );
  }
}
