import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../data/repositories/account_repository.dart';
import '../../services/app_settings_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class SettingsController extends GetxController {
  final AppSettingsService settingsService = Get.find<AppSettingsService>();
  final AccountRepository repository = Get.find<AccountRepository>();

  final appName = AppConstants.appDisplayName.obs;
  final appVersion = 'Loading...'.obs;
  final isImportingCsv = false.obs;
  final isTakingBackup = false.obs;

  DateTime? get lastUpdatedAt => repository.lastUpdatedAt;

  @override
  void onInit() {
    super.onInit();
    _loadAppInfo();
  }

  Future<void> importCsv() async {
    isImportingCsv.value = true;
    final error = await repository.importFromCsv();
    isImportingCsv.value = false;

    if (error == 'Import cancelled') {
      return;
    }

    if (error != null) {
      Helpers.showError(error);
      return;
    }

    if (repository.lastImportIssues.isEmpty) {
      Helpers.showSuccess('CSV import completed');
      return;
    }

    Helpers.showSuccess(
      'CSV import completed with ${repository.lastImportIssues.length} warning(s)',
    );
  }

  Future<void> takeBackup() async {
    isTakingBackup.value = true;
    await repository.exportBackup();
    isTakingBackup.value = false;

    final backupError = repository.lastBackupError.value;
    if (backupError != null) {
      Helpers.showError(backupError);
      return;
    }

    final path = repository.lastBackupPath.value;
    if (path == null) {
      Helpers.showError('Backup export failed');
      return;
    }

    final message = repository.lastBackupMessage.value;
    Helpers.showSuccess(message == null ? 'Backup downloaded: $path' : '$message\n$path');
  }

  Future<void> setThemeMode(ThemeMode mode) {
    return settingsService.setThemeMode(mode);
  }

  Future<void> setCompactEntries(bool value) {
    return settingsService.setCompactEntries(value);
  }

  Future<void> setConfirmBeforeClose(bool value) {
    return settingsService.setConfirmBeforeClose(value);
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    appName.value = info.appName.trim().isEmpty ? AppConstants.appDisplayName : info.appName;
    appVersion.value = 'v${info.version} (${info.buildNumber})';
  }
}

