import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:entry_ui/entry_ui.dart';
import 'package:entry_book/routes/app_routes.dart';
import 'package:entry_book/screens/accounts/accounts_binding.dart';
import 'package:entry_book/screens/accounts/accounts_view.dart';
import 'package:entry_book/screens/collections/collections_binding.dart';
import 'package:entry_book/screens/collections/collections_view.dart';
import 'package:entry_book/screens/dashboard/dashboard_binding.dart';
import 'package:entry_book/screens/dashboard/dashboard_view.dart';
import 'package:entry_book/screens/login/login_binding.dart';
import 'package:entry_book/screens/login/login_view.dart';
import 'package:entry_book/screens/open_account/open_account_binding.dart';
import 'package:entry_book/screens/open_account/open_account_view.dart';
import 'package:entry_book/screens/profile/profile_binding.dart';
import 'package:entry_book/screens/profile/profile_view.dart';
import 'package:entry_book/screens/withdrawal/withdrawal_binding.dart';
import 'package:entry_book/screens/withdrawal/withdrawal_view.dart';

abstract final class AppPages {
  static bool get _isMacOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

  static String get initialRoute =>
      _isMacOS ? AppRoutes.playground : AppRoutes.login;

  static List<GetPage<dynamic>> get pages => [
    GetPage(
      name: AppRoutes.withdrawal,
      page: () => const WithdrawalView(),
      binding: WithdrawalBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    if (_isMacOS)
      GetPage(name: AppRoutes.playground, page: () => const PlaygroundView()),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.collections,
      page: () => const CollectionsView(),
      binding: CollectionsBinding(),
    ),
    GetPage(
      name: AppRoutes.accounts,
      page: () => const AccountsView(),
      binding: AccountsBinding(),
    ),
    GetPage(
      name: AppRoutes.openAccount,
      page: () => const OpenAccountView(),
      binding: OpenAccountBinding(),
    ),
  ];
}
