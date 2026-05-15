import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/features/services/presentation/screens/category_service_list_screen.dart';

/// Styling & Makeover screen — fetches services with category "Styling & Make over"
/// from the API and groups them by subcategory tabs (Makeup, Bridal Makeover, Hair Styling).
class StylingMakeoverScreen extends StatelessWidget {
  const StylingMakeoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryServiceListScreen(
      title: 'Styling & Makeover',
      apiCategory: 'Styling & Make over',
      tabLabels: ['All', 'Makeup', 'Bridal Makeover', 'Hair Styling'],
    );
  }
}
