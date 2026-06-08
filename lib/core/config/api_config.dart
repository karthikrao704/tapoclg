
import 'package:flutter_dotenv/flutter_dotenv.dart';
class ApiConfig {
  ApiConfig._();

  static String get mapboxAccessToken => dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
  static String get backendUrl => dotenv.env['BACKEND_URL'] ?? 'http://10.0.2.2:5000';
  static String get authProfileBackendUrl => dotenv.env['AUTH_PROFILE_BACKEND_URL'] ?? 'https://backend.rosettesmartlife.com';
}


