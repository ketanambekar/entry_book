import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/entry_feed_item.dart';
import '../../data/repositories/account_repository.dart';
import '../../utils/helpers.dart';
import '../../routes/app_routes.dart';

class EntriesController extends GetxController {
  final AccountRepository repository = Get.find<AccountRepository>();

  final entrySearch = ''.obs;
  final entriesSearchController = TextEditingController();

  List<EntryFeedItem> get entries => repository.getEntries(query: entrySearch.value);

  void openAccountDetails(String accountNumber) {
    Get.toNamed(AppRoutes.accountDetails, arguments: accountNumber);
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

  @override
  void onClose() {
    entriesSearchController.dispose();
    super.onClose();
  }
}

