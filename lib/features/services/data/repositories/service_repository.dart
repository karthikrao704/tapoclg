import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tapovana_mobile_app/features/services/data/models/service_model.dart';
import 'package:tapovana_mobile_app/features/services/data/models/service_detail_model.dart';

class ServiceRepository {
  final String baseUrl = "https://backend.rosettesmartlife.com";

  // ═══════════════════════════════════════
  //   GET /api/services — Fetch all services
  // ═══════════════════════════════════════

  Future<List<ServiceModel>> getAllServices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/services'),
        headers: {"Content-Type": "application/json"},
      );

      debugPrint("📋 GET ALL SERVICES RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['services'] != null) {
          final List<dynamic> servicesJson = data['services'];
          return servicesJson
              .map((json) => ServiceModel.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch services');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Error fetching services: $e");
      rethrow;
    }
  }

  // ═══════════════════════════════════════
  //   GET /api/services — Fetch services by category
  // ═══════════════════════════════════════

  /// Fetches all services and filters by [category] (case-insensitive).
  Future<List<ServiceModel>> getServicesByCategory(String category) async {
    final all = await getAllServices();
    return all
        .where((s) => s.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  // ═══════════════════════════════════════
  //   GET /api/services/:id — Fetch service by ID
  // ═══════════════════════════════════════

  Future<ServiceDetailModel> getServiceById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/services/$id'),
        headers: {"Content-Type": "application/json"},
      );

      debugPrint("📋 GET SERVICE BY ID RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['service'] != null) {
          return ServiceDetailModel.fromJson(data['service']);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch service details');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Error fetching service details: $e");
      rethrow;
    }
  }
}
