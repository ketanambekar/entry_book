import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppSettingsService extends GetxService {
  static const _themeModeKey = 'settings.themeMode';
  static const _compactEntriesKey = 'settings.compactEntries';
  static const _confirmCloseKey = 'settings.confirmBeforeClose';

  final GetStorage _box = GetStorage();

  final themeMode = ThemeMode.system.obs;
  final compactEntries = false.obs;
  final confirmBeforeClose = true.obs;

  Future<AppSettingsService> init() async {
    final savedTheme = _box.read<String>(_themeModeKey);
    themeMode.value = _parseThemeMode(savedTheme);

    compactEntries.value = _box.read<bool>(_compactEntriesKey) ?? false;
    confirmBeforeClose.value = _box.read<bool>(_confirmCloseKey) ?? true;
    return this;
  }

  Future<void> setThemeMode(ThemeMode value) async {
    themeMode.value = value;
    await _box.write(_themeModeKey, value.name);
  }

  Future<void> setCompactEntries(bool value) async {
    compactEntries.value = value;
    await _box.write(_compactEntriesKey, value);
  }

  Future<void> setConfirmBeforeClose(bool value) async {
    confirmBeforeClose.value = value;
    await _box.write(_confirmCloseKey, value);
  }

  ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
