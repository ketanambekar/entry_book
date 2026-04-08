import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/account_model.dart';
import '../../data/repositories/account_repository.dart';
import '../../utils/helpers.dart';

class ClosedAccountsController extends GetxController {
  ClosedAccountsController({required this.showCloseFlow});

  final bool showCloseFlow;
  final AccountRepository _repository = Get.find<AccountRepository>();

  final searchController = TextEditingController();
  final amountController = TextEditingController();
  final selectedAccountNumber = RxnString();
  final closedAccounts = <AccountModel>[].obs;
  final activeAccounts = <AccountModel>[].obs;
  final isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    final preselected = Get.arguments is String ? Get.arguments as String : null;
    if (preselected != null && preselected.isNotEmpty) {
      selectedAccountNumber.value = preselected;
    }
    _reload();
    ever<List<AccountModel>>(_repository.accounts, (_) => _reload());
  }

  void _reload() {
    closedAccounts.assignAll(_repository.closedAccounts);
    activeAccounts.assignAll(_repository.activeAccounts);
    filterClosed(searchController.text);
  }

  void filterClosed(String value) {
    final query = value.trim().toLowerCase();
    final base = _repository.closedAccounts;
    if (query.isEmpty) {
      closedAccounts.assignAll(base);
      return;
    }
    closedAccounts.assignAll(
      base.where(
        (a) => a.accountNumber.toLowerCase().contains(query) ||
            a.accountName.toLowerCase().contains(query),
      ),
    );
  }

  Future<void> closeSelectedAccount() async {
    final accountNumber = selectedAccountNumber.value;
    final amount = double.tryParse(amountController.text.trim());

    if (accountNumber == null || accountNumber.isEmpty) {
      Helpers.showError('Please select an account');
      return;
    }
    if (amount == null || amount <= 0) {
      Helpers.showError('Enter valid closing amount');
      return;
    }

    isProcessing.value = true;
    final error = await _repository.closeAccount(
      accountNumber: accountNumber,
      closingAmount: amount,
    );
    isProcessing.value = false;

    if (error != null) {
      Helpers.showError(error);
      return;
    }

    Helpers.showSuccess('Account closed successfully');
    selectedAccountNumber.value = null;
    amountController.clear();
    _reload();
  }

  @override
  void onClose() {
    searchController.dispose();
    amountController.dispose();
    super.onClose();
  }
}
