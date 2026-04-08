import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/repositories/account_repository.dart';
import '../../utils/helpers.dart';

class OpenAccountController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final accountNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final amountController = TextEditingController();
  final creationDate = DateTime.now().obs;
  final isSubmitting = false.obs;

  final AccountRepository _repository = Get.find<AccountRepository>();

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    isSubmitting.value = true;
    final error = await _repository.createAccount(
      accountName: accountNameController.text,
      accountNumber: accountNumberController.text,
      amount: double.parse(amountController.text.trim()),
      creationDate: creationDate.value,
    );
    isSubmitting.value = false;

    if (error != null) {
      Helpers.showError(error);
      return;
    }

    Helpers.showSuccess('Account created successfully');
    accountNameController.clear();
    accountNumberController.clear();
    amountController.clear();
    creationDate.value = DateTime.now();
  }

  Future<void> pickDate() async {
    final selected = await showDatePicker(
      context: Get.context!,
      initialDate: creationDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      creationDate.value = selected;
    }
  }

  @override
  void onClose() {
    accountNameController.dispose();
    accountNumberController.dispose();
    amountController.dispose();
    super.onClose();
  }
}
