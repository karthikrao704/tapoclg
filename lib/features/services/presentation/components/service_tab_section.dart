import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';

class ServicesTabSection extends StatelessWidget {
  const ServicesTabSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // DefaultTabController manages the state between the TabBar and TabBarView
    // automatically, saving you from writing a complex StatefulWidget.
    return DefaultTabController(
      length: 4, // Must match the number of tabs and views
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. The Custom Tab Bar
          // We wrap it in a Material widget or Container if we need a specific 
          // background, but keeping it transparent fits your previous design.
          TabBar(
            // Styling the indicator (the line under the active tab)
            indicatorColor: theme.colorScheme.primary,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 3.0,
            
            // Differentiating selected vs unselected text (My Advice for better UX)
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.outline, // Or bodySmall color
            
            // Fetching your text styles
            labelStyle: AppFonts.poppinsSemiBold(fontSize: 16),
            unselectedLabelStyle: AppFonts.poppinsRegular(fontSize: 16),
            
            // If the tabs get squished on small screens, set isScrollable: true
            isScrollable: false, 
            
            // Removing default splash padding for a cleaner look
            padding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            
            tabs: const [
              Tab(text: "All Services"),
              Tab(text: "Popular"),
              Tab(text: "Packages"),
              Tab(text: "Offers"),
            ],
          ),
          
          const SizedBox(height: 16), // Space between tabs and content
          
          // 2. The Views Below
          // Expanded is crucial here so the TabBarView takes up the remaining 
          // screen space inside the Column.
          Expanded(
            child: TabBarView(
              children: [
                // These represent the different views that will swap in and out.
                // Replace these Placeholders with your actual list/grid widgets.
                _ServiceListPlaceholder(title: "All Services Content"),
                _ServiceListPlaceholder(title: "Popular Content"),
                _ServiceListPlaceholder(title: "Packages Content"),
                _ServiceListPlaceholder(title: "Offers Content"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A simple dummy widget to demonstrate the changing views.
/// Replace this with your actual layout components.
class _ServiceListPlaceholder extends StatelessWidget {
  final String title;

  const _ServiceListPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}