import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class LocalDatabase {
  static Database? _database;
  static const String _dbName = 'tapovana.db';
  static const int _dbVersion = 1;
  static const String _userTable = 'local_user';

  // ═══════════════════════════════════════
  //          SINGLETON INIT
  // ═══════════════════════════════════════

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    debugPrint('📂 Database path: $path');

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_userTable (
        id INTEGER PRIMARY KEY,
        user_id TEXT NOT NULL,
        email TEXT NOT NULL,
        name TEXT,
        auth_method TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    debugPrint('✅ Local database created');
  }

  // ═══════════════════════════════════════
  //          SAVE USER
  // ═══════════════════════════════════════

  /// Save or update user in local DB
  /// Called after successful login or signup
  static Future<void> saveUser({
    required String userId,
    required String email,
    String? name,
    String? authMethod,
  }) async {
    final db = await database;

    // Delete any existing user (single user app)
    await db.delete(_userTable);

    // Insert new user
    await db.insert(
      _userTable,
      {
        'user_id': userId,
        'email': email,
        'name': name ?? '',
        'auth_method': authMethod ?? 'email',
        'created_at': DateTime.now().toIso8601String(),
      },
    );

    debugPrint('✅ User saved to local DB: $email ($userId)');
  }

  // ═══════════════════════════════════════
  //          GET USER
  // ═══════════════════════════════════════

  /// Get saved user from local DB
  static Future<Map<String, dynamic>?> getUser() async {
    final db = await database;
    final results = await db.query(_userTable, limit: 1);

    if (results.isNotEmpty) {
      debugPrint('✅ User found in local DB: ${results.first['email']}');
      return results.first;
    }

    debugPrint('❌ No user in local DB');
    return null;
  }

  // ═══════════════════════════════════════
  //          GET USER ID
  // ═══════════════════════════════════════

  static Future<String?> getUserId() async {
    final user = await getUser();
    return user?['user_id'] as String?;
  }

  // ═══════════════════════════════════════
  //          GET USER EMAIL
  // ═══════════════════════════════════════

  static Future<String?> getUserEmail() async {
    final user = await getUser();
    return user?['email'] as String?;
  }

  // ═══════════════════════════════════════
  //          GET USER NAME
  // ═══════════════════════════════════════

  static Future<String?> getUserName() async {
    final user = await getUser();
    return user?['name'] as String?;
  }

  // ═══════════════════════════════════════
  //          UPDATE USER NAME
  // ═══════════════════════════════════════

  static Future<void> updateUserName(String name) async {
    final db = await database;
    await db.update(
      _userTable,
      {'name': name},
    );
    debugPrint('✅ User name updated to: $name');
  }

  // ═══════════════════════════════════════
  //          DELETE USER (on logout)
  // ═══════════════════════════════════════

  static Future<void> deleteUser() async {
    final db = await database;
    await db.delete(_userTable);
    debugPrint('✅ User deleted from local DB');
  }

  // ═══════════════════════════════════════
  //          CLOSE DB
  // ═══════════════════════════════════════

  static Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    debugPrint('✅ Database closed');
  }
}