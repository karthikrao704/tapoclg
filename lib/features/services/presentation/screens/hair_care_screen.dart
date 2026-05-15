import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/features/services/presentation/screens/category_service_list_screen.dart';

/// Hair Care screen — fetches services with category "Hair Care" from the API
/// and groups them by subcategory tabs (Haircut, Hair Spa, Styling).
class HairCareScreen extends StatelessWidget {
  const HairCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryServiceListScreen(
      title: 'Hair Care',
      apiCategory: 'Hair Care',
      tabLabels: ['All', 'Haircut', 'Hair Spa', 'Styling'],
    );
  }
}
