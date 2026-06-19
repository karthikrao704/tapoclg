import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tapovana_mobile_app/core/config/api_config.dart';
import 'package:tapovana_mobile_app/core/services/notification_service.dart';

class BookingRepository {
  BookingRepository._();

  static Future<bool> createBooking({
    required String userName,
    required String email,
    String? profilePic,
    required String serviceName,
    required String bookingDate,
    required String bookingTime,
    String? note,
    required String totalAmount,
    String? passDetails,
  }) async {
    final url = Uri.parse('${ApiConfig.backendUrl}/api/bookings');
    
    final Map<String, dynamic> body = {
      'userName': userName,
      'email': email,
      'profilePic': profilePic,
      'serviceName': serviceName,
      'bookingDate': bookingDate,
      'bookingTime': bookingTime,
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

  static void startPollingForBookingStatus(String email, String serviceName) {
    Timer? timer;
    int maxAttempts = 60; // 60 attempts * 5 seconds = 5 minutes
    int attempts = 0;
    
    debugPrint('🔄 Polling started for email: $email, service: $serviceName');

    timer = Timer.periodic(const Duration(seconds: 5), (t) async {
      attempts++;
      if (attempts > maxAttempts) {
        debugPrint('⏹️ Polling stopped after $maxAttempts attempts.');
        timer?.cancel();
        return;
      }

      final url = Uri.parse('${ApiConfig.backendUrl}/api/bookings');
      try {
        final response = await http.get(url).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true && data['bookings'] != null) {
            final List bookings = data['bookings'];
            
            // Log for debugging
            debugPrint('🔍 Polling attempt $attempts: Fetched ${bookings.length} bookings');
            
            // Find the most recent booking for this user and service
            final userBookings = bookings.where((b) {
              final bEmail = b['user_email']?.toString() ?? '';
              final bService = b['service_name']?.toString() ?? '';
              
              // More relaxed matching
              return bEmail.trim().toLowerCase() == email.trim().toLowerCase() && 
                     bService.trim().toLowerCase() == serviceName.trim().toLowerCase();
            }).toList();
            
            if (userBookings.isNotEmpty) {
              // Sort by id descending to get the latest
              userBookings.sort((a, b) {
                final idA = int.tryParse(a['id'].toString()) ?? 0;
                final idB = int.tryParse(b['id'].toString()) ?? 0;
                return idB.compareTo(idA);
              });
              
              final latestBooking = userBookings.first;
              final status = (latestBooking['status']?.toString() ?? '').toUpperCase();
              final therapistName = latestBooking['therapist_name']?.toString();

              debugPrint('📋 Latest booking status: $status, Therapist: $therapistName');

              if (status == 'CONFIRMED' && therapistName != null && therapistName.trim().isNotEmpty) {
                debugPrint('🎉 Booking confirmed! Triggering notification...');
                final bookingId = int.tryParse(latestBooking['id'].toString()) ?? 1000;
                
                // Show notification
                await NotificationService().showInstantNotification(
                  id: bookingId,
                  title: 'Booking Confirmed!',
                  body: 'Therapist $therapistName is assigned for your $serviceName.',
                );
                
                // Stop polling
                debugPrint('⏹️ Polling succeeded & stopped.');
                timer?.cancel();
              }
            } else {
              debugPrint('⚠️ No matching bookings found yet for $email and $serviceName');
            }
          }
        } else {
          debugPrint('⚠️ Polling received status code: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('❌ Polling error: $e');
      }
    });
  }
}
