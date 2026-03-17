
import 'package:flutter_dotenv/flutter_dotenv.dart';
class ApiConfig {
  ApiConfig._();

  static String get mapboxAccessToken => dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
  
}


