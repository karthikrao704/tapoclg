import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/api/app_error.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';

/// A reusable error widget displayed when a network or server error occurs.
///
/// Pass [errorType] to automatically adapt the icon and message:
/// - [AppErrorType.network] → wifi-off icon + "No internet connection"
/// - [AppErrorType.server]  → cloud-error icon + "Server error"
///
/// You may always override [title] and [subtitle] explicitly.
class NoInternetWidget extends StatelessWidget {
  /// The [AppErrorType] drives icon and default text selection.
  final AppErrorType errorType;

  /// Primary bold message. If null, a default based on [errorType] is used.
  final String? title;

  /// Optional secondary hint. If null, a default based on [errorType] is used.
  final String? subtitle;

  /// Callback executed when the user taps the Reload button.
  final VoidCallback onReload;

  const NoInternetWidget({
    super.key,
    required this.onReload,
    this.errorType = AppErrorType.network,
    this.title,
    this.subtitle,
  });

  // ── Derived UI values ───────────────────────────────────────────────────────

  IconData get _icon {
    switch (errorType) {
      case AppErrorType.network:
        return Icons.wifi_off_rounded;
      case AppErrorType.server:
        return Icons.cloud_off_rounded;
    }
  }

  String get _defaultTitle {
    switch (errorType) {
      case AppErrorType.network:
        return 'No internet connection';
      case AppErrorType.server:
        return 'Something went wrong';
    }
  }

  String get _defaultSubtitle {
    switch (errorType) {
      case AppErrorType.network:
        return 'Please check your connection and try again';
      case AppErrorType.server:
        return 'We\'re having trouble reaching the server.\nPlease try again shortly.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: Theme.of(context).brightness == Brightness.dark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon ──────────────────────────────────────────────────
              Icon(
                _icon,
                size: 56,
                color: AppColors.primaryColor.withAlpha(200),
              ),

              const SizedBox(height: 20),

              // ── Bold title ────────────────────────────────────────────
              Text(
                title ?? _defaultTitle,
                textAlign: TextAlign.center,
                style: AppFonts.poppinsSemiBold(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 6),

              // ── Subtitle ──────────────────────────────────────────────
              Text(
                subtitle ?? _defaultSubtitle,
                textAlign: TextAlign.center,
                style: AppFonts.poppinsRegular(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF9B9BA1),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // ── Reload button ─────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onReload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Reload',
                    style: AppFonts.poppinsSemiBold(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
