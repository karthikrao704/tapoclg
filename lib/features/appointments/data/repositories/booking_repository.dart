import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tapovana_mobile_app/core/config/api_config.dart';

class BookingRepository {
  BookingRepository._();

  static Future<bool> createBooking({
    required String userName,
    String? profilePic,
    required String serviceName,
    required String bookingDate,
    required String bookingTime,
    required String therapistName,
    String? note,
    required String totalAmount,
    String? passDetails,
  }) async {
    final url = Uri.parse('${ApiConfig.backendUrl}/api/bookings');
    
    final Map<String, dynamic> body = {
      'userName': userName,
      'profilePic': profilePic,
      'serviceName': serviceName,
      'bookingDate': bookingDate,
      'bookingTime': bookingTime,
      'therapistName': therapistName,
      'note': note,
      'totalAmount': totalAmount,
      'passDetails': passDetails,
    };

    try {
      debugPrint('📡 Sending booking details to backend: $url');
      debugPrint('📦 Payload: ${jsonEncode(body)}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 Response Code: ${response.statusCode}');
      debugPrint('📥 Response Body: ${response.body}');

      if (response.statusCode == 201) {
        debugPrint('✅ Booking synced with PostgreSQL Neon DB!');
        return true;
      } else {
        debugPrint('⚠️ Backend failed to process booking. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Network or database repository error during booking creation: $e');
      return false;
    }
  }
}
