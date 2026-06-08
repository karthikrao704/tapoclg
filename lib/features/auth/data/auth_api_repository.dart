import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:tapovana_mobile_app/core/storage/secure_storage.dart';
import '../../../core/config/api_config.dart';

class AuthApiRepository {
  String get baseUrl => ApiConfig.authProfileBackendUrl;
  final SecureStorage _secureStorage = SecureStorage();

  // ═══════════════════════════════════════
  //   SIGNUP: send-otp
  //   Email: { email, password }
  //   Google: { email, provider: "google" }
  // ═══════════════════════════════════════

  /// Email signup: send OTP
  Future<Map<String, dynamic>> sendSignupOtp({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/signup/send-otp'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    debugPrint("SEND OTP RESPONSE: ${response.body}");
    return jsonDecode(response.body);
  }

  /// Google signup: check if user exists (no OTP needed)
  Future<Map<String, dynamic>> googleCheckUser({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/signup/send-otp'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "provider": "google"}),
    );
    debugPrint("GOOGLE CHECK USER RESPONSE: ${response.body}");
    return jsonDecode(response.body);
  }

  // ═══════════════════════════════════════
  //   SIGNUP: verify-otp (email only)
  // ═══════════════════════════════════════

  Future<Map<String, dynamic>> verifySignupOtp({
    required String email,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/signup/verify-otp'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );
    debugPrint("VERIFY OTP RESPONSE: ${response.body}");
    return jsonDecode(response.body);
  }

  // ═══════════════════════════════════════
  //   SIGNUP: complete
  //   Email: { email, password, name, gender, city }
  //   Google: { email, uid, provider: "google", name, gender, city }
  // ═══════════════════════════════════════

  /// Email signup complete
  Future<Map<String, dynamic>> completeSignup({
    required String email,
    required String password,
    required String name,
    required String gender,
    required String city,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/signup/complete'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
        "name": name,
        "gender": gender,
        "city": city,
      }),
    );
    debugPrint("COMPLETE SIGNUP RESPONSE: ${response.body}");
    return jsonDecode(response.body);
  }

  /// Google signup complete
  Future<Map<String, dynamic>> completeGoogleSignup({
    required String email,
    required String uid,
    required String name,
    required String gender,
    required String city,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/signup/complete'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "uid": uid,
        "provider": "google",
        "name": name,
        "gender": gender,
        "city": city,
      }),
    );

    debugPrint("GOOGLE SIGNUP COMPLETE RESPONSE: ${response.body}");
    final data = jsonDecode(response.body);

    if (data['success'] == true && data['token'] != null) {
      await _secureStorage.saveToken(data['token']);
      await _secureStorage.saveUserEmail(email);
      await _secureStorage.saveAuthMethod('google');
      if (data['user'] != null && data['user']['id'] != null) {
        await _secureStorage.saveUserId(data['user']['id'].toString());
      }
    }

    return data;
  }

  // ═══════════════════════════════════════
  //   LOGIN
  //   Email: { email, password }
  //   Google: { email, uid, provider: "google" }
  // ═══════════════════════════════════════

  /// Email login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    debugPrint("LOGIN RESPONSE: ${response.body}");
    final data = jsonDecode(response.body);

    if (data['success'] == true &&
        data['requires_otp'] == false &&
        data['token'] != null) {
      await _secureStorage.saveToken(data['token']);
      await _secureStorage.saveUserEmail(email);
      await _secureStorage.saveAuthMethod('email');
      if (data['user'] != null && data['user']['id'] != null) {
        await _secureStorage.saveUserId(data['user']['id'].toString());
      }
    }

    return data;
  }

  /// Google login
  Future<Map<String, dynamic>> googleLogin({
    required String email,
    required String uid,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "uid": uid,
        "provider": "google",
      }),
    );

    debugPrint("GOOGLE LOGIN RESPONSE: ${response.body}");
    final data = jsonDecode(response.body);

    if (data['success'] == true &&
        data['requires_otp'] == false &&
        data['token'] != null) {
      await _secureStorage.saveToken(data['token']);
      await _secureStorage.saveUserEmail(email);
      await _secureStorage.saveAuthMethod('google');
      if (data['user'] != null && data['user']['id'] != null) {
        await _secureStorage.saveUserId(data['user']['id'].toString());
      }
    }

    return data;
  }

  // ═══════════════════════════════════════
  //   LOGIN: verify-otp (same for both)
  // ═══════════════════════════════════════

  Future<Map<String, dynamic>> verifyLoginOtp({
    required String email,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/login/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );

    debugPrint("VERIFY LOGIN OTP RESPONSE: ${response.body}");
    final data = jsonDecode(response.body);

    if (data['success'] == true && data['token'] != null) {
      await _secureStorage.saveToken(data['token']);
      await _secureStorage.saveUserEmail(email);
      if (data['user'] != null && data['user']['id'] != null) {
        await _secureStorage.saveUserId(data['user']['id'].toString());
      }
    }

    return data;
  }

  // ═══════════════════════════════════════
  //   FORGOT PASSWORD
  // ═══════════════════════════════════════

  Future<Map<String, dynamic>> sendForgotPasswordOtp({required String email}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/signup/forgot-password/send-otp'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    debugPrint("FORGOT PASSWORD SEND OTP: ${response.body}");
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> verifyForgotPasswordOtp({required String email, required String otp}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/signup/forgot-password/verify-otp'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );
    debugPrint("FORGOT PASSWORD VERIFY OTP: ${response.body}");
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> resetPassword({required String email, required String newPassword}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/signup/forgot-password/reset'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "new_password": newPassword}),
    );
    debugPrint("FORGOT PASSWORD RESET: ${response.body}");
    return jsonDecode(response.body);
  }
}