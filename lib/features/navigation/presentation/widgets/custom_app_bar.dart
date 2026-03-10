import 'package:flutter/material.dart';

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
            greetingMessage,
            // Inherits size 14, w500, secondaryText color
            style: theme.textTheme.labelLarge,
          ),
          Text(
            userName,
            // Inherits size 20, bold, primaryText color
            style: theme.textTheme.titleLarge,
          ),
        ],
      ),

      // Notifications Icon
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Uses the outline color for the subtle circular border
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.notifications_none,
                  // Uses onSurface (primaryText) to match the dark text color
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () {
                  _handleNotificationTap();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
