import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tapovana_mobile_app/core/theme/theme_cubit.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/core/widgets/no_internet_widget.dart';
import 'package:tapovana_mobile_app/core/api/app_error.dart';
import 'package:tapovana_mobile_app/features/auth/bloc/auth/auth_cubit.dart';
import 'package:tapovana_mobile_app/features/bookings/presentation/pages/my_bookings_page.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_event.dart';
import '../bloc/profile/profile_state.dart';
import 'package:tapovana_mobile_app/core/widgets/media_helper.dart';
import 'personal_info_page.dart';
import 'notification_settings_page.dart';
import 'privacy_security_page.dart';
import 'support_center_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileView();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile',
          overflow: TextOverflow.ellipsis,
          style: AppFonts.headland(
            fontSize: isSmallScreen ? 20 : 22,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? Colors.amberAccent : AppTheme.primaryText,
            ),
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
          const SizedBox(width: 8),
        ],
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
            return NoInternetWidget(
              errorType: state.errorType ?? AppErrorType.network,
              onReload: () => context.read<ProfileBloc>().add(LoadProfile()),
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
                _buildLegalLinks(context, isSmallScreen),
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
      color: Theme.of(context).scaffoldBackgroundColor,
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
                    child: MediaHelper.buildServiceImage(
                      state.profilePhotoUrl,
                      fit: BoxFit.cover,
                      fallbackWidget: Image.asset(
                        state.avatar,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
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
              color: Theme.of(context).colorScheme.onSurface,
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
                color: Theme.of(context).textTheme.bodySmall?.color,
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
    // Determine card gradient and title based on the active pass
    final passType = state.membershipType.toUpperCase();
    List<Color> cardGradient;
    String passTitle;

    if (passType.contains('SILVER')) {
      cardGradient = const [Color(0xFFCBD5E1), Color(0xFF64748B)]; // Silver grey
      passTitle = 'Silver Wellness Pass';
    } else if (passType.contains('GOLD')) {
      cardGradient = const [Color(0xFFFBBF24), Color(0xFFD97706)]; // Gold/amber
      passTitle = 'Gold Wellness Pass';
    } else if (passType.contains('DIAMOND')) {
      cardGradient = const [Color(0xFF60A5FA), Color(0xFF1D4ED8)]; // Diamond blue
      passTitle = 'Diamond Wellness Pass';
    } else {
      cardGradient = const [Color(0xFF34D399), Color(0xFF059669)]; // Standard green/teal
      passTitle = 'Get Wellness Pass';
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: hPadding, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withAlpha(20)
              : const Color(0xFFF1F5F9),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: isSmallScreen ? 90 : 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: cardGradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.only(
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
                    passTitle,
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
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: isSmallScreen ? 10 : 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 6),
                      Text(
                        '${state.availableCredits} Credits remaining',
                        style: AppFonts.poppinsSemiBold(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: isSmallScreen ? 16 : 18,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 6),
                      Text(
                        'Next renewal: ${state.nextRenewal}',
                        style: AppFonts.poppinsRegular(
                          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7) ?? AppColors.primaryBlack40,
                          fontSize: isSmallScreen ? 11 : 13,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                 ElevatedButton(
                  onPressed: () => _showPassPickerBottomSheet(context),
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

  // ─── Wellness Pass Picker Bottom Sheet ────────────────────────────────────

  void _showPassPickerBottomSheet(BuildContext context) {
    final profileBloc = context.read<ProfileBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Select Wellness Pass',
                    textAlign: TextAlign.center,
                    style: AppFonts.headland(
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a pass to unlock exclusive discounts and monthly wellness credits.',
                    textAlign: TextAlign.center,
                    style: AppFonts.poppinsRegular(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Pass Card - Silver
                  _buildPassOptionCard(
                    context: context,
                    profileBloc: profileBloc,
                    title: 'SILVER PASS',
                    gradient: const [Color(0xFFCBD5E1), Color(0xFF94A3B8)],
                    price: '₹2,999/mo',
                    discount: '10%',
                    credits: '5 Credits',
                    benefits: [
                      '10% Discount on all packages & services',
                      '5 Monthly wellness credits',
                      'Standard booking priority'
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Pass Card - Gold
                  _buildPassOptionCard(
                    context: context,
                    profileBloc: profileBloc,
                    title: 'GOLD PASS',
                    gradient: const [Color(0xFFFBBF24), Color(0xFFD97706)],
                    price: '₹5,999/mo',
                    discount: '20%',
                    credits: '12 Credits',
                    isPopular: true,
                    benefits: [
                      '20% Discount on all packages & services',
                      '12 Monthly wellness credits',
                      'High booking priority',
                      '1 Free expert consultation session'
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Pass Card - Diamond
                  _buildPassOptionCard(
                    context: context,
                    profileBloc: profileBloc,
                    title: 'DIAMOND PASS',
                    gradient: const [Color(0xFF60A5FA), Color(0xFF1D4ED8)],
                    price: '₹9,999/mo',
                    discount: '30%',
                    credits: '25 Credits',
                    benefits: [
                      '30% Discount on all packages & services',
                      '25 Monthly wellness credits',
                      'Instant VIP booking priority',
                      'Unlimited expert consultation sessions',
                      'VIP Lounge & Refreshment access'
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPassOptionCard({
    required BuildContext context,
    required ProfileBloc profileBloc,
    required String title,
    required List<Color> gradient,
    required String price,
    required String discount,
    required String credits,
    required List<String> benefits,
    bool isPopular = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? const Color(0xFFD97706) : const Color(0xFFE2E8F0),
          width: isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            // Card Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isPopular)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'MOST POPULAR',
                            style: AppFonts.poppinsSemiBold(
                              color: const Color(0xFFD97706),
                              fontSize: 9,
                            ),
                          ),
                        ),
                      Text(
                        title,
                        style: AppFonts.poppinsSemiBold(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        credits,
                        style: AppFonts.poppinsRegular(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: AppFonts.poppinsSemiBold(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$discount OFF',
                          style: AppFonts.poppinsSemiBold(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Benefits List & Apply Button
            Container(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ...benefits.map((benefit) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: AppColors.primaryColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              benefit,
                              style: AppFonts.poppinsRegular(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        profileBloc.add(UpgradeWellnessPass(passType: title));
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Applied for $title successfully!'),
                            backgroundColor: AppColors.primaryColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Apply for $title',
                        style: AppFonts.poppinsSemiBold(fontSize: 14),
                      ),
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
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withAlpha(20)
                : const Color(0xFFF1F5F9),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: isSmallScreen ? 38 : 44,
              height: isSmallScreen ? 38 : 44,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withAlpha(15) : const Color(0xFFF2F7E6),
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
                      color: Theme.of(context).colorScheme.onSurface,
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
              color: Theme.of(context).textTheme.bodySmall?.color,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: hPadding),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withAlpha(20)
                  : const Color(0xFFF1F5F9),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSettingsItem(
                context,
                Icons.person_outline,
                'Personal Information',
                () => _navigateToPage(context, const PersonalInfoPage()),
                isSmallScreen,
                showDivider: true,
              ),
              _buildSettingsItem(
                context,
                Icons.notifications_none,
                'Notifications',
                () =>
                    _navigateToPage(context, const NotificationSettingsPage()),
                isSmallScreen,
                showDivider: true,
              ),
              _buildSettingsItem(
                context,
                Icons.security_outlined,
                'Privacy & Security',
                () => _navigateToPage(context, const PrivacySecurityPage()),
                isSmallScreen,
                showDivider: true,
              ),
              _buildSettingsItem(
                context,
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
    BuildContext context,
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
              color: Theme.of(context).colorScheme.onSurface,
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
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withAlpha(15) : const Color(0xFFF1F5F9),
            indent: 52,
            endIndent: 0,
          ),
      ],
    );
  }

  // ─── Legal / logout / version ─────────────────────────────────────────────

  Widget _buildLegalLinks(BuildContext context, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.only(top: isSmallScreen ? 16 : 24, bottom: 16),
      child: Column(
        children: [
          Text(
            'Terms &\nConditions',
            textAlign: TextAlign.center,
            style: AppFonts.poppinsRegular(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: isSmallScreen ? 12 : 14,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Privacy Policy',
            style: AppFonts.poppinsRegular(
              color: Theme.of(context).textTheme.bodySmall?.color,
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
              context.read<ProfileBloc>().add(Logout());
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
