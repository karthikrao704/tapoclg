import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tapovana_mobile_app/core/theme/theme_cubit.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';
import '../../../../core/storage/local_database.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String greetingMessage;
  final String userName;
  const CustomAppBar({
    super.key,
    required this.greetingMessage,
    required this.userName,
  });


  void _handleProfileTap() {}


  @override
  Widget build(BuildContext context) {

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
      leading: GestureDetector(
        onTap: _handleProfileTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryColor.withAlpha(50), width: 1.5),
            ),
            child: FutureBuilder<String?>(
              future: LocalDatabase.getProfilePhotoUrl(),
              builder: (context, snapshot) {
                final photoUrl = snapshot.data;

                if (photoUrl != null && photoUrl.isNotEmpty) {
                  return ClipOval(
                    child: Image.network(
                      photoUrl,
                      fit: BoxFit.fill,
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/profile.png',
                          fit: BoxFit.fill,
                          width: 50,
                          height: 50,
                        );
                      },
                    ),
                  );
                }

                return const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/profile.png'),
                  backgroundColor: Colors.transparent,
                );
              },
            ),
          ),
        ),
      ),

      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getGreeting(),
            style: AppFonts.poppinsRegular(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodySmall?.color ?? AppTheme.secondaryText,
            ),
          ),
          FutureBuilder<String?>(
            future: LocalDatabase.getUserName(),
            builder: (context, snapshot) {
              final name = snapshot.data ?? userName;
              return Text(
                name,
                style: AppFonts.headland(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              );
            },
          ),
        ],
      ),

      actions: [
        IconButton(
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.amberAccent
                : Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {
            context.read<ThemeCubit>().toggleTheme();
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}