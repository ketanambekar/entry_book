import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/account_model.dart';
import '../../data/repositories/account_repository.dart';
import '../../routes/app_routes.dart';
import '../../utils/helpers.dart';

class DailyEntryController extends GetxController {
  final searchController = TextEditingController();
  final amountController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final searchedAccount = Rxn<AccountModel>();

  final AccountRepository _repository = Get.find<AccountRepository>();

  @override
  void onInit() {
    super.onInit();
    final prefill = Get.arguments is String ? Get.arguments as String : null;
    if (prefill != null && prefill.isNotEmpty) {
      searchController.text = prefill;
      searchAccount();
    }
  }

  void searchAccount() {
    final account = _repository.findByAccountNumber(searchController.text);
    searchedAccount.value = account;
    if (account == null) {
      Helpers.showError('Account not found');
    }
  }

  Future<void> submitEntry() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    final account = searchedAccount.value;
    if (account == null) {
      Helpers.showError('Search and select an account first');
      return;
    }

    isLoading.value = true;
    final error = await _repository.addEntry(
      accountNumber: account.accountNumber,
      amount: double.parse(amountController.text.trim()),
      date: DateTime.now(),
    );
    isLoading.value = false;

    if (error != null) {
      Helpers.showError(error);
      return;
    }

    amountController.clear();
    searchedAccount.value = _repository.findByAccountNumber(account.accountNumber);

    final exportError = _repository.lastExportError.value;

    if (exportError != null) {
      Helpers.showError('Entry added, but backup export failed');
    } else {
      Helpers.showSuccess('Entry added successfully');
    }

    Get.toNamed(
      AppRoutes.confirmation,
      arguments: <String, dynamic>{
        'title': 'Entry Added',
        'message': 'Entry added successfully',
        'autoCloseSeconds': 4,
      },
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    amountController.dispose();
    super.onClose();
  }
}
