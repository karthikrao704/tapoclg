import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    // theme
    final theme = Theme.of(context);

    return Container(
      // margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(color: theme.colorScheme.tertiary, offset: Offset(1, 1)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: theme.primaryColor),
          const SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search services, treatments...',
                hintStyle: theme.textTheme.labelLarge,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
