import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/features/appointments/presentation/pages/appointment_booking_page.dart';
import 'package:tapovana_mobile_app/features/bookings/presentation/widgets/future_booking_card.dart';
import 'package:tapovana_mobile_app/features/bookings/presentation/widgets/upcoming_booking_card.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "My Bookings",
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,

              indicatorWeight: 3.0,

              indicatorSize: TabBarIndicatorSize.label,

              indicatorColor: const Color(0xFFC9A14A),
              dividerColor: Colors.transparent,
              labelColor: const Color(0xFFC9A14A),
              unselectedLabelColor: const Color(0xFF848484),

              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.zero,

              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
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
        children: [_buildUpcomingTab(), _buildCompletedTab()],
      ),
    );
  }

  Widget _buildUpcomingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "IMMEDIATE NEXT",
            style: TextStyle(
              fontSize: 12.5,
              letterSpacing: 1.2,
              color: Color(0xFFC9A14A),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const UpcomingBookingCard(),
          const SizedBox(height: 35),
          const Text(
            "FUTURE APPOINTMENTS",
            style: TextStyle(
              fontSize: 13,
              letterSpacing: 1.2,
              color: Color(0xFFC9A14A),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          FutureBookingCard(
            title: "Vedic Aromatherapy",
            time: "Nov 02 • 02:30 PM",
            status: "PENDING",
            icon: "assets/bookings/leaf.png",
          ),
          const SizedBox(height: 12),
          FutureBookingCard(
            title: "Private Yoga Session",
            time: "Nov 15 • 08:00 AM",
            status: "CONFIRMED",
            icon: "assets/bookings/yoga.png",
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTab() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 80),
        child: Text(
          "No completed bookings yet",
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}