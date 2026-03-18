import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/privacy_security/privacy_security_bloc.dart';
import '../bloc/privacy_security/privacy_security_event.dart';
import '../bloc/privacy_security/privacy_security_state.dart';

class PrivacySecurityPage extends StatelessWidget {
  const PrivacySecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PrivacySecurityBloc()..add(LoadPrivacySettings()),
      child: const PrivacySecurityView(),
    );
  }
}

class PrivacySecurityView extends StatelessWidget {
  const PrivacySecurityView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PrivacySecurityBloc, PrivacySecurityState>(
      listenWhen: (previous, current) =>
          previous.error != current.error || previous.successMessage != current.successMessage,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
          context.read<PrivacySecurityBloc>().add(ClearPrivacyStatusMessages());
        }
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
          context.read<PrivacySecurityBloc>().add(ClearPrivacyStatusMessages());
        }
      },
      child: Scaffold(
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
          title: const Text(
            'Privacy & Security',
            style: TextStyle(
              color: Color(0xFF333333),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: const Color(0xFFF1F5F9), height: 1.0),
          ),
        ),
        body: BlocBuilder<PrivacySecurityBloc, PrivacySecurityState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFCDA751)));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Account Security'),
                  _buildCardGroup([
                    _buildActionItem(
                      title: 'Change Password',
                      subtitle: '',
                      icon: Icons.lock_outline,
                      iconBackColor: const Color(0xFFFDFBF4),
                      iconColor: const Color(0xFFCDA751),
                      onTap: () => _showChangePasswordDialog(context),
                    ),
                    _buildSwitchItem(
                      title: 'Two-Factor Authentication',
                      subtitle: 'Adds an extra layer of security',
                      icon: Icons.security,
                      iconBackColor: const Color(0xFFFDFBF4),
                      iconColor: const Color(0xFFCDA751),
                      value: state.twoFactorAuth,
                      onChanged: (val) {
                        context.read<PrivacySecurityBloc>().add(
                              UpdatePrivacySettings(twoFactorAuth: val),
                            );
                      },
                      showDivider: false,
                    ),
                  ]),

                  const SizedBox(height: 32),

                  _buildSectionHeader('Privacy Controls'),
                  _buildCardGroup([
                    _buildActionItem(
                      title: 'Data Permissions',
                      subtitle: '',
                      icon: Icons.key_outlined,
                      iconBackColor: const Color(0xFFFDFBF4),
                      iconColor: const Color(0xFFCDA751),
                      onTap: () {}, // Navigate or show modal
                    ),
                    _buildActionItem(
                      title: 'Download Data',
                      subtitle: '',
                      icon: Icons.file_download_outlined,
                      iconBackColor: const Color(0xFFFDFBF4),
                      iconColor: const Color(0xFFCDA751),
                      onTap: () {}, // Trigger data download action
                    ),
                    _buildActionItem(
                      title: 'Delete Account',
                      subtitle: '',
                      titleColor: const Color(0xFFEF4444),
                      icon: Icons.delete_forever_outlined,
                      iconBackColor: const Color(0xFFFEF2F2),
                      iconColor: const Color(0xFFEF4444),
                      showChevron: false,
                      showDivider: false,
                      onTap: () {}, // Trigger delete account warning
                    ),
                  ]),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
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

  Widget _buildEnclosedIcon(IconData icon, Color iconBackColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconBackColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 20,
      ),
    );
  }

  Widget _buildActionItem({
    required String title,
    String subtitle = '',
    required IconData icon,
    required Color iconBackColor,
    required Color iconColor,
    Color titleColor = const Color(0xFF1E293B),
    required VoidCallback onTap,
    bool showChevron = true,
    bool showDivider = true,
  }) {
    final hasSubtitle = subtitle.isNotEmpty;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12), // prevent square ripple bleeding
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildEnclosedIcon(icon, iconBackColor, iconColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (hasSubtitle) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8), // Muted grey
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showChevron)
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
              ],
            ),
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

  Widget _buildSwitchItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBackColor,
    required Color iconColor,
    required bool value,
    required Function(bool) onChanged,
    bool showDivider = true,
  }) {
    final hasSubtitle = subtitle.isNotEmpty;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildEnclosedIcon(icon, iconBackColor, iconColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (hasSubtitle) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                height: 24,
                child: CupertinoSwitch(
                  value: value,
                  activeTrackColor: const Color(0xFFCDA751),
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

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                labelStyle: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                labelStyle: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCDA751),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<PrivacySecurityBloc>().add(
                    ChangePassword(
                      currentPassword: currentPasswordController.text,
                      newPassword: newPasswordController.text,
                    ),
                  );
              Navigator.of(context).pop();
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}