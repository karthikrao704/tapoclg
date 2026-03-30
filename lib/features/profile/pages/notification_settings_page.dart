import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/features/profile/bloc/notification_setting/notification_settings_bloc.dart';
import 'package:tapovana_mobile_app/features/profile/bloc/notification_setting/notification_settings_event.dart';
import 'package:tapovana_mobile_app/features/profile/bloc/notification_setting/notification_settings_state.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationSettingsBloc()..add(LoadNotificationSettings()),
      child: const NotificationSettingsView(),
    );
  }
}

class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          'Notification Settings',
          style: AppFonts.headland(
            color: AppTheme.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFF1F5F9), height: 1.0),
        ),
      ),
      body: BlocBuilder<NotificationSettingsBloc, NotificationSettingsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(Icons.calendar_today_outlined, 'Appointment Notifications'),
                _buildSwitchGroup([
                  _buildSwitchItem(
                    title: 'Booking Confirmation',
                    subtitle: 'Get notified when your booking is confirmed',
                    value: state.bookingConfirmation,
                    onChanged: (val) => _updateSetting(context, bookingConfirmation: val),
                  ),
                  _buildSwitchItem(
                    title: 'Reminders',
                    subtitle: 'Receive alerts for upcoming appointments',
                    value: state.reminders,
                    onChanged: (val) => _updateSetting(context, reminders: val),
                  ),
                  _buildSwitchItem(
                    title: 'Reschedule Alerts',
                    subtitle: 'Updates when your session time changes',
                    value: state.rescheduleAlerts,
                    onChanged: (val) => _updateSetting(context, rescheduleAlerts: val),
                    showDivider: false,
                  ),
                ]),
                const SizedBox(height: 32),

                _buildSectionHeader(Icons.spa_outlined, 'Program Updates'),
                _buildSwitchGroup([
                  _buildSwitchItem(
                    title: 'Workshops',
                    subtitle: 'New skill-based wellness sessions',
                    value: state.workshops,
                    onChanged: (val) => _updateSetting(context, workshops: val),
                  ),
                  _buildSwitchItem(
                    title: 'Programs',
                    subtitle: 'Long-term holistic health tracks',
                    value: state.programs,
                    onChanged: (val) => _updateSetting(context, programs: val),
                  ),
                  _buildSwitchItem(
                    title: 'Retreats',
                    subtitle: 'Immersive wellness getaways',
                    value: state.retreats,
                    onChanged: (val) => _updateSetting(context, retreats: val),
                    showDivider: false,
                  ),
                ]),
                const SizedBox(height: 32),

                _buildSectionHeader(Icons.local_offer_outlined, 'Marketing & Offers'),
                _buildSwitchGroup([
                  _buildSwitchItem(
                    title: 'Promotions',
                    subtitle: 'Limited time discounts on services',
                    value: state.promotions,
                    onChanged: (val) => _updateSetting(context, promotions: val),
                  ),
                  _buildSwitchItem(
                    title: 'Benefits',
                    subtitle: 'Exclusive member perks and rewards',
                    value: state.benefits,
                    onChanged: (val) => _updateSetting(context, benefits: val),
                  ),
                  _buildSwitchItem(
                    title: 'Seasonal',
                    subtitle: 'Holiday specials and solstice events',
                    value: state.seasonal,
                    onChanged: (val) => _updateSetting(context, seasonal: val),
                    showDivider: false,
                  ),
                ]),
                const SizedBox(height: 32),

                _buildSectionHeader(Icons.campaign_outlined, 'Notification Channels'),
                _buildSwitchGroup([
                  _buildSwitchItem(
                    title: 'Push Notifications',
                    subtitle: '',
                    value: state.pushNotifications,
                    leadingIcon: Icons.notifications_none,
                    onChanged: (val) => _updateSetting(context, pushNotifications: val),
                  ),
                  _buildSwitchItem(
                    title: 'Email Updates',
                    subtitle: '',
                    value: state.emailUpdates,
                    leadingIcon: Icons.mail_outline,
                    onChanged: (val) => _updateSetting(context, emailUpdates: val),
                  ),
                  _buildSwitchItem(
                    title: 'SMS Alerts',
                    subtitle: '',
                    value: state.smsAlerts,
                    leadingIcon: Icons.chat_bubble_outline,
                    onChanged: (val) => _updateSetting(context, smsAlerts: val),
                    showDivider: false,
                  ),
                ]),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppFonts.poppinsSemiBold(
              color: AppTheme.primaryText,
              fontSize: 17,
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
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    IconData? leadingIcon,
    bool showDivider = true,
  }) {
    // If there is no subtitle (like in Notification Channels), adjust padding
    final hasSubtitle = subtitle.isNotEmpty;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, color: const Color(0xFF94A3B8), size: 24),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppFonts.poppinsMedium(
                        color: AppTheme.primaryText,
                        fontSize: 16,
                      ),
                    ),
                    if (hasSubtitle) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppFonts.poppinsRegular(
                          color: AppColors.primaryBlack40,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                height: 24, // Control the switch height appropriately
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
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF1F5F9),
            indent: 16,
            endIndent: 16,
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