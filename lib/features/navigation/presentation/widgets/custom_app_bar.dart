import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import '../../../../core/storage/local_database.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String greetingMessage;
  final String userName;
  const CustomAppBar({
    super.key,
    required this.greetingMessage,
    required this.userName,
  });

  // handle onTap for notifications icon
  void _handleNotificationTap() {}

  // handle onTap for profile icon (if needed)
  void _handleProfileTap() {}

  // Greeting and Name can be made dynamic by passing them as parameters to the CustomAppBar widget

  @override
  Widget build(BuildContext context) {
    // Theme
    final theme = Theme.of(context);

    String getGreeting() {
      final hour = DateTime.now().hour;
      if (hour >= 5 && hour < 12) {
        return "Good Morning";
      } else if (hour >= 12 && hour < 17) {
        return "Good Afternoon";
      } else if (hour >= 17 && hour < 21) {
        return "Good Evening";
      } else {
        return "Good Night";
      }
    }

    return AppBar(
      // Background color is automatically set by the theme's colorScheme.primary

      // profile icon with circular border
      leading: GestureDetector(
        onTap: _handleProfileTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Uses the secondary color (mapped to the light greenish wellnessTipBg)
              border: Border.all(color: theme.colorScheme.secondary, width: 2),
            ),
            child: const CircleAvatar(
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=500&q=60',
              ),
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
      ),

      // Greeting and Name
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getGreeting(),
            // Inherits size 14, w500, secondaryText color
            style: AppFonts.headland(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6F7894),
            ),

            //Color(0xFF6F7894);
          ),
          FutureBuilder<String?>(
            future: LocalDatabase.getUserName(),
            builder: (context, snapshot) {
              final name = snapshot.data ?? userName;
              return Text(
                name,
                // Inherits size 20, bold, primaryText color
                style: AppFonts.headland(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3D3D3D),
                ),
              );
            },
          ),
        ],
      ),

      // Notifications Icon
      actions: [
        IconButton(
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD9A04B), width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFFD9A04B),
              size: 20,
            ),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
