import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/features/bookings/presentation/widgets/future_booking_card.dart';
import 'package:tapovana_mobile_app/features/bookings/presentation/widgets/upcoming_booking_card.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Establish screen dimensions for responsive scaling
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.height < 650;
    final hPadding = size.width * 0.05;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF333333),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "My Bookings",
          style: AppFonts.headland(
            fontSize: isSmallScreen ? 18 : 20,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          // Adjusted preferred size slightly for tighter screens
          preferredSize: Size.fromHeight(isSmallScreen ? 42 : 48),
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
              controller: _tabController,
              indicatorWeight: 3.0,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorColor: AppColors.primaryColor,
              dividerColor: Colors.transparent,
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : AppColors.primaryBlack40,
              labelPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
              ),
              padding: EdgeInsets.zero,
              // 2. Scaled TabBar typography
              labelStyle: AppFonts.poppinsSemiBold(
                fontSize: isSmallScreen ? 13 : 15,
              ),
              unselectedLabelStyle: AppFonts.poppinsSemiBold(
                fontSize: isSmallScreen ? 13 : 15,
              ),
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              tabs: const [
                Tab(text: "Upcoming"),
                Tab(text: "Completed"),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUpcomingTab(isSmallScreen, hPadding),
          _buildCompletedTab(isSmallScreen),
        ],
      ),
    );
  }

  // 3. Passed the responsive variables down into the sub-trees
  Widget _buildUpcomingTab(bool isSmallScreen, double hPadding) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: hPadding,
        vertical: isSmallScreen ? 12 : 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "IMMEDIATE NEXT",
            style: AppFonts.poppinsSemiBold(
              fontSize: isSmallScreen ? 11 : 12.5,
              letterSpacing: 1.2,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),

          // NOTE: Ensure this external widget also uses Expanded/Flexible internally!
          const UpcomingBookingCard(),

          SizedBox(height: isSmallScreen ? 24 : 35),
          Text(
            "FUTURE APPOINTMENTS",
            style: AppFonts.poppinsSemiBold(
              fontSize: isSmallScreen ? 11 : 13,
              letterSpacing: 1.2,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),

          // NOTE: Ensure this external widget also uses Expanded/Flexible internally!
          const FutureBookingCard(
            title: "Vedic Aromatherapy",
            time: "Nov 02 • 02:30 PM",
            status: "PENDING",
            icon: "assets/bookings/leaf.png",
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          const FutureBookingCard(
            title: "Private Yoga Session",
            time: "Nov 15 • 08:00 AM",
            status: "CONFIRMED",
            icon: "assets/bookings/yoga.png",
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTab(bool isSmallScreen) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: isSmallScreen ? 50 : 80),
        child: Text(
          "No completed bookings yet",
          style: AppFonts.poppinsRegular(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : AppColors.primaryBlack40,
            fontSize: isSmallScreen ? 13 : 15,
          ),
        ),
      ),
    );
  }
}
