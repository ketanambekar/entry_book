import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:entry_book/data/accounts/account.dart';
import 'package:entry_book/data/accounts/demo_account_repository.dart';
import 'package:entry_book/routes/app_routes.dart';

class DashboardController extends GetxController {
  void showWithdrawalCalculator() {
    Get.toNamed<void>(AppRoutes.withdrawal);
  }

  void showCollections() {
    Get.toNamed<void>(AppRoutes.collections);
  }

  void showReports() => _showComingSoon('Reports');

  void _showComingSoon(String title) {
    Get.dialog<void>(
      AlertDialog(
        title: Text(title),
        content: const Text('Coming soon. This feature is not available yet.'),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  final accounts = const DemoAccountRepository().getAccounts();

  List<Account> get recentAccounts => accounts.take(5).toList(growable: false);

  int get totalOpeningBalancePaise =>
      accounts.fold(0, (total, account) => total + account.openingBalancePaise);

  void showAllAccounts() {
    Get.toNamed<void>(AppRoutes.accounts);
  }

  void openAccount() {
    Get.toNamed<void>(AppRoutes.openAccount);
  }
}
