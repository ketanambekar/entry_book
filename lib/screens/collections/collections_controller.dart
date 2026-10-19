import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:entry_book/data/accounts/account.dart';
import 'package:entry_book/data/accounts/demo_account_repository.dart';

class CollectionsController extends GetxController {
  final accounts = const DemoAccountRepository().getAccounts();
  final searchController = TextEditingController();
  final query = ''.obs;

  bool get isSearching => query.value.trim().isNotEmpty;

  List<Account> get filteredAccounts {
    final search = query.value.trim().toLowerCase();
    return accounts
        .where((account) {
          if (search.isEmpty) return account.hasPendingInstalment;
          return account.name.toLowerCase().contains(search) ||
              account.number.contains(search);
        })
        .toList(growable: false);
  }

  void updateSearch(String value) => query.value = value;

  void clearSearch() {
    searchController.clear();
    query.value = '';
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
