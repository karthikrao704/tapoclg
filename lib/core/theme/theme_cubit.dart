import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const _themeKey = 'theme_mode';
  final _storage = const FlutterSecureStorage();

  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final savedTheme = await _storage.read(key: _themeKey);
      if (savedTheme == 'dark') {
        emit(ThemeMode.dark);
      } else {
        emit(ThemeMode.light);
      }
    } catch (_) {
      // Default to light if read fails
      emit(ThemeMode.light);
    }
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    emit(newMode);
    try {
      await _storage.write(
        key: _themeKey,
        value: newMode == ThemeMode.dark ? 'dark' : 'light',
      );
    } catch (_) {}
  }
}
