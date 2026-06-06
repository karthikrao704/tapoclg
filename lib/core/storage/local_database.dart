import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class LocalDatabase {
  static Database? _database;
  static const String _dbName = 'tapovana.db';
  static const int _dbVersion = 3;  
  static const String _userTable = 'local_user';
  static const String _userInfoTable = 'user_info';  

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
      onUpgrade: _onUpgrade,
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

    await db.execute('''
      CREATE TABLE $_userInfoTable (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE appointments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        service_name TEXT,
        date TEXT,
        time TEXT,
        therapist TEXT,
        price TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    debugPrint('✅ Local database created (version $version)');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_userInfoTable (
          key TEXT PRIMARY KEY,
          value TEXT
        )
      ''');
      debugPrint('✅ Database upgraded: v$oldVersion → v$newVersion (added user_info table)');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS appointments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          service_name TEXT,
          date TEXT,
          time TEXT,
          therapist TEXT,
          price TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
      ''');
      debugPrint('✅ Database upgraded: v$oldVersion → v$newVersion (added appointments table)');
    }
  }

  // ═══════════════════════════════════════
  //          SAVE USER
  // ═══════════════════════════════════════

  static Future<void> saveUser({
    required String userId,
    required String email,
    String? name,
    String? authMethod,
  }) async {
    final db = await database;

    await db.delete(_userTable);

    await db.insert(_userTable, {
      'user_id': userId,
      'email': email,
      'name': name ?? '',
      'auth_method': authMethod ?? 'email',
      'created_at': DateTime.now().toIso8601String(),
    });

    debugPrint('✅ User saved to local DB: $email ($userId)');
  }

  // ═══════════════════════════════════════
  //          GET USER
  // ═══════════════════════════════════════

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
    await db.update(_userTable, {'name': name});
    debugPrint('✅ User name updated to: $name');
  }

  // ═══════════════════════════════════════
  //          PROFILE PHOTO URL
  // ═══════════════════════════════════════

  static Future<void> saveProfilePhotoUrl(String? url) async {
    final db = await database;
    if (url != null) {
      await db.rawInsert(
        "INSERT OR REPLACE INTO $_userInfoTable (key, value) VALUES ('profile_photo_url', ?)",
        [url],
      );
      debugPrint('✅ Profile photo URL saved locally');
    } else {
      await db.rawDelete(
        "DELETE FROM $_userInfoTable WHERE key = 'profile_photo_url'",
      );
      debugPrint('✅ Profile photo URL removed locally');
    }
  }

  static Future<String?> getProfilePhotoUrl() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT value FROM $_userInfoTable WHERE key = 'profile_photo_url'",
    );
    if (result.isNotEmpty) {
      return result.first['value'] as String?;
    }
    return null;
  }

  // ═══════════════════════════════════════
  //          WELLNESS PASS
  // ═══════════════════════════════════════

  static Future<void> saveWellnessPass(String passType) async {
    final db = await database;
    await db.rawInsert(
      "INSERT OR REPLACE INTO $_userInfoTable (key, value) VALUES ('wellness_pass', ?)",
      [passType],
    );
    debugPrint('✅ Wellness pass saved locally: $passType');
  }

  static Future<String?> getWellnessPass() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT value FROM $_userInfoTable WHERE key = 'wellness_pass'",
    );
    if (result.isNotEmpty) {
      return result.first['value'] as String?;
    }
    return null;
  }

  // ═══════════════════════════════════════
  //          WELLNESS CREDITS
  // ═══════════════════════════════════════

  static Future<void> saveWellnessCredits(int credits) async {
    final db = await database;
    await db.rawInsert(
      "INSERT OR REPLACE INTO $_userInfoTable (key, value) VALUES ('wellness_credits', ?)",
      [credits.toString()],
    );
    debugPrint('✅ Wellness credits saved locally: $credits');
  }

  static Future<int?> getWellnessCredits() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT value FROM $_userInfoTable WHERE key = 'wellness_credits'",
    );
    if (result.isNotEmpty) {
      return int.tryParse(result.first['value'] as String? ?? '');
    }
    return null;
  }

  // ═══════════════════════════════════════
  //          DELETE USER (on logout)
  // ═══════════════════════════════════════

  static Future<void> deleteUser() async {
    final db = await database;
    await db.delete(_userTable);
    await db.delete(_userInfoTable); 
    debugPrint('✅ User deleted from local DB');
  }

  // ═══════════════════════════════════════
  //          APPOINTMENTS CRUD
  // ═══════════════════════════════════════

  static Future<void> insertAppointment({
    required String serviceName,
    required String date,
    required String time,
    required String therapist,
    required String price,
  }) async {
    final db = await database;
    await db.insert('appointments', {
      'service_name': serviceName,
      'date': date,
      'time': time,
      'therapist': therapist,
      'price': price,
    });
    debugPrint('✅ Appointment saved locally: $serviceName');
  }

  static Future<List<Map<String, dynamic>>> getAppointments() async {
    final db = await database;
    return await db.query('appointments', orderBy: 'id DESC');
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