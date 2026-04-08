import 'package:get/get.dart';

import '../../services/csv_service.dart';
import '../../services/excel_service.dart';
import '../models/account_model.dart';
import '../models/entry_feed_item.dart';
import '../models/entry_model.dart';
import '../providers/local_storage_provider.dart';

class AccountRepository {
  AccountRepository({
    required AccountStorageProvider storageProvider,
    required ExcelService excelService,
    required CsvService csvService,
  })  : _storageProvider = storageProvider,
        _excelService = excelService,
        _csvService = csvService;

  final AccountStorageProvider _storageProvider;
  final ExcelService _excelService;
  final CsvService _csvService;

  final RxList<AccountModel> accounts = <AccountModel>[].obs;
  final RxnString lastExportPath = RxnString();
  final RxnString lastExportMessage = RxnString();
  final RxnString lastExportError = RxnString();
  final RxnString lastBackupPath = RxnString();
  final RxnString lastBackupMessage = RxnString();
  final RxnString lastBackupError = RxnString();
  final RxList<String> lastImportIssues = <String>[].obs;

  Future<void> load() async {
    accounts.assignAll(_storageProvider.getAccounts());
  }

  List<AccountModel> get allAccounts {
    final data = List<AccountModel>.from(accounts);
    data.sort((a, b) => b.creationDate.compareTo(a.creationDate));
    return data;
  }

  List<AccountModel> get activeAccounts =>
      allAccounts.where((a) => a.status == AccountStatus.active).toList();

  List<AccountModel> get closedAccounts =>
      allAccounts.where((a) => a.status == AccountStatus.closed).toList();

  List<AccountModel> searchAccounts({
    required String query,
    AccountStatus? status,
  }) {
    final normalized = query.trim().toLowerCase();
    final base = status == null
        ? allAccounts
        : allAccounts.where((a) => a.status == status).toList();

    if (normalized.isEmpty) {
      return base;
    }

    return base
        .where(
          (a) => a.accountName.toLowerCase().contains(normalized) ||
              a.accountNumber.toLowerCase().contains(normalized),
        )
        .toList();
  }

  List<EntryFeedItem> getEntries({String query = ''}) {
    final normalized = query.trim().toLowerCase();
    final items = <EntryFeedItem>[];

    for (final account in allAccounts) {
      for (final entry in account.entries) {
        final item = EntryFeedItem(
          accountName: account.accountName,
          accountNumber: account.accountNumber,
          amount: entry.amount,
          date: entry.date,
        );

        if (normalized.isEmpty ||
            item.accountName.toLowerCase().contains(normalized) ||
            item.accountNumber.toLowerCase().contains(normalized)) {
          items.add(item);
        }
      }
    }

    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  List<AccountModel> getRecentAccounts({int limit = 5}) {
    final list = allAccounts;
    return list.take(limit).toList();
  }

  List<EntryFeedItem> getRecentEntries({int limit = 5}) {
    return getEntries().take(limit).toList();
  }

  DateTime? get lastUpdatedAt {
    if (accounts.isEmpty) {
      return null;
    }

    var latest = allAccounts.first.creationDate;
    for (final account in accounts) {
      if (account.creationDate.isAfter(latest)) {
        latest = account.creationDate;
      }
      for (final entry in account.entries) {
        if (entry.date.isAfter(latest)) {
          latest = entry.date;
        }
      }
    }
    return latest;
  }

  bool accountNumberExists(String accountNumber) {
    return accounts.any((a) => a.accountNumber == accountNumber.trim());
  }

  AccountModel? findByAccountNumber(String accountNumber) {
    try {
      return accounts.firstWhere((a) => a.accountNumber == accountNumber.trim());
    } catch (_) {
      return null;
    }
  }

  Future<String?> createAccount({
    required String accountName,
    required String accountNumber,
    required double amount,
    required DateTime creationDate,
  }) async {
    if (accountNumberExists(accountNumber)) {
      return 'Account number already exists';
    }

    final account = AccountModel(
      accountName: accountName.trim(),
      accountNumber: accountNumber.trim(),
      creationDate: creationDate,
      totalAmount: amount,
      status: AccountStatus.active,
      entries: <EntryModel>[
        EntryModel(amount: amount, date: creationDate),
      ],
    );

    accounts.add(account);
    await _persist();
    return null;
  }

  Future<String?> addEntry({
    required String accountNumber,
    required double amount,
    required DateTime date,
  }) async {
    final index = accounts.indexWhere((a) => a.accountNumber == accountNumber.trim());
    if (index == -1) {
      return 'Account not found';
    }

    final target = accounts[index];
    if (target.isClosed) {
      return 'Cannot add entry to closed account';
    }

    final entries = List<EntryModel>.from(target.entries)
      ..add(EntryModel(amount: amount, date: date));

    accounts[index] = target.copyWith(
      entries: entries,
      totalAmount: target.totalAmount + amount,
    );

    await _persist();

    await exportReport();

    return null;
  }

  Future<void> exportReport() async {
    try {
      final export = await _excelService.exportAccounts(allAccounts);
      lastExportPath.value = export.path;
      lastExportMessage.value = export.message;
      lastExportError.value = null;
    } catch (error) {
      lastExportError.value = 'Excel export failed: $error';
      lastExportMessage.value = null;
      lastExportPath.value = null;
    }
  }

  Future<void> exportBackup() async {
    try {
      final backup = await _csvService.exportBackupCsv(allAccounts);
      lastBackupPath.value = backup.path;
      lastBackupMessage.value = backup.message;
      lastBackupError.value = null;
    } catch (error) {
      lastBackupError.value = 'CSV backup export failed: $error';
      lastBackupPath.value = null;
      lastBackupMessage.value = null;
    }
  }

  Future<String?> closeAccount({
    required String accountNumber,
    required double closingAmount,
  }) async {
    final index = accounts.indexWhere((a) => a.accountNumber == accountNumber.trim());
    if (index == -1) {
      return 'Account not found';
    }

    final target = accounts[index];
    if (target.isClosed) {
      return 'Account already closed';
    }

    accounts[index] = target.copyWith(
      status: AccountStatus.closed,
      closingAmount: closingAmount,
    );

    await _persist();
    return null;
  }

  Future<String?> updateAccount({
    required String accountNumber,
    required String accountName,
  }) async {
    final index = accounts.indexWhere((a) => a.accountNumber == accountNumber.trim());
    if (index == -1) {
      return 'Account not found';
    }

    final trimmedName = accountName.trim();
    if (trimmedName.isEmpty) {
      return 'Account name is required';
    }

    final target = accounts[index];
    accounts[index] = target.copyWith(accountName: trimmedName);
    await _persist();
    await exportReport();
    return null;
  }

  Future<String?> updateEntry({
    required String accountNumber,
    required DateTime originalDate,
    required double originalAmount,
    required double newAmount,
    DateTime? newDate,
  }) async {
    final accountIndex =
        accounts.indexWhere((a) => a.accountNumber == accountNumber.trim());
    if (accountIndex == -1) {
      return 'Account not found';
    }

    if (newAmount <= 0) {
      return 'Amount must be greater than 0';
    }

    final account = accounts[accountIndex];
    final updatedEntries = List<EntryModel>.from(account.entries);
    final entryIndex = updatedEntries.indexWhere(
      (e) => e.date.isAtSameMomentAs(originalDate) && e.amount == originalAmount,
    );

    if (entryIndex == -1) {
      return 'Entry not found';
    }

    updatedEntries[entryIndex] = EntryModel(
      amount: newAmount,
      date: newDate ?? originalDate,
    );

    final recalculatedTotal =
        updatedEntries.fold<double>(0, (sum, e) => sum + e.amount);

    accounts[accountIndex] = account.copyWith(
      entries: updatedEntries,
      totalAmount: recalculatedTotal,
    );

    await _persist();
    await exportReport();
    return null;
  }

  Future<String?> deleteEntry({
    required String accountNumber,
    required DateTime entryDate,
    required double entryAmount,
  }) async {
    final accountIndex =
        accounts.indexWhere((a) => a.accountNumber == accountNumber.trim());
    if (accountIndex == -1) {
      return 'Account not found';
    }

    final account = accounts[accountIndex];
    final updatedEntries = List<EntryModel>.from(account.entries);
    final entryIndex = updatedEntries.indexWhere(
      (e) => e.date.isAtSameMomentAs(entryDate) && e.amount == entryAmount,
    );

    if (entryIndex == -1) {
      return 'Entry not found';
    }

    updatedEntries.removeAt(entryIndex);

    final recalculatedTotal =
        updatedEntries.fold<double>(0, (sum, e) => sum + e.amount);

    accounts[accountIndex] = account.copyWith(
      entries: updatedEntries,
      totalAmount: recalculatedTotal,
    );

    await _persist();
    await exportReport();
    return null;
  }

  Future<String?> importFromCsv() async {
    final parsed = await _csvService.pickAndParseCsv();
    if (parsed == null) {
      return 'Import cancelled';
    }

    accounts.assignAll(parsed.accounts);
    lastImportIssues.assignAll(parsed.issues);
    await _persist();

    if (parsed.accounts.isEmpty) {
      return 'No valid account rows were imported';
    }

    return null;
  }

  Map<String, num> getSummary() {
    final active = activeAccounts.length;
    final closed = closedAccounts.length;
    final total = allAccounts.length;
    final balance = allAccounts.fold<double>(0, (sum, a) => sum + a.totalAmount);
    final entries = allAccounts.fold<int>(0, (sum, a) => sum + a.entries.length);

    return <String, num>{
      'totalAccounts': total,
      'activeAccounts': active,
      'closedAccounts': closed,
      'totalBalance': balance,
      'totalEntries': entries,
    };
  }

  Future<void> _persist() async {
    await _storageProvider.saveAccounts(accounts);
    accounts.refresh();
  }
}
