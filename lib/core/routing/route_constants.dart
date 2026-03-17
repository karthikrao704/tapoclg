// lib/core/routing/route_constants.dart

class RouteConstants {
  // Auth flow routes (outside bottom nav)
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dataEntry = '/data-entry';

  // Main navigation routes (inside bottom nav)
  static const String home = '/home';
  static const String services = '/services';
  static const String more = '/more';
  static const String profile = '/profile';
  static const String details = '/details';

  // Service Categories
  static const String bodyCare = '/body-care';
  static const String skinCare = '/skincare';
  static const String hairCare = '/haircare';
  static const String nailCare = '/nail-care';
  static const String styling = '/styling';

  // Profile sub-routes
  static const String personalInfo = '/profile/personal-info';
  static const String notificationSettings = '/profile/notification-settings';
  static const String privacySecurity = '/profile/privacy-security';
  static const String supportCenter = '/profile/support-center';
}