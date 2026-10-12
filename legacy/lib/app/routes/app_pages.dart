import 'package:get/get.dart';

import '../modules/account_details/bindings.dart';
import '../modules/account_details/view.dart';
import '../modules/account_list/bindings.dart';
import '../modules/account_list/view.dart';
import '../modules/closed_accounts/bindings.dart';
import '../modules/closed_accounts/view.dart';
import '../modules/confirmation/bindings.dart';
import '../modules/confirmation/view.dart';
import '../modules/dashboard/bindings.dart';
import '../modules/dashboard/view.dart';
import '../modules/daily_entry/bindings.dart';
import '../modules/daily_entry/view.dart';
import '../modules/entries/bindings.dart';
import '../modules/entries/view.dart';
import '../modules/open_account/bindings.dart';
import '../modules/open_account/view.dart';
import '../modules/reports/bindings.dart';
import '../modules/reports/view.dart';
import '../modules/settings/bindings.dart';
import '../modules/settings/view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.dashboard,
      page: DashboardView.new,
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.entries,
      page: EntriesView.new,
      binding: EntriesBinding(),
    ),
    GetPage(
      name: AppRoutes.openAccount,
      page: OpenAccountView.new,
      binding: OpenAccountBinding(),
    ),
    GetPage(
      name: AppRoutes.dailyEntry,
      page: DailyEntryView.new,
      binding: DailyEntryBinding(),
    ),
    GetPage(
      name: AppRoutes.reports,
      page: ReportsView.new,
      binding: ReportsBinding(),
    ),
    GetPage(
      name: AppRoutes.accountList,
      page: AccountListView.new,
      binding: AccountListBinding(),
    ),
    GetPage(
      name: AppRoutes.accountDetails,
      page: AccountDetailsView.new,
      binding: AccountDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.closedAccounts,
      page: ClosedAccountsView.new,
      binding: ClosedAccountsBinding(),
    ),
    GetPage(
      name: AppRoutes.closeAccount,
      page: ClosedAccountsView.new,
      binding: ClosedAccountsBinding(showCloseFlow: true),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: SettingsView.new,
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.confirmation,
      page: ConfirmationView.new,
      binding: ConfirmationBinding(),
    ),
  ];
}
