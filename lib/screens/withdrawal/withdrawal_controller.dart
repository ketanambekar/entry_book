import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:entry_book/domain/withdrawal/withdrawal_calculator.dart';

class WithdrawalController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final balanceController = TextEditingController();
  final additionalCollections = <TextEditingController>[].obs;
  final openedAt = Rxn<DateTime>();
  final withdrawnAt = Rxn<DateTime>();
  final result = Rxn<WithdrawalEstimate>();
  final dateError = RxnString();

  void addCollection() {
    additionalCollections.add(TextEditingController());
    invalidate();
  }

  void removeCollection(TextEditingController entry) {
    additionalCollections.remove(entry);
    // Let the field unmount before releasing its controller.
    WidgetsBinding.instance.addPostFrameCallback((_) => entry.dispose());
    invalidate();
  }

  BigInt get collectedPrincipalPaise =>
      [balanceController, ...additionalCollections].fold<BigInt>(
        BigInt.zero,
        (total, entry) => total + WithdrawalCalculator.parsePaise(entry.text),
      );

  void invalidate() {
    result.value = null;
    dateError.value = null;
  }

  void calculate() {
    final valid = formKey.currentState!.validate();
    if (openedAt.value == null || withdrawnAt.value == null) {
      dateError.value = 'Choose both dates.';
      return;
    }
    if (withdrawnAt.value!.isBefore(openedAt.value!)) {
      dateError.value = 'Withdrawal date cannot be before opening date.';
      return;
    }
    if (!valid) return;
    FocusManager.instance.primaryFocus?.unfocus();
    dateError.value = null;
    result.value = WithdrawalCalculator.estimate(
      collectedPrincipalPaise,
      WithdrawalCalculator.completedMonths(openedAt.value!, withdrawnAt.value!),
    );
  }

  @override
  void onClose() {
    balanceController.dispose();
    for (final entry in additionalCollections) {
      entry.dispose();
    }
    super.onClose();
  }
}
