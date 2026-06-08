import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tapovana_mobile_app/features/bookings/presentation/widgets/future_booking_card.dart';
import 'package:tapovana_mobile_app/features/bookings/presentation/widgets/upcoming_booking_card.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/core/config/api_config.dart';
import 'package:tapovana_mobile_app/core/storage/local_database.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<dynamic> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final name = await LocalDatabase.getUserName();
      if (name == null || name.isEmpty) {
        setState(() {
          _isLoading = false;
          _bookings = [];
        });
        return;
      }

      final url = Uri.parse('${ApiConfig.backendUrl}/api/bookings?userName=${Uri.encodeComponent(name)}');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['bookings'] != null) {
          setState(() {
            _bookings = data['bookings'];
            _isLoading = false;
          });
          return;
        }
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading bookings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  String _formatFutureDateTime(String dateStr, String timeStr) {
    try {
      final dt = DateTime.parse(dateStr);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final formattedDay = dt.day.toString().padLeft(2, '0');
      return "${months[dt.month - 1]} $formattedDay • $timeStr";
    } catch (_) {
      return "$dateStr • $timeStr";
    }
  }

  String _getFutureIcon(String serviceName) {
    final sLower = serviceName.toLowerCase();
    if (sLower.contains('vedic') || sLower.contains('aroma') || sLower.contains('detox')) {
      return "assets/bookings/leaf.png";
    }
    return "assets/bookings/yoga.png";
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

  Widget _buildUpcomingTab(bool isSmallScreen, double hPadding) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
        ),
      );
    }

    if (_bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            "No upcoming bookings yet.",
            style: AppFonts.poppinsRegular(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : AppColors.primaryBlack40,
              fontSize: isSmallScreen ? 13 : 15,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final upcoming = _bookings[0];
    final futureBookings = _bookings.sublist(1);

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

          UpcomingBookingCard(booking: upcoming),

          if (futureBookings.isNotEmpty) ...[
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
            ...futureBookings.map((b) {
              final title = b['service_name'] ?? 'Swedish Massage';
              final dateStr = b['booking_date']?.toString() ?? '';
              final timeStr = b['booking_time']?.toString() ?? '';
              final timeLabel = _formatFutureDateTime(dateStr, timeStr);
              final status = 'CONFIRMED';
              final icon = _getFutureIcon(title);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: FutureBookingCard(
                  title: title,
                  time: timeLabel,
                  status: status,
                  icon: icon,
                ),
              );
            }),
          ],
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
