import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; 
import '../../../../core/storage/local_database.dart';
import '../../../../core/config/api_config.dart';

class ProfileRepository {
  String get _baseUrl => '${ApiConfig.authProfileBackendUrl}/api/details';

  // ─── Helper: resolve userId from local DB ────────────────────────────────

  Future<int> _getLocalUserId() async {
    final idStr = await LocalDatabase.getUserId();
    if (idStr == null) throw ProfilePhotoException('User not logged in.');
    final id = int.tryParse(idStr);
    if (id == null) throw ProfilePhotoException('Invalid user ID: $idStr');
    return id;
  }
  // ─── GET membership details ───────────────────────────────────────────────

  Future<Map<String, dynamic>> getMembershipDetails() async {
    final userId = await _getLocalUserId();
    final uri = Uri.parse('${ApiConfig.authProfileBackendUrl}/api/membership?userId=$userId');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] == true && json['membership'] != null) {
        return json['membership'] as Map<String, dynamic>;
      }
    }
    throw ProfilePhotoException(
      'Failed to load membership details (status ${response.statusCode}).',
    );
  }

  // ─── POST (SAVE/UPDATE) membership details ────────────────────────────────

  Future<Map<String, dynamic>> saveMembershipDetails({
    required String membershipName,
    required int availableCredits,
    String? purchaseDate,
  }) async {
    final userId = await _getLocalUserId();
    final uri = Uri.parse('${ApiConfig.authProfileBackendUrl}/api/membership');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'membership_name': membershipName,
        'available_credits': availableCredits,
        if (purchaseDate != null) 'purchase_date': purchaseDate,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] == true && json['membership'] != null) {
        return json['membership'] as Map<String, dynamic>;
      }
    }
    throw ProfilePhotoException(
      'Failed to save membership details (status ${response.statusCode}).',
    );
  }

  // ─── GET user details ─────────────────────────────────────────────────────

  Future<UserProfile> getUserDetails() async {
    final userId = await _getLocalUserId();
    final uri = Uri.parse('$_baseUrl/$userId');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return UserProfile.fromJson(json['user'] as Map<String, dynamic>);
    }

    throw ProfilePhotoException(
      'Failed to load profile (status ${response.statusCode}).',
    );
  }

  // ─── PATCH profile photo ──────────────────────────────────────────────────

  Future<String> uploadProfilePhoto({required String filePath}) async {
    final userId = await _getLocalUserId();
    final uri = Uri.parse('$_baseUrl/$userId/profile-photo');
    final file = File(filePath);

    final fileSize = await file.length();
    if (fileSize > 5 * 1024 * 1024) {
      throw ProfilePhotoException('File size must not exceed 5 MB.');
    }

    final ext = filePath.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png'].contains(ext)) {
      throw ProfilePhotoException('Only .jpg and .png files are allowed.');
    }

    // ✅ FIX: Set the correct content type based on extension
    String mimeType;
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        mimeType = 'image/jpeg';
        break;
      case 'png':
        mimeType = 'image/png';
        break;
      case 'webp':
        mimeType = 'image/webp';
        break;
      default:
        mimeType = 'image/jpeg';
    }

    final request = http.MultipartRequest('PATCH', uri);
    request.files.add(
      await http.MultipartFile.fromPath(
        'profile_photo',
        filePath,
        contentType: MediaType(
          'image',
          ext == 'png' ? 'png' : 'jpeg',
        ), // ✅ ADD THIS
      ),
    );

    print('📤 Uploading with mime: $mimeType');

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('📡 Response status: ${response.statusCode}');
    print('📡 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] == true) {
        return (json['data'] as Map<String, dynamic>)['profile_photo_url']
            as String;
      }
      throw ProfilePhotoException(
        json['message'] as String? ?? 'Upload failed.',
      );
    }

    throw ProfilePhotoException(
      'Upload failed (status ${response.statusCode}).',
    );
  }

  // ─── DELETE profile photo ─────────────────────────────────────────────────

  Future<void> deleteProfilePhoto() async {
    final userId = await _getLocalUserId();
    final uri = Uri.parse('$_baseUrl/$userId/profile-photo');

    final response = await http.delete(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] == true) return;
      throw ProfilePhotoException(
        json['message'] as String? ?? 'Delete failed.',
      );
    }

    throw ProfilePhotoException(
      'Delete failed (status ${response.statusCode}).',
    );
  }
}

// ─── UserProfile model ────────────────────────────────────────────────────────

class UserProfile {
  final int id;
  final String email;
  final String name;
  final String? gender;
  final String? city;
  final String? address;
  final String? phone;
  final String? dob;
  final String? healthConcerns;
  final String? preferredTherapies;
  final String? allergies;
  final String? membership;
  final String? createdAt;
  final bool twoStepVerification;
  final String? profilePhotoUrl;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.gender,
    this.city,
    this.address,
    this.phone,
    this.dob,
    this.healthConcerns,
    this.preferredTherapies,
    this.allergies,
    this.membership,
    this.createdAt,
    this.twoStepVerification = false,
    this.profilePhotoUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      gender: json['gender'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      dob: json['dob'] as String?,
      healthConcerns: json['health_concerns'] as String?,
      preferredTherapies: json['preferred_therapies'] as String?,
      allergies: json['allergies'] as String?,
      membership: json['membership'] as String?,
      createdAt: json['created_at'] as String?,
      twoStepVerification: json['two_step_verification'] as bool? ?? false,
      profilePhotoUrl: json['profile_photo_url'] as String?,
    );
  }

  /// Formats "2026-03-12T18:05:34.699Z" → "March 2026"
  String get memberSinceFormatted {
    if (createdAt == null) return '';
    try {
      final dt = DateTime.parse(createdAt!);
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return '';
    }
  }
}

class ProfilePhotoException implements Exception {
  final String message;
  const ProfilePhotoException(this.message);

  @override
  String toString() => message;
}
