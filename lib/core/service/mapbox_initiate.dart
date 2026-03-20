import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:tapovana_mobile_app/core/config/api_config.dart';



class MapboxConfig {
  MapboxConfig._();

 
  static String get accessToken => ApiConfig.mapboxAccessToken;

  
  static String get tileUrl =>
      'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/'
      '{z}/{x}/{y}@2x?access_token=$accessToken';
}



class MapboxPlace {
  final String name;
  final String country;
  final String displayName;
  final double latitude;
  final double longitude;

  const MapboxPlace({
    required this.name,
    required this.country,
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  factory MapboxPlace.fromFeature(Map<String, dynamic> feature) {
    final String text = feature['text'] ?? '';
    final List<dynamic> center = feature['center'] ?? [0.0, 0.0];
    final List<dynamic> placeTypes = feature['place_type'] ?? [];
    final List<dynamic>? context = feature['context'] as List<dynamic>?;

    String city = text;
    String countryCode = '';

    if (context != null) {
      for (final ctx in context) {
        final String id = (ctx['id'] ?? '').toString();

        if (id.startsWith('country')) {
          countryCode =
              (ctx['short_code'] ?? '').toString().toUpperCase();
        }

        if (placeTypes.contains('postcode') &&
            id.startsWith('place')) {
          city = ctx['text'] ?? city;
        }
      }
    }

    if (placeTypes.contains('postcode') && city != text) {
      city = '$city ($text)';
    }

    final display =
        countryCode.isNotEmpty ? '$city, $countryCode' : city;

    return MapboxPlace(
      name: city,
      country: countryCode,
      displayName: display,
      latitude: (center[1] as num).toDouble(),
      longitude: (center[0] as num).toDouble(),
    );
  }

  @override
  String toString() => displayName;
}



class MapboxGeocodingService {
  MapboxGeocodingService._();

  static Future<List<MapboxPlace>> searchPlaces(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return [];

    final token = MapboxConfig.accessToken;
    if (token.isEmpty) return [];

    final encoded = Uri.encodeComponent(trimmed);

    final uri = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/$encoded.json'
      '?access_token=$token'
      '&types=place,locality,postcode'
      '&limit=8'
      '&autocomplete=true'
      '&language=en',
    );

    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        final features =
            (body['features'] as List<dynamic>?) ?? [];
        return features
            .map((f) =>
                MapboxPlace.fromFeature(f as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Geocoding ▸ $e');
    }
    return [];
  }

  static Future<MapboxPlace?> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    final token = MapboxConfig.accessToken;
    if (token.isEmpty) return null;

    final uri = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/'
      '$longitude,$latitude.json'
      '?access_token=$token'
      '&types=place,locality'
      '&limit=1'
      '&language=en',
    );

    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final features =
            (json.decode(res.body)['features'] as List<dynamic>?) ??
                [];
        if (features.isNotEmpty) {
          return MapboxPlace.fromFeature(
              features.first as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('ReverseGeocode ▸ $e');
    }
    return null;
  }
}


class MapboxLocationService {
  MapboxLocationService._();

  static Future<bool> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) return false;

    return perm == LocationPermission.whileInUse ||
        perm == LocationPermission.always;
  }

 
  static Future<Position?> currentPosition() async {
    if (!await ensurePermission()) return null;
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Location ▸ $e');
      return null;
    }
  }

  static Future<MapboxPlace?> currentPlace() async {
    final pos = await currentPosition();
    if (pos == null) return null;
    return MapboxGeocodingService.reverseGeocode(
        pos.latitude, pos.longitude);
  }
}