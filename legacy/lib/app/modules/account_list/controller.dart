import 'package:get/get.dart';

import '../../data/models/account_model.dart';
import '../../data/repositories/account_repository.dart';

enum AccountSortField { number, name, amount, status, date }

class AccountListController extends GetxController {
  final AccountRepository _repository = Get.find<AccountRepository>();

  final accounts = <AccountModel>[].obs;
  final sortField = AccountSortField.date.obs;
  final ascending = false.obs;

  @override
  void onInit() {
    super.onInit();
    _reload();
    ever<List<AccountModel>>(_repository.accounts, (_) => _reload());
  }

  void sortBy(AccountSortField field) {
    if (sortField.value == field) {
      ascending.value = !ascending.value;
    } else {
      sortField.value = field;
      ascending.value = true;
    }
    _reload();
  }

  void _reload() {
    final data = List<AccountModel>.from(_repository.allAccounts);
    data.sort((a, b) {
      int result;
      switch (sortField.value) {
        case AccountSortField.number:
          result = a.accountNumber.compareTo(b.accountNumber);
          break;
        case AccountSortField.name:
          result = a.accountName.compareTo(b.accountName);
          break;
        case AccountSortField.amount:
          result = a.totalAmount.compareTo(b.totalAmount);
          break;
        case AccountSortField.status:
          result = a.status.name.compareTo(b.status.name);
          break;
        case AccountSortField.date:
          result = a.creationDate.compareTo(b.creationDate);
          break;
      }
      return ascending.value ? result : -result;
    });
    accounts.assignAll(data);
  }
}
