import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/features/services/presentation/components/categories_buttons.dart';
import 'package:tapovana_mobile_app/features/services/presentation/components/custom_search_bar.dart';
import 'package:tapovana_mobile_app/features/services/presentation/screens/service_list_section.dart';
import 'package:tapovana_mobile_app/features/services/presentation/screens/service_grid_section.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen>
    with SingleTickerProviderStateMixin {
  int _selectedCategoryIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Note: You usually don't need to call setState on tab change for a TabBarView,
    // it rebuilds its children automatically. But keeping it if you have other logic.
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness Services'),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: theme.primaryColor.withAlpha(60),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.notifications_none, color: theme.primaryColor),
          ),
        ],
        actionsPadding: const EdgeInsets.only(right: 16.0),
      ),
      // 1. Replace SingleChildScrollView with NestedScrollView
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            // 2. Put your top non-tab content inside a SliverToBoxAdapter
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    const CustomSearchBar(),
                    const SizedBox(height: 16.0),
                    Text("Categories", style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8.0),
                    CategoriesSection(
                      categories: const [
                        CategoryData(
                          title: 'Spa',
                          icon: "assets/icons/spa_icon.svg",
                        ),
                        CategoryData(
                          title: 'Salon',
                          icon: "assets/icons/salon_icon.svg",
                        ),
                        CategoryData(
                          title: 'Yoga',
                          icon: "assets/icons/yoga_icon.svg",
                        ),
                        CategoryData(
                          title: 'Mind',
                          icon: "assets/icons/mind_icon.svg",
                        ),
                      ],
                      selectedIndex: _selectedCategoryIndex,
                      onCategoryTapped: (index) {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),

            // 3. Make your TabBar a sticky header using a SliverPersistentHeader
            SliverPersistentHeader(
              pinned: true, // This keeps the tabs visible when scrolling down
              delegate: _StickyTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: theme.colorScheme.primary,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorWeight: 3.0,
                  dividerColor: Colors.transparent,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.outline,
                  labelStyle: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.normal,
                  ),
                  isScrollable: false,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                  tabs: const [
                    Tab(text: "All Services"),
                    Tab(text: "Popular"),
                    Tab(text: "Packages"),
                    Tab(text: "Offers"),
                  ],
                ),
                backgroundColor: theme.scaffoldBackgroundColor,
              ),
            ),
          ];
        },

        // 4. The body of the NestedScrollView safely houses the TabBarView
        body: TabBarView(
          controller: _tabController,
          children: const [
            ListScreen(),
            ServiceGridSection(),
            Center(child: Text("Packages Content")),
            Center(child: Text("Offers Content")),
          ],
        ),
      ),
    );
  }
}

/// Custom Delegate required to wrap a TabBar in a SliverPersistentHeader
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _StickyTabBarDelegate(this.tabBar, {required this.backgroundColor});

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: backgroundColor, // Prevents elements from showing through the tabs
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
