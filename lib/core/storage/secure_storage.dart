import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = const FlutterSecureStorage();

  static const _tokenKey = "auth_token";
  static const _authMethodKey = "auth_method";
  static const _userEmailKey = "user_email";
  static const _userIdKey = "user_id";

  // Token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Auth method ("google" or "email")
  Future<void> saveAuthMethod(String method) async {
    await _storage.write(key: _authMethodKey, value: method);
  }

  Future<String?> getAuthMethod() async {
    return await _storage.read(key: _authMethodKey);
  }

  // User email
  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _userEmailKey, value: email);
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  // User ID (details table id)
  Future<void> saveUserId(String id) async {
    await _storage.write(key: _userIdKey, value: id);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  // Clear all
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}