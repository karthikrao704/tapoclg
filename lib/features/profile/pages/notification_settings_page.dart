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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  context,
                  Icons.calendar_today_outlined,
                  'Appointment Notifications',
                  isSmallScreen,
                ),
                _buildSwitchGroup(context, [
                  _buildSwitchItem(
                    context: context,
                    title: 'Booking Confirmation',
                    subtitle: 'Get notified when your booking is confirmed',
                    value: state.bookingConfirmation,
                    isSmallScreen: isSmallScreen,
                    onChanged: (val) =>
                        _updateSetting(context, bookingConfirmation: val),
                  ),
                  _buildSwitchItem(
                    context: context,
                    title: 'Reminders',
                    subtitle: 'Receive alerts for upcoming appointments',
                    value: state.reminders,
                    isSmallScreen: isSmallScreen,
                    onChanged: (val) => _updateSetting(context, reminders: val),
                  ),
                  _buildSwitchItem(
                    context: context,
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
                  context,
                  Icons.spa_outlined,
                  'Program Updates',
                  isSmallScreen,
                ),
                _buildSwitchGroup(context, [
                  _buildSwitchItem(
                    context: context,
                    title: 'Workshops',
                    subtitle: 'New skill-based wellness sessions',
                    value: state.workshops,
                    isSmallScreen: isSmallScreen,
                    onChanged: (val) => _updateSetting(context, workshops: val),
                  ),
                  _buildSwitchItem(
                    context: context,
                    title: 'Programs',
                    subtitle: 'Long-term holistic health tracks',
                    value: state.programs,
                    isSmallScreen: isSmallScreen,
                    onChanged: (val) => _updateSetting(context, programs: val),
                  ),
                  _buildSwitchItem(
                    context: context,
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
                  context,
                  Icons.local_offer_outlined,
                  'Marketing & Offers',
                  isSmallScreen,
                ),
                _buildSwitchGroup(context, [
                  _buildSwitchItem(
                    context: context,
                    title: 'Promotions',
                    subtitle: 'Limited time discounts on services',
                    value: state.promotions,
                    isSmallScreen: isSmallScreen,
                    onChanged: (val) =>
                        _updateSetting(context, promotions: val),
                  ),
                  _buildSwitchItem(
                    context: context,
                    title: 'Benefits',
                    subtitle: 'Exclusive member perks and rewards',
                    value: state.benefits,
                    isSmallScreen: isSmallScreen,
                    onChanged: (val) => _updateSetting(context, benefits: val),
                  ),
                  _buildSwitchItem(
                    context: context,
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
                  context,
                  Icons.campaign_outlined,
                  'Notification Channels',
                  isSmallScreen,
                ),
                _buildSwitchGroup(context, [
                  _buildSwitchItem(
                    context: context,
                    title: 'Push Notifications',
                    subtitle: '',
                    value: state.pushNotifications,
                    leadingIcon: Icons.notifications_none,
                    isSmallScreen: isSmallScreen,
                    onChanged: (val) =>
                        _updateSetting(context, pushNotifications: val),
                  ),
                  _buildSwitchItem(
                    context: context,
                    title: 'Email Updates',
                    subtitle: '',
                    value: state.emailUpdates,
                    leadingIcon: Icons.mail_outline,
                    isSmallScreen: isSmallScreen,
                    onChanged: (val) =>
                        _updateSetting(context, emailUpdates: val),
                  ),
                  _buildSwitchItem(
                    context: context,
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

  Widget _buildSectionHeader(BuildContext context, IconData icon, String title, bool isSmallScreen) {
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
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: isSmallScreen ? 15 : 17,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchGroup(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withAlpha(20) : const Color(0xFFF1F5F9),
          width: 1.5,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchItem({
    required BuildContext context,
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
                        color: Theme.of(context).colorScheme.onSurface,
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
                          color: Theme.of(context).textTheme.bodySmall?.color,
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
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withAlpha(15) : const Color(0xFFF1F5F9),
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
