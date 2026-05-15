import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/features/services/presentation/screens/category_service_list_screen.dart';

/// Nail Care screen — fetches services with category "Nail Care" from the API
/// and groups them by subcategory tabs (Manicure, Pedicure, Nail Art).
class NailCareScreen extends StatelessWidget {
  const NailCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryServiceListScreen(
      title: 'Nail Care',
      apiCategory: 'Nail Care',
      tabLabels: ['All', 'Manicure', 'Pedicure', 'Nail Art'],
    );
  }
}
