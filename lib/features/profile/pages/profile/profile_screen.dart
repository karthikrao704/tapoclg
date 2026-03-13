import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tapovana_mobile_app/features/profile/bloc/profile/profile_bloc.dart';
import 'package:tapovana_mobile_app/features/profile/bloc/profile/profile_event.dart';
import 'package:tapovana_mobile_app/features/profile/bloc/profile/profile_state.dart';
import 'package:tapovana_mobile_app/features/profile/pages/notification_settings/notification_settings_page.dart';
import 'package:tapovana_mobile_app/features/profile/pages/personal_info/personal_info_page.dart';
import 'package:tapovana_mobile_app/features/profile/pages/privacy_security/privacy_security_page.dart';
import 'package:tapovana_mobile_app/features/profile/pages/support_center/support_center_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(LoadProfile()),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: false,
        titleSpacing: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF333333),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.withValues(alpha: 0.2),
            height: 1.0,
          ),
        ),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Text(
                'Error: ${state.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(context, state),
                _buildWellnessPassCard(context, state),
                _buildHistoryCard(context, state),
                _buildAccountSettingsSection(context),
                _buildLegalLinks(),
                _buildLogoutButton(context),
                _buildAppVersion(state),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: 3,
          onTap: (index) {},
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFFCFA644), // Gold explicitly
          unselectedItemColor: const Color(0xFF333333),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, fontFamily: 'Poppins'),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13, fontFamily: 'Poppins'),
          items: [
            BottomNavigationBarItem(
              icon: Padding(padding: const EdgeInsets.only(bottom: 6), child: CustomPaint(size: const Size(24, 24), painter: HomeIconPainter(color: const Color(0xFF333333)))),
              activeIcon: Padding(padding: const EdgeInsets.only(bottom: 6), child: CustomPaint(size: const Size(24, 24), painter: HomeIconPainter(color: const Color(0xFFCFA644)))),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: const EdgeInsets.only(bottom: 6), child: CustomPaint(size: const Size(28, 28), painter: ServicesIconPainter(color: const Color(0xFF333333)))),
              activeIcon: Padding(padding: const EdgeInsets.only(bottom: 6), child: CustomPaint(size: const Size(28, 28), painter: ServicesIconPainter(color: const Color(0xFFCFA644)))),
              label: 'Services',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: const EdgeInsets.only(bottom: 6), child: CustomPaint(size: const Size(24, 24), painter: MoreIconPainter(color: const Color(0xFF333333)))),
              activeIcon: Padding(padding: const EdgeInsets.only(bottom: 6), child: CustomPaint(size: const Size(24, 24), painter: MoreIconPainter(color: const Color(0xFFCFA644)))),
              label: 'More',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: const EdgeInsets.only(bottom: 6), child: CustomPaint(size: const Size(24, 24), painter: ProfileIconPainter(color: const Color(0xFF333333)))),
              activeIcon: Padding(padding: const EdgeInsets.only(bottom: 6), child: CustomPaint(size: const Size(24, 24), painter: ProfileIconPainter(color: const Color(0xFFCFA644)))),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Column(
        children: [
          // Avatar with gold verified badge
          Stack(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  image: DecorationImage(
                    image: AssetImage(state.avatar),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter, // Often helps frame portraits better
                  ),
                ),
              ),
              Positioned(
                bottom: -2,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Color(0xFFCFAB46),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.verified_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            state.name,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),

          // GOLD MEMBER outlined badge below name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF58B814).withValues(alpha: 0.10), // 10% opacity green
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              'GOLD MEMBER',
              style: TextStyle(
                fontFamily: 'Manrope',
                color: Color(0xFFCDA751), // Exact gold
                fontSize: 14,
                fontWeight: FontWeight.w800, // Extra Bold
                letterSpacing: 0.7,
                height: 1.5, // 21px line height for 14px text
              ),
            ),
          ),

          const SizedBox(height: 12),
          Text(
            'Member since ${state.memberSince}',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 15,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessPassCard(BuildContext context, ProfileState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP: gold-to-green gradient with title + spa leaf icon
          Container(
            width: double.infinity,
            height: 95, // Decreased size as requested
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFDCA730), Color(0xFF9DC970)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.antiAlias, // Keep it anti-aliased to container bounds
              children: [
                const Positioned(
                  left: 20,
                  top: 36, // Centered better in the 95 height box
                  child: Text(
                    'Premium Wellness Pass',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Positioned(
                  right: -10,
                  bottom: -15, // shifted to align correctly with the corner crop
                  child: Opacity(
                    opacity: 0.2, // lowered opacity slightly to match reference
                    child: SizedBox(
                      width: 130, // scaled slightly larger to reach the "Pass" word horizontally
                      height: 130,
                      child: CustomPaint(
                        painter: _ThreeLeavesPainter(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // BOTTOM: white section — credits left, gold Manage button right
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24), // Reduced padding to prevent line wrapping
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AVAILABLE CREDITS',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${state.availableCredits} Credits remaining',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFF1E293B),
                          fontSize: 18, // Reduced to prevent wrapping
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Next renewal: ${state.nextRenewal}',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC5A335),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Manage',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, ProfileState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F7E6), // Light greenish yellow
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.restore,
              color: Color(0xFFCFA644), // Gold color
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'History',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 2),
              Text(
                '24 visits',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20, top: 16, bottom: 8),
          child: Text(
            'ACCOUNT SETTINGS',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSettingsItem(
                Icons.person_outline,
                'Personal Information',
                () => _navigateToPage(context, const PersonalInfoPage()),
                showDivider: true,
              ),
              _buildSettingsItem(
                Icons.notifications_none,
                'Notifications',
                () => _navigateToPage(context, const NotificationSettingsPage()),
                showDivider: true,
              ),
              _buildSettingsItem(
                Icons.security_outlined,
                'Privacy & Security',
                () => _navigateToPage(context, const PrivacySecurityPage()),
                showDivider: true,
              ),
              _buildSettingsItem(
                Icons.help_outline,
                'Support Center',
                () => _navigateToPage(context, const SupportCenterPage()),
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap, {bool showDivider = true}) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          minVerticalPadding: 0,
          leading: Icon(icon, color: const Color(0xFFC5A335), size: 24),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Color(0xFFCBD5E1),
            size: 20,
          ),
          onTap: onTap,
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF1F5F9),
            indent: 52,
            endIndent: 0,
          ),
      ],
    );
  }

  Widget _buildLegalLinks() {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Column(
        children: [
          Text(
            'Terms &\nConditions',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Privacy Policy',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout_rounded, size: 24, color: Colors.white),
        label: const Text(
          'Logout',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFCFA644), // Gold explicitly
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Pill shape
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildAppVersion(ProfileState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Text(
        'Tapovana Wellness v2.4.0',
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProfileBloc>().add(Logout());
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// Custom painter to draw a 3-leaf watermark similar to the requested design
class _ThreeLeavesPainter extends CustomPainter {
  final Color color;

  _ThreeLeavesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0 // slightly thinner relative to large size
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.miter;

    final path = Path();
    
    var w = size.width;
    var h = size.height;

    // Origin at 90% hooks it precisely to the corner given the -15, -10 Stack offset
    double bx = w * 0.9;
    double by = h * 0.9;

    // Center Leaf: Tallest, tilting strongly left
    path.moveTo(bx, by);
    // Outer/Left edge sweeping up
    path.cubicTo(w * 0.4, h * 0.8, w * 0.35, h * 0.25, w * 0.6, h * 0.05); 
    // Inner/Right edge returning
    path.cubicTo(w * 0.8, h * 0.2, w * 0.9, h * 0.5, bx, by); 

    // Left Leaf: Wide and thick, pointing leftwards
    path.moveTo(bx, by);
    // Top edge sweeping out
    path.cubicTo(w * 0.65, h * 0.65, w * 0.35, h * 0.55, w * 0.15, h * 0.55);
    // Bottom edge returning
    path.cubicTo(w * 0.2, h * 0.8, w * 0.5, h * 0.95, bx, by);

    // Right Leaf: Slightly smaller, pointing up/right and heavily cropped by the edge
    path.moveTo(bx, by);
    // Left edge sweeping up/right
    path.cubicTo(w * 0.92, h * 0.65, w * 1.05, h * 0.4, w * 1.15, h * 0.3); 
    // Right edge returning
    path.cubicTo(w * 1.25, h * 0.5, w * 1.1, h * 0.8, bx, by);

    // Subtle curved stem hooking below the corner bounds
    path.moveTo(bx, by);
    path.quadraticBezierTo(w * 0.88, h * 0.95, w * 0.85, h * 1.0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Below are the Custom Painters for the Bottom Nav Bar Icons

class HomeIconPainter extends CustomPainter {
  final Color color;
  HomeIconPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    var path = Path();
    var w = size.width;
    var h = size.height;

    // Center Peak
    path.moveTo(w * 0.5, h * 0.05);

    // Right roof slope
    path.lineTo(w * 0.85, h * 0.3);
    // Right shoulder rounded corner
    path.quadraticBezierTo(w * 0.9, h * 0.35, w * 0.88, h * 0.45);
    // Right wall drop
    path.lineTo(w * 0.8, h * 0.75);
    // Right bottom rounded corner
    path.quadraticBezierTo(w * 0.78, h * 0.85, w * 0.65, h * 0.85);

    // Flat bottom line
    path.lineTo(w * 0.35, h * 0.85);

    // Left bottom rounded corner
    path.quadraticBezierTo(w * 0.22, h * 0.85, w * 0.2, h * 0.75);
    // Left wall rise
    path.lineTo(w * 0.12, h * 0.45);
    // Left shoulder rounded corner
    path.quadraticBezierTo(w * 0.1, h * 0.35, w * 0.15, h * 0.3);
    // Back to Peak
    path.lineTo(w * 0.5, h * 0.05);
    path.close();
    
    // Smile curve inside
    var smilePath = Path();
    smilePath.moveTo(w * 0.35, h * 0.6);
    smilePath.quadraticBezierTo(w * 0.5, h * 0.75, w * 0.65, h * 0.6);
    
    canvas.drawPath(path, paint);
    canvas.drawPath(smilePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ServicesIconPainter extends CustomPainter {
  final Color color;
  ServicesIconPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    var w = size.width;
    var h = size.height;
    
    // The base is the bottom center of all petals
    double bx = w * 0.5;
    double by = h * 0.88;

    // ---- Center Petal: tall, narrow pointed oval ----
    var center = Path();
    center.moveTo(bx, by);
    center.cubicTo(w * 0.3, h * 0.68, w * 0.3, h * 0.22, bx, h * 0.06); // Left edge up
    center.cubicTo(w * 0.7, h * 0.22, w * 0.7, h * 0.68, bx, by);         // Right edge down
    canvas.drawPath(center, paint);

    // ---- Inner Left Petal: medium oval angled left ----
    var iL = Path();
    iL.moveTo(bx, by);
    // Goes up and to the left, tip at ~(0.14, 0.28)
    iL.cubicTo(w * 0.08, h * 0.72, w * -0.02, h * 0.32, w * 0.18, h * 0.22);
    // Returns along the right side of petal back to base
    iL.cubicTo(w * 0.32, h * 0.28, w * 0.38, h * 0.58, bx, by);
    canvas.drawPath(iL, paint);

    // ---- Inner Right Petal: mirror of inner left ----
    var iR = Path();
    iR.moveTo(bx, by);
    iR.cubicTo(w * 0.92, h * 0.72, w * 1.02, h * 0.32, w * 0.82, h * 0.22);
    iR.cubicTo(w * 0.68, h * 0.28, w * 0.62, h * 0.58, bx, by);
    canvas.drawPath(iR, paint);

    // ---- Outer Left Wing: wide, flat, low arc ----
    var oL = Path();
    oL.moveTo(bx, by);
    // Sweeps far left to tip
    oL.cubicTo(w * 0.2, h * 0.95, w * -0.12, h * 0.85, w * -0.05, h * 0.6);
    // Returns close along top of wing
    oL.cubicTo(w * 0.0,  h * 0.5,  w * 0.15, h * 0.68, bx, by);
    canvas.drawPath(oL, paint);

    // ---- Outer Right Wing: mirror ----
    var oR = Path();
    oR.moveTo(bx, by);
    oR.cubicTo(w * 0.8,  h * 0.95, w * 1.12, h * 0.85, w * 1.05, h * 0.6);
    oR.cubicTo(w * 1.0,  h * 0.5,  w * 0.85, h * 0.68, bx, by);
    canvas.drawPath(oR, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MoreIconPainter extends CustomPainter {
  final Color color;
  MoreIconPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    var w = size.width;
    var h = size.height;

    // Outer rounded squircle (slightly taller than wide)
    var outerRect = RRect.fromLTRBR(
      w * 0.1, h * 0.08, w * 0.9, h * 0.92, const Radius.circular(7),
    );
    canvas.drawRRect(outerRect, paint);

    // Horizontal divider line spanning the full inner width, at ~45% height
    canvas.drawLine(Offset(w * 0.1, h * 0.48), Offset(w * 0.9, h * 0.48), paint);

    // Top handle: a U-shaped bracket sitting above the divider
    // The handle has rounded top corners
    var handleRect = RRect.fromLTRBAndCorners(
      w * 0.32, h * 0.22, w * 0.68, h * 0.48,
      topLeft: const Radius.circular(4),
      topRight: const Radius.circular(4),
      bottomLeft: Radius.zero,
      bottomRight: Radius.zero,
    );
    canvas.drawRRect(handleRect, paint);

    // Small centered horizontal bar in the bottom section
    canvas.drawLine(Offset(w * 0.35, h * 0.70), Offset(w * 0.65, h * 0.70), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ProfileIconPainter extends CustomPainter {
  final Color color;
  ProfileIconPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    var w = size.width;
    var h = size.height;

    // Head circle, sits higher up
    canvas.drawCircle(Offset(w * 0.5, h * 0.25), w * 0.18, paint);

    // Body forming a classic torso bell curve
    var bodyPath = Path();
    // Start at bottom left
    bodyPath.moveTo(w * 0.15, h * 0.85);
    // Draw horizontal bottom line to bottom right
    bodyPath.lineTo(w * 0.85, h * 0.85);
    // Sweep up right shoulder
    bodyPath.quadraticBezierTo(w * 0.8, h * 0.6, w * 0.65, h * 0.55);
    // Across the neck/collar
    bodyPath.quadraticBezierTo(w * 0.5, h * 0.45, w * 0.35, h * 0.55);
    // Sweep down left shoulder
    bodyPath.quadraticBezierTo(w * 0.2, h * 0.6, w * 0.15, h * 0.85);
    bodyPath.close();

    canvas.drawPath(bodyPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}