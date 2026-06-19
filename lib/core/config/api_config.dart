
import 'package:flutter_dotenv/flutter_dotenv.dart';
class ApiConfig {
  ApiConfig._();

  static String get mapboxAccessToken => dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
  static String get backendUrl => dotenv.env['BACKEND_URL'] ?? 'https://tapoclg.onrender.com';
  static String get authProfileBackendUrl => dotenv.env['AUTH_PROFILE_BACKEND_URL'] ?? 'https://tapovanaserver.nimvoltlabs.in';
}


