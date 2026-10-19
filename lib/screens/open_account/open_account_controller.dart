import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:entry_book/domain/withdrawal/withdrawal_calculator.dart';

import 'package:entry_book/screens/open_account/widgets/account_preview_dialog.dart';

class OpenAccountController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final openingAmountController = TextEditingController();
  final phoneController = TextEditingController();

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter the account holder name.';
    }
    return null;
  }

  String? validateAccountNumber(String? value) {
    final number = value?.trim() ?? '';
    if (number.isEmpty) return 'Enter the account number.';
    if (!RegExp(r'^[0-9]+$').hasMatch(number)) {
      return 'Use digits only for the account number.';
    }
    return null;
  }

  String? validateOpeningAmount(String? value) {
    return WithdrawalCalculator.validateAmount(value, optional: true);
  }

  String? validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return null;
    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      return 'Enter a 10-digit phone number, or leave it blank.';
    }
    return null;
  }

  String get openingAmountDisplay {
    final amount = openingAmountController.text.trim();
    if (amount.isEmpty) return '0.00';
    final parts = amount.split('.');
    final whole = parts.first.replaceFirst(RegExp(r'^0+(?=[0-9])'), '');
    final fraction = parts.length == 1 ? '00' : parts[1].padRight(2, '0');
    return '$whole.$fraction';
  }

  void previewAccount() {
    if (!formKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    Get.dialog<void>(
      AccountPreviewDialog(
        name: nameController.text.trim(),
        accountNumber: accountNumberController.text.trim(),
        openingAmount: openingAmountDisplay,
        phone: phoneController.text.trim(),
      ),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    accountNumberController.dispose();
    openingAmountController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
