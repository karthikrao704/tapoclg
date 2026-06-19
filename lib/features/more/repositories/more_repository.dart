import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tapovana_mobile_app/features/more/models/more_models.dart';

class MoreRepository {
  final String baseUrl = "https://tapovana.onrender.com";

  // ═══════════════════════════════════════
  //   GET /api/workshops — Fetch all workshops
  // ═══════════════════════════════════════

  Future<List<FeaturedWorkshop>> getWorkshops() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/workshops'),
        headers: {"Content-Type": "application/json"},
      );

      debugPrint("📋 GET ALL WORKSHOPS RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['workshops'] != null) {
          final List<dynamic> workshopsJson = data['workshops'];
          return workshopsJson
              .map((json) => FeaturedWorkshop.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch workshops');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Error fetching workshops: $e");
      rethrow;
    }
  }

  // ═══════════════════════════════════════
  //   GET /api/blogs — Fetch all blogs
  // ═══════════════════════════════════════

  Future<List<WellnessBlogPost>> getBlogs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/blogs'),
        headers: {"Content-Type": "application/json"},
      );

      debugPrint("📋 GET ALL BLOGS RESPONSE STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['blogs'] != null) {
          final List<dynamic> blogsJson = data['blogs'];
          return blogsJson
              .map((json) => WellnessBlogPost.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch blogs');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Error fetching blogs: $e");
      rethrow;
    }
  }

  // ═══════════════════════════════════════
  //   GET /api/vedic-programs — Fetch all vedic programs
  // ═══════════════════════════════════════

  Future<List<VedicPackage>> getVedicPrograms() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/vedic-programs'),
        headers: {"Content-Type": "application/json"},
      );

      debugPrint("📋 GET ALL VEDIC PROGRAMS RESPONSE STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['programs'] != null) {
          final List<dynamic> programsJson = data['programs'];
          return programsJson
              .map((json) => VedicPackage.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch vedic programs');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Error fetching vedic programs: $e");
      rethrow;
    }
  }
}
