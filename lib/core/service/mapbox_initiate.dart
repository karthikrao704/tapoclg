// lib/core/services/mapbox/mapbox_initiate.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:tapovana_mobile_app/core/config/api_config.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  MAPBOX CONFIG
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class MapboxConfig {
  MapboxConfig._();

  static String get accessToken => ApiConfig.mapboxAccessToken;

  static String get tileUrl =>
      'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/'
      '{z}/{x}/{y}@2x?access_token=$accessToken';
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  PLACE MODEL
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class MapboxPlace {
  final String name;                    // City name: "Manipal"
  final String countryName;             // Full name: "India"
  final String countryCode;             // Short code: "IN"
  final String? postalCode;             // Zip code: "576104"
  final String displayName;             // For field: "Manipal, India"
  final String dropdownName;            // For dropdown: "Manipal (576104), India"
  final double latitude;
  final double longitude;

  const MapboxPlace({
    required this.name,
    required this.countryName,
    required this.countryCode,
    this.postalCode,
    required this.displayName,
    required this.dropdownName,
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
    String countryName = '';
    String? postalCode;

    if (context != null) {
      for (final ctx in context) {
        final String id = (ctx['id'] ?? '').toString();

        // ✅ Extract country FULL NAME from Mapbox response
        if (id.startsWith('country')) {
          countryCode =
              (ctx['short_code'] ?? '').toString().toUpperCase();
          // ✅ Get full country name from 'text' field
          countryName = (ctx['text'] ?? '').toString();
        }

        // Extract postal code
        if (id.startsWith('postcode')) {
          postalCode = (ctx['text'] ?? '').toString();
        }

        // For postcode search results, get city from place context
        if (placeTypes.contains('postcode') &&
            id.startsWith('place')) {
          city = ctx['text'] ?? city;
        }
      }
    }

    // ✅ displayName: Without zipcode (for field after selection)
    final display = countryName.isNotEmpty
        ? '$city, $countryName'
        : city;

    // ✅ dropdownName: With zipcode (for dropdown list only)
    final dropdownDisplay = postalCode != null && postalCode!.isNotEmpty
        ? '$city ($postalCode), $countryName'
        : display;

    return MapboxPlace(
      name: city,
      countryName: countryName.isNotEmpty ? countryName : countryCode,
      countryCode: countryCode,
      postalCode: postalCode,
      displayName: display,
      dropdownName: dropdownDisplay,
      latitude: (center[1] as num).toDouble(),
      longitude: (center[0] as num).toDouble(),
    );
  }

  @override
  String toString() => displayName;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  GEOCODING SERVICE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class MapboxGeocodingService {
  MapboxGeocodingService._();

  /// Forward: city name or zip → list of places
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

  /// Reverse: lat,lng → single place with zipcode
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
      '&types=place,locality,postcode'
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

  /// ✅ NEW: Get city name from zipcode
  /// This is for current location: find the zipcode, then get city
  static Future<MapboxPlace?> getCityByPostalCode(
    String postalCode,
  ) async {
    final token = MapboxConfig.accessToken;
    if (token.isEmpty) return null;

    final encoded = Uri.encodeComponent(postalCode);

    final uri = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/$encoded.json'
      '?access_token=$token'
      '&types=postcode'
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
      debugPrint('GetCityByPostalCode ▸ $e');
    }
    return null;
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  LOCATION SERVICE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

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

  /// One-time GPS fetch
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

  /// ✅ NEW: GPS → reverse geocode → get zipcode → lookup city by zipcode
  /// This ensures we show the city that the zipcode belongs to
  static Future<MapboxPlace?> currentPlaceByZipcode() async {
    final pos = await currentPosition();
    if (pos == null) return null;

    // Step 1: Reverse geocode to get zipcode
    final initialPlace = await MapboxGeocodingService.reverseGeocode(
        pos.latitude, pos.longitude);

    if (initialPlace == null) return null;

    // Step 2: If we have a postal code, lookup the city by that postal code
    if (initialPlace.postalCode != null &&
        initialPlace.postalCode!.isNotEmpty) {
      final placeByZip =
          await MapboxGeocodingService.getCityByPostalCode(
              initialPlace.postalCode!);
      return placeByZip ?? initialPlace;
    }

    return initialPlace;
  }
}