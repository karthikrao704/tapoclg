import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/auth/auth_cubit.dart';
import 'package:tapovana_mobile_app/features/bookings/presentation/pages/my_bookings_page.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_event.dart';
import '../bloc/profile/profile_state.dart';
import 'personal_info_page.dart';
import 'notification_settings_page.dart';
import 'privacy_security_page.dart';
import 'support_center_page.dart';

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

  // ─── File picker + validation ─────────────────────────────────────────────

  Future<void> _pickAndUploadPhoto(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      allowMultiple: false,
      withData: false,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final ext = (file.extension ?? '').toLowerCase();

    if (!['jpg', 'jpeg', 'png'].contains(ext)) {
      _showSnackBar(context, 'Only .jpg and .png files are allowed.');
      return;
    }

    if (file.size > 5 * 1024 * 1024) {
      _showSnackBar(context, 'File size must not exceed 5 MB.');
      return;
    }

    final path = file.path;
    if (path == null) {
      _showSnackBar(context, 'Could not access the selected file.');
      return;
    }

    context.read<ProfileBloc>().add(UploadProfilePhoto(filePath: path));
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFCFA644),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─── Photo action bottom sheet ────────────────────────────────────────────

  void _showPhotoOptions(BuildContext context, bool hasPhoto) {
    // ✅ Capture the bloc BEFORE opening bottom sheet
    final profileBloc = context.read<ProfileBloc>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(
                  Icons.upload_rounded,
                  color: Color(0xFFCFA644),
                ),
                title: Text(
                  hasPhoto ? 'Change Photo' : 'Upload Photo',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  // ✅ Use captured bloc reference
                  _pickAndUploadPhotoWithBloc(context, profileBloc);
                },
              ),
              if (hasPhoto)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFEF4444),
                  ),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    // ✅ Use captured bloc reference
                    profileBloc.add(DeleteProfilePhoto());
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadPhotoWithBloc(
    BuildContext context,
    ProfileBloc bloc,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      allowMultiple: false,
      withData: false,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final ext = (file.extension ?? '').toLowerCase();

    if (!['jpg', 'jpeg', 'png'].contains(ext)) {
      _showSnackBar(context, 'Only .jpg and .png files are allowed.');
      return;
    }

    if (file.size > 5 * 1024 * 1024) {
      _showSnackBar(context, 'File size must not exceed 5 MB.');
      return;
    }

    final path = file.path;
    if (path == null) {
      _showSnackBar(context, 'Could not access the selected file.');
      return;
    }

    // ✅ Use the captured bloc reference directly
    bloc.add(UploadProfilePhoto(filePath: path));
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          ' Profile',
          overflow: TextOverflow.ellipsis,
          style: AppFonts.headland(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF3D3D3D),
          ),
        ),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.photoError != null) {
            _showSnackBar(context, state.photoError!);
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ProfileBloc>().add(LoadProfile()),
                    child: const Text('Retry'),
                  ),
                ],
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
    );
  }

  // ─── Profile header ───────────────────────────────────────────────────────

  Widget _buildProfileHeader(BuildContext context, ProfileState state) {
    final bool hasNetworkPhoto =
        state.profilePhotoUrl != null && state.profilePhotoUrl!.isNotEmpty;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showPhotoOptions(context, hasNetworkPhoto),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Avatar
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: ClipOval(
                    child: hasNetworkPhoto
                        ? Image.network(
                            state.profilePhotoUrl!,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (_, __, ___) =>
                                Image.asset(state.avatar, fit: BoxFit.cover),
                          )
                        : Image.asset(
                            state.avatar,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                  ),
                ),

                // Upload loading overlay
                if (state.isUploadingPhoto)
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black38,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                // Gold verified badge (bottom-right)
                // Positioned(
                //   bottom: -2,
                //   right: 0,
                //   child: Container(
                //     width: 32,
                //     height: 32,
                //     decoration: const BoxDecoration(
                //       color: Colors.white,
                //       shape: BoxShape.circle,
                //     ),
                //     child: Center(
                //       child: Container(
                //         width: 26,
                //         height: 26,
                //         decoration: const BoxDecoration(
                //           color: Color(0xFFCFAB46),
                //           shape: BoxShape.circle,
                //         ),
                //         child: const Center(
                //           child: Icon(
                //             Icons.verified_outlined,
                //             color: Colors.white,
                //             size: 18,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),

                // Camera badge (bottom-left)
                Positioned(
                  bottom: -2,
                  left: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCFA644),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

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

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF58B814).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              state.membershipType,
              style: const TextStyle(
                fontFamily: 'Manrope',
                color: Color(0xFFCDA751),
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 12),
          if (state.memberSince.isNotEmpty)
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

  // ─── Wellness pass card ───────────────────────────────────────────────────

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
          Container(
            width: double.infinity,
            height: 110,
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
              clipBehavior: Clip.hardEdge,
              children: [
                const Positioned(
                  left: 20,
                  top: 40,
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
                  right: 0,
                  bottom: 0,
                  child: SvgPicture.asset(
                    'assets/icons/petal.svg',
                    width: 50,
                    height: 50,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Next renewal: ${state.nextRenewal}',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
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

  // ─── History card ─────────────────────────────────────────────────────────

  Widget _buildHistoryCard(BuildContext context, ProfileState state) {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const MyBookingsPage()));
      },
      child: Container(
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
                color: const Color(0xFFF2F7E6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.restore,
                color: Color(0xFFCFA644),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Bookings & History',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${state.totalVisits} visits',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Account settings ─────────────────────────────────────────────────────

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
                () =>
                    _navigateToPage(context, const NotificationSettingsPage()),
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

  Widget _buildSettingsItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
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

  // ─── Legal / logout / version ─────────────────────────────────────────────

  Widget _buildLegalLinks() {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Column(
        children: const [
          Text(
            'Terms &\nConditions',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Privacy Policy',
            style: TextStyle(
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
          backgroundColor: const Color(0xFFCFA644),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
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
        'Tapovana Wellness v${state.appVersion}',
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
              context.read<AuthCubit>().signOut();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
