import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/core/widgets/secondary_app_bar.dart';
import 'package:tapovana_mobile_app/features/profile/bloc/notification_setting/notification_settings_bloc.dart';
import 'package:tapovana_mobile_app/features/profile/bloc/notification_setting/notification_settings_event.dart';
import 'package:tapovana_mobile_app/features/profile/bloc/notification_setting/notification_settings_state.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          NotificationSettingsBloc()..add(LoadNotificationSettings()),
      child: const NotificationSettingsView(),
    );
  }
}

class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Establish breakpoints
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.height < 650;
    final hPadding = size.width * 0.05;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: SecondaryAppBar(
        title: 'Notification Settings',
        centerTitle: false,
        titleSpacing: 0,
        showSearch: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFF1F5F9), height: 1.0),
        ),
      ),
      body: BlocBuilder<NotificationSettingsBloc, NotificationSettingsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFD9A04B)),
            );
          }

          if (state.error != null) {
            return Center(
              child: Text(
                'Error: ${state.error}',
                style: AppFonts.poppinsRegular(color: Colors.red),
              ),
            );
          }

          return SingleChildScrollView(
            // 2. Relative padding for the outer scroll view
            padding: EdgeInsets.symmetric(
              horizontal: hPadding,
              vertical: isSmallScreen ? 16 : 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  Icons.calendar_today_outlined,
                  'Appointment Notifications',
                  isSmallScreen,
                ),
                _buildSwitchGroup([
                  _buildSwitchItem(
                    title: 'Booking Confirmation',
                    subtitle: 'Get notified when your booking is confirmed',
                    value: state.bookingConfirmation,
                    isSmallScreen: isSmallScreen,
                    onChanged: (val) =>
                        _updateSetting(context, bookingConfirmation: val),
                  ),
                  _buildSwitchItem(
                    title: 'Reminders',
                    subtitle: 'Receive alerts for upcoming appointments',
                    value: state.reminders,
                    isSmallScreen: isSmallScreen,
                    onChanged: (val) => _updateSetting(context, reminders: val),
                  ),
                  _buildSwitchItem(
                    title: 'Reschedule Alerts',
                    subtitle: 'Updates when your session time changes',
                    value: state.rescheduleAlerts,
                    isSmallScreen: isSmallScreen,
                    onChanged: (val) =>
                        _updateSetting(context, rescheduleAlerts: val),
                    showDivider: false,
                  ),
                ]),
                SizedBox(height: isSmallScreen ? 24 : 32),

                _buildSectionHeader(
                  Icons.spa_outlined,
                  'Program Updates',
                  isSmallScreen,
                ),
                _buildSwitchGroup([
                  _buildSwitchItem(
                    title: 'Workshops',
                    subtitle: 'New skill-based wellness sessions',
                    value: state.workshops,
                    isSmallScreen: isSmallScreen,
                    onChanged: (val) => _updateSetting(context, workshops: val),
                  ),
                  _buildSwitchItem(
                    title: 'Programs',
                    subtitle: 'Long-term holistic health tracks',
                    value: state.programs,
                    isSmallScreen: isSmallScreen,
                    onChanged: (val) => _updateSetting(context, programs: val),
                  ),
                  _buildSwitchItem(
                    title: 'Retreats',
                    subtitle: 'Immersive wellness getaways',
                    value: state.retreats,
                    isSmallScreen: isSmallScreen,
                    onChanged: (val) => _updateSetting(context, retreats: val),
                    showDivider: false,
                  ),
                ]),
                SizedBox(height: isSmallScreen ? 24 : 32),

                _buildSectionHeader(
                  Icons.local_offer_outlined,
                  'Marketing & Offers',
                  isSmallScreen,
                ),
                _buildSwitchGroup([
                  _buildSwitchItem(
                    title: 'Promotions',
                    subtitle: 'Limited time discounts on services',
                    value: state.promotions,
                    isSmallScreen: isSmallScreen,
                    onChanged: (val) =>
                        _updateSetting(context, promotions: val),
                  ),
                  _buildSwitchItem(
                    title: 'Benefits',
                    subtitle: 'Exclusive member perks and rewards',
                    value: state.benefits,
                    isSmallScreen: isSmallScreen,
                    onChanged: (val) => _updateSetting(context, benefits: val),
                  ),
                  _buildSwitchItem(
                    title: 'Seasonal',
                    subtitle: 'Holiday specials and solstice events',
                    value: state.seasonal,
                    isSmallScreen: isSmallScreen,
                    onChanged: (val) => _updateSetting(context, seasonal: val),
                    showDivider: false,
                  ),
                ]),
                SizedBox(height: isSmallScreen ? 24 : 32),

                _buildSectionHeader(
                  Icons.campaign_outlined,
                  'Notification Channels',
                  isSmallScreen,
                ),
                _buildSwitchGroup([
                  _buildSwitchItem(
                    title: 'Push Notifications',
                    subtitle: '',
                    value: state.pushNotifications,
                    leadingIcon: Icons.notifications_none,
                    isSmallScreen: isSmallScreen,
                    onChanged: (val) =>
                        _updateSetting(context, pushNotifications: val),
                  ),
                  _buildSwitchItem(
                    title: 'Email Updates',
                    subtitle: '',
                    value: state.emailUpdates,
                    leadingIcon: Icons.mail_outline,
                    isSmallScreen: isSmallScreen,
                    onChanged: (val) =>
                        _updateSetting(context, emailUpdates: val),
                  ),
                  _buildSwitchItem(
                    title: 'SMS Alerts',
                    subtitle: '',
                    value: state.smsAlerts,
                    leadingIcon: Icons.chat_bubble_outline,
                    isSmallScreen: isSmallScreen,
                    onChanged: (val) => _updateSetting(context, smsAlerts: val),
                    showDivider: false,
                  ),
                ]),
                SizedBox(height: isSmallScreen ? 24 : 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.only(left: 4, bottom: isSmallScreen ? 12 : 16),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primaryColor,
            size: isSmallScreen ? 20 : 24,
          ),
          const SizedBox(width: 8),
          // 3. Pre-emptively wrapping text in Expanded
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.poppinsSemiBold(
                color: AppTheme.primaryText,
                fontSize: isSmallScreen ? 15 : 17,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required bool isSmallScreen,
    IconData? leadingIcon,
    bool showDivider = true,
  }) {
    final hasSubtitle = subtitle.isNotEmpty;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 12 : 16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leadingIcon != null) ...[
                Icon(
                  leadingIcon,
                  color: const Color(0xFF94A3B8),
                  size: isSmallScreen ? 20 : 24,
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.poppinsMedium(
                        color: AppTheme.primaryText,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                    if (hasSubtitle) ...[
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.poppinsRegular(
                          color: AppColors.primaryBlack40,
                          fontSize: isSmallScreen ? 11 : 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // 4. Scaling the CupertinoSwitch so it fits neatly on tight screens
              Transform.scale(
                scale: isSmallScreen ? 0.85 : 1.0,
                child: CupertinoSwitch(
                  value: value,
                  activeTrackColor: AppColors.primaryColor,
                  inactiveTrackColor: const Color(0xFFE2E8F0),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: const Color(0xFFF1F5F9),
            indent: isSmallScreen ? 12 : 16,
            endIndent: isSmallScreen ? 12 : 16,
          ),
      ],
    );
  }

  void _updateSetting(
    BuildContext context, {
    bool? bookingConfirmation,
    bool? reminders,
    bool? rescheduleAlerts,
    bool? workshops,
    bool? programs,
    bool? retreats,
    bool? promotions,
    bool? benefits,
    bool? seasonal,
    bool? pushNotifications,
    bool? emailUpdates,
    bool? smsAlerts,
  }) {
    context.read<NotificationSettingsBloc>().add(
      UpdateNotificationSettings(
        bookingConfirmation: bookingConfirmation,
        reminders: reminders,
        rescheduleAlerts: rescheduleAlerts,
        workshops: workshops,
        programs: programs,
        retreats: retreats,
        promotions: promotions,
        benefits: benefits,
        seasonal: seasonal,
        pushNotifications: pushNotifications,
        emailUpdates: emailUpdates,
        smsAlerts: smsAlerts,
      ),
    );
  }
}
