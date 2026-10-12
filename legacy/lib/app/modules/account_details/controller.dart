import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/account_model.dart';
import '../../data/models/entry_model.dart';
import '../../data/repositories/account_repository.dart';
import '../../routes/app_routes.dart';
import '../../utils/helpers.dart';

class AccountDetailsController extends GetxController {
  final account = Rxn<AccountModel>();
  final AccountRepository _repository = Get.find<AccountRepository>();
  String? _accountNumber;

  @override
  void onInit() {
    super.onInit();
    _accountNumber = Get.arguments as String?;
    if (_accountNumber != null) {
      account.value = _repository.findByAccountNumber(_accountNumber!);
    }

    ever<List<AccountModel>>(_repository.accounts, (_) => _refresh());
  }

  int get totalEntries => account.value?.entries.length ?? 0;

  double get averageEntryAmount {
    final entries = account.value?.entries ?? <dynamic>[];
    if (entries.isEmpty) {
      return 0;
    }
    return (account.value?.totalAmount ?? 0) / entries.length;
  }

  DateTime? get latestEntryDate {
    final entries = account.value?.entries;
    if (entries == null || entries.isEmpty) {
      return null;
    }

    final sorted = entries.toList()..sort((a, b) => b.date.compareTo(a.date));
    return sorted.first.date;
  }

  void openAddEntry() {
    final number = account.value?.accountNumber;
    if (number == null) {
      return;
    }
    Get.toNamed(AppRoutes.dailyEntry, arguments: number);
  }

  void openCloseAccountFlow() {
    final number = account.value?.accountNumber;
    if (number == null) {
      return;
    }
    Get.toNamed(AppRoutes.closeAccount, arguments: number);
  }

  Future<void> promptEditAccount() async {
    final target = account.value;
    if (target == null) {
      return;
    }

    final nameController = TextEditingController(text: target.accountName);
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Edit Account'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Account Holder Name'),
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

    final error = await _repository.updateAccount(
      accountNumber: target.accountNumber,
      accountName: nameController.text,
    );
    if (error != null) {
      Helpers.showError(error);
      return;
    }
    Helpers.showSuccess('Account updated successfully');
  }

  Future<void> promptEditEntry(EntryModel entry) async {
    final target = account.value;
    if (target == null) {
      return;
    }

    final amountController = TextEditingController(
      text: entry.amount.toStringAsFixed(2),
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

    final error = await _repository.updateEntry(
      accountNumber: target.accountNumber,
      originalDate: entry.date,
      originalAmount: entry.amount,
      newAmount: parsed,
    );
    if (error != null) {
      Helpers.showError(error);
      return;
    }
    Helpers.showSuccess('Entry updated successfully');
  }

  Future<void> deleteEntry(EntryModel entry) async {
    final target = account.value;
    if (target == null) {
      return;
    }

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

    final error = await _repository.deleteEntry(
      accountNumber: target.accountNumber,
      entryDate: entry.date,
      entryAmount: entry.amount,
    );
    if (error != null) {
      Helpers.showError(error);
      return;
    }
    Helpers.showSuccess('Entry deleted successfully');
  }

  void _refresh() {
    if (_accountNumber == null) {
      return;
    }
    account.value = _repository.findByAccountNumber(_accountNumber!);
  }
}
