import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tapovana_mobile_app/core/config/api_config.dart';

class ReviewRepository {
  Future<void> submitReview({
    required String username,
    required String email,
    required String moduleType,
    required String title,
    required int rating,
    required String feedback,
  }) async {
    final url = Uri.parse('${ApiConfig.backendUrl}/api/reviews');
    
    final payload = {
      "username": username,
      "email": email,
      "module_type": moduleType,
      "title": title,
      "rating": rating,
      "feedback": feedback,
      "date": DateTime.now().toUtc().toIso8601String(),
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      debugPrint("POST Review Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to submit review: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error submitting review: $e");
      rethrow;
    }
  }
}
