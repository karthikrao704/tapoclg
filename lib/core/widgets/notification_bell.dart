import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';

class NotificationBell extends StatelessWidget {
  final VoidCallback? onPressed;
  final double size;

  const NotificationBell({
    super.key,
    this.onPressed,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed ?? () {},
      icon: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.notificationBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.notifications_outlined,
          color: AppColors.primaryColor,
          size: 20,
        ),
      ),
    );
  }
}
