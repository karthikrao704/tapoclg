import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/features/services/presentation/screens/category_service_list_screen.dart';

/// Body Care screen — fetches services with category "Body Care" from the API
/// and groups them by subcategory tabs (Massages, Facials, Scrubs, Hydrotherapy).
class BodyCareScreen extends StatelessWidget {
  const BodyCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryServiceListScreen(
      title: 'Body Care',
      apiCategory: 'Body Care',
      tabLabels: ['All', 'Massages', 'Facials', 'Scrubs', 'Hydrotherapy'],
    );
  }
}
