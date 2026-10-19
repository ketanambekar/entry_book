import 'package:get/get.dart';

import 'package:entry_book/data/accounts/demo_account_repository.dart';

class AccountsController extends GetxController {
  final accounts = const DemoAccountRepository().getAccounts();
}
