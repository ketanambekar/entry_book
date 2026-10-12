import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../data/models/account_model.dart';
import '../../data/models/entry_feed_item.dart';
import '../../data/repositories/account_repository.dart';
import '../../routes/app_routes.dart';
import '../../services/app_settings_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class DashboardController extends GetxController {
  final AccountRepository repository = Get.find<AccountRepository>();
  final AppSettingsService settingsService = Get.find<AppSettingsService>();

  final entrySearch = ''.obs;
  final accountSearch = ''.obs;
  final appName = AppConstants.appDisplayName.obs;
  final appVersion = 'Loading...'.obs;
  final welcomeUserName = 'User'.obs;
  final isImportingCsv = false.obs;
  final isDownloadingReport = false.obs;
  final isTakingBackup = false.obs;

  final entriesSearchController = TextEditingController();
  final accountSearchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadAppVersion();
  }

  void openAccount() => Get.toNamed(AppRoutes.openAccount);

  void openDailyEntry() => Get.toNamed(AppRoutes.dailyEntry);

  void openEntries() => Get.toNamed(AppRoutes.entries);

  void openReports() => Get.toNamed(AppRoutes.reports);

  void openAccounts() => Get.toNamed(AppRoutes.accountList);

  void openClosedAccounts() => Get.toNamed(AppRoutes.closedAccounts);

  void openSettings() => Get.toNamed(AppRoutes.settings);

  void openCloseFlow() => Get.toNamed(AppRoutes.closeAccount);

  void openAccountDetails(String accountNumber) {
    Get.toNamed(AppRoutes.accountDetails, arguments: accountNumber);
  }

  void goToAccountsTab() => openAccounts();

  void goToExistingAccountsPage() => Get.toNamed(AppRoutes.accountList);

  void goToActiveAccountsTab() => openAccounts();

  void goToClosedAccountsTab() => openClosedAccounts();

  void goToEntriesTab() => openEntries();

  void goToReportsTab() => openReports();

  List<AccountModel> get recentAccounts => repository.getRecentAccounts(limit: 5);

  List<EntryFeedItem> get recentEntries => repository.getRecentEntries(limit: 5);

  List<EntryFeedItem> get entries => repository.getEntries(query: entrySearch.value);

  List<AccountModel> get activeAccounts =>
      repository.searchAccounts(query: accountSearch.value, status: AccountStatus.active);

  List<AccountModel> get closedAccounts =>
      repository.searchAccounts(query: accountSearch.value, status: AccountStatus.closed);

  Map<String, num> get summary => repository.getSummary();

  DateTime? get lastUpdatedAt => repository.lastUpdatedAt;

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

  Future<void> downloadReport() async {
    isDownloadingReport.value = true;
    await repository.exportReport();
    isDownloadingReport.value = false;

    final exportError = repository.lastExportError.value;
    if (exportError != null) {
      Helpers.showError(exportError);
      return;
    }

    final path = repository.lastExportPath.value;
    if (path == null) {
      Helpers.showError('Report export failed');
      return;
    }

    final message = repository.lastExportMessage.value;
    Helpers.showSuccess(message == null ? 'Report downloaded: $path' : '$message\n$path');
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

  Future<void> promptEditAccount(AccountModel account) async {
    final nameController = TextEditingController(text: account.accountName);
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Edit Account'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Account Holder Name',
          ),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Get.back(result: true), child: const Text('Save')),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final error = await repository.updateAccount(
      accountNumber: account.accountNumber,
      accountName: nameController.text,
    );
    if (error != null) {
      Helpers.showError(error);
      return;
    }
    Helpers.showSuccess('Account updated successfully');
  }

  Future<void> promptEditEntry(EntryFeedItem item) async {
    final amountController = TextEditingController(
      text: item.amount.toStringAsFixed(2),
    );

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Edit Entry Amount'),
        content: TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount'),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Get.back(result: true), child: const Text('Save')),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final parsed = double.tryParse(amountController.text.trim());
    if (parsed == null || parsed <= 0) {
      Helpers.showError('Enter a valid amount');
      return;
    }

    final error = await repository.updateEntry(
      accountNumber: item.accountNumber,
      originalDate: item.date,
      originalAmount: item.amount,
      newAmount: parsed,
    );
    if (error != null) {
      Helpers.showError(error);
      return;
    }
    Helpers.showSuccess('Entry updated successfully');
  }

  Future<void> deleteEntry(EntryFeedItem item) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('This entry will be removed permanently.'),
        actions: <Widget>[
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Get.back(result: true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final error = await repository.deleteEntry(
      accountNumber: item.accountNumber,
      entryDate: item.date,
      entryAmount: item.amount,
    );
    if (error != null) {
      Helpers.showError(error);
      return;
    }
    Helpers.showSuccess('Entry deleted successfully');
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

  Future<void> _loadAppVersion() async {
    await _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    appName.value = info.appName.trim().isEmpty ? AppConstants.appDisplayName : info.appName;
    appVersion.value = 'v${info.version} (${info.buildNumber})';
  }

  @override
  void onClose() {
    entriesSearchController.dispose();
    accountSearchController.dispose();
    super.onClose();
  }
}
