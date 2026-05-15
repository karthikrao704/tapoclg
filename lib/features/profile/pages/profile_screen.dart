import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
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


  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─── Photo action bottom sheet ────────────────────────────────────────────

  void _showPhotoOptions(BuildContext context, bool hasPhoto) {
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
                  color: AppColors.primaryColor,
                ),
                title: Text(
                  hasPhoto ? 'Change Photo' : 'Upload Photo',
                  style: AppFonts.poppinsMedium(),
                ),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _pickAndUploadPhotoWithBloc(context, profileBloc);
                },
              ),
              if (hasPhoto)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFEF4444),
                  ),
                  title: Text(
                    'Remove Photo',
                    style: AppFonts.poppinsMedium(
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
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

    if (!context.mounted) return;
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

    bloc.add(UploadProfilePhoto(filePath: path));
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Determine screen sizing for responsive elements
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.height < 650;
    final horizontalPadding = size.width * 0.05; // Flexible side margins

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profile',
          overflow: TextOverflow.ellipsis,
          style: AppFonts.headland(
            fontSize: isSmallScreen ? 20 : 22,
            fontWeight: FontWeight.w400,
            color: AppTheme.primaryText,
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
                _buildProfileHeader(context, state, isSmallScreen),
                _buildWellnessPassCard(
                  context,
                  state,
                  isSmallScreen,
                  horizontalPadding,
                ),
                _buildHistoryCard(
                  context,
                  state,
                  isSmallScreen,
                  horizontalPadding,
                ),
                _buildAccountSettingsSection(
                  context,
                  isSmallScreen,
                  horizontalPadding,
                ),
                _buildLegalLinks(isSmallScreen),
                _buildLogoutButton(context, isSmallScreen, horizontalPadding),
                _buildAppVersion(state, isSmallScreen),
                SizedBox(height: isSmallScreen ? 15 : 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Profile header ───────────────────────────────────────────────────────

  Widget _buildProfileHeader(
    BuildContext context,
    ProfileState state,
    bool isSmallScreen,
  ) {
    final bool hasNetworkPhoto =
        state.profilePhotoUrl != null && state.profilePhotoUrl!.isNotEmpty;

    // Scale avatar based on screen size
    final double avatarSize = isSmallScreen ? 90 : 110;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 8, bottom: isSmallScreen ? 16 : 24),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showPhotoOptions(context, hasNetworkPhoto),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Avatar
                Container(
                  width: avatarSize,
                  height: avatarSize,
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

                // Camera badge (bottom-left)
                Positioned(
                  bottom: -2,
                  left: 0,
                  child: Container(
                    width: isSmallScreen ? 26 : 30,
                    height: isSmallScreen ? 26 : 30,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),

          Text(
            state.name,
            style: AppFonts.poppinsMedium(
              fontSize: isSmallScreen ? 20 : 24,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 4 : 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF58B814).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              state.membershipType,
              style: AppFonts.poppinsSemiBold(
                color: AppColors.primaryColor,
                fontSize: isSmallScreen ? 12 : 14,
                letterSpacing: 0.7,
                height: 1.5,
              ),
            ),
          ),

          SizedBox(height: isSmallScreen ? 8 : 12),
          if (state.memberSince.isNotEmpty)
            Text(
              'Member since ${state.memberSince}',
              style: AppFonts.poppinsRegular(
                color: AppTheme.secondaryText,
                fontSize: isSmallScreen ? 13 : 15,
                letterSpacing: -0.3,
              ),
            ),
        ],
      ),
    );
  }

  // ─── Wellness pass card ───────────────────────────────────────────────────

  Widget _buildWellnessPassCard(
    BuildContext context,
    ProfileState state,
    bool isSmallScreen,
    double hPadding,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: hPadding, vertical: 8),
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
            height: isSmallScreen ? 90 : 110,
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
                Positioned(
                  left: 20,
                  top: isSmallScreen ? 30 : 40,
                  child: Text(
                    'Premium Wellness Pass',
                    style: AppFonts.poppinsMedium(
                      color: AppColors.white,
                      fontSize: isSmallScreen ? 16 : 18,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: SvgPicture.asset(
                    'assets/icons/petal.svg',
                    width: isSmallScreen ? 40 : 50,
                    height: isSmallScreen ? 40 : 50,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 20,
              vertical: isSmallScreen ? 16 : 24,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AVAILABLE CREDITS',
                        style: AppFonts.poppinsSemiBold(
                          color: AppTheme.secondaryText,
                          fontSize: isSmallScreen ? 10 : 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 6),
                      Text(
                        '${state.availableCredits} Credits remaining',
                        style: AppFonts.poppinsSemiBold(
                          color: AppTheme.primaryText,
                          fontSize: isSmallScreen ? 16 : 18,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 6),
                      Text(
                        'Next renewal: ${state.nextRenewal}',
                        style: AppFonts.poppinsRegular(
                          color: AppColors.primaryBlack40,
                          fontSize: isSmallScreen ? 11 : 13,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 24,
                      vertical: isSmallScreen ? 12 : 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Manage',
                    style: AppFonts.poppinsSemiBold(
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
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

  Widget _buildHistoryCard(
    BuildContext context,
    ProfileState state,
    bool isSmallScreen,
    double hPadding,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const MyBookingsPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: hPadding, vertical: 8),
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: isSmallScreen ? 38 : 44,
              height: isSmallScreen ? 38 : 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F7E6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.restore,
                color: AppColors.primaryColor,
                size: isSmallScreen ? 24 : 28,
              ),
            ),
            const SizedBox(width: 16),

            // 🐛 THE FIX: Wrapped the Column in an Expanded widget
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Bookings & History',
                    // Added safety truncations just in case
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.poppinsRegular(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${state.totalVisits} visits',
                    style: AppFonts.poppinsRegular(
                      fontSize: isSmallScreen ? 11 : 13,
                      color: AppColors.primaryBlack40,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Account settings ─────────────────────────────────────────────────────

  Widget _buildAccountSettingsSection(
    BuildContext context,
    bool isSmallScreen,
    double hPadding,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: hPadding + 4, top: 16, bottom: 8),
          child: Text(
            'ACCOUNT SETTINGS',
            style: AppFonts.poppinsSemiBold(
              fontSize: isSmallScreen ? 11 : 13,
              color: AppTheme.secondaryText,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: hPadding),
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
                isSmallScreen,
                showDivider: true,
              ),
              _buildSettingsItem(
                Icons.notifications_none,
                'Notifications',
                () =>
                    _navigateToPage(context, const NotificationSettingsPage()),
                isSmallScreen,
                showDivider: true,
              ),
              _buildSettingsItem(
                Icons.security_outlined,
                'Privacy & Security',
                () => _navigateToPage(context, const PrivacySecurityPage()),
                isSmallScreen,
                showDivider: true,
              ),
              _buildSettingsItem(
                Icons.help_outline,
                'Support Center',
                () => _navigateToPage(context, const SupportCenterPage()),
                isSmallScreen,
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
    VoidCallback onTap,
    bool isSmallScreen, {
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
          leading: Icon(
            icon,
            color: AppColors.primaryColor,
            size: isSmallScreen ? 20 : 24,
          ),
          title: Text(
            title,
            style: AppFonts.poppinsMedium(
              fontSize: isSmallScreen ? 13 : 15,
              color: AppTheme.primaryText,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: const Color(0xFFCBD5E1),
            size: isSmallScreen ? 18 : 20,
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

  Widget _buildLegalLinks(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.only(top: isSmallScreen ? 16 : 24, bottom: 16),
      child: Column(
        children: [
          Text(
            'Terms &\nConditions',
            textAlign: TextAlign.center,
            style: AppFonts.poppinsRegular(
              color: AppTheme.secondaryText,
              fontSize: isSmallScreen ? 12 : 14,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Privacy Policy',
            style: AppFonts.poppinsRegular(
              color: AppTheme.secondaryText,
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    bool isSmallScreen,
    double hPadding,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: hPadding, vertical: 16),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: Icon(
          Icons.logout_rounded,
          size: isSmallScreen ? 20 : 24,
          color: Colors.white,
        ),
        label: Text(
          'Logout',
          style: AppFonts.poppinsSemiBold(fontSize: isSmallScreen ? 16 : 18),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildAppVersion(ProfileState state, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: isSmallScreen ? 16 : 24),
      child: Text(
        'Tapovana Wellness v${state.appVersion}',
        style: AppFonts.poppinsRegular(
          color: AppColors.primaryBlack40,
          fontSize: isSmallScreen ? 11 : 13,
        ),
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
