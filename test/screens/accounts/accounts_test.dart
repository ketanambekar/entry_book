import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:entry_ui/entry_ui.dart';
import 'package:get/get.dart';

import 'package:entry_book/data/accounts/demo_account_repository.dart';
import 'package:entry_book/routes/app_pages.dart';
import 'package:entry_book/routes/app_routes.dart';
import 'package:entry_book/screens/accounts/accounts_controller.dart';
import 'package:entry_book/screens/dashboard/dashboard_controller.dart';
import 'package:entry_book/widgets/accounts/account_list_item.dart';
import 'package:entry_book/screens/dashboard/widgets/recent_accounts_card.dart';

void main() {
  tearDown(Get.reset);

  test('recent accounts are exactly the five newest full-list accounts', () {
    final dashboard = DashboardController();
    final all = const DemoAccountRepository().getAccounts();
    expect(all.length, greaterThan(5));
    expect(dashboard.recentAccounts.length, 5);
    expect(
      dashboard.totalOpeningBalancePaise,
      all.fold<int>(0, (total, account) => total + account.openingBalancePaise),
    );
    expect(dashboard.totalOpeningBalancePaise, 1425050);
    expect(
      dashboard.recentAccounts.map((account) => account.number),
      all.take(5).map((account) => account.number),
    );
    for (var index = 1; index < all.length; index++) {
      expect(all[index - 1].createdAt.isBefore(all[index].createdAt), isFalse);
    }
    expect(all.map((account) => account.number).toSet().length, all.length);
  });

  for (final dark in [false, true]) {
    testWidgets('recent card and full listing (dark: $dark)', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        GetMaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          initialRoute: AppRoutes.dashboard,
          getPages: AppPages.pages,
        ),
      );
      await tester.pumpAndSettle();

      Get.to<void>(
        () => const Scaffold(
          body: SingleChildScrollView(child: RecentAccountsCard()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AccountListItem), findsNWidgets(5));
      expect(find.text('Recent accounts'), findsOneWidget);
      expect(find.text('Asha Patil'), findsOneWidget);
      expect(find.text('Sunita Rao'), findsOneWidget);
      expect(find.text('Arjun Nair'), findsNothing);
      expect(find.text('Opening balance'), findsNWidgets(5));
      expect(find.text('Created'), findsNWidgets(5));
      expect(find.text('₹0.00'), findsOneWidget);
      final firstAccount = const DemoAccountRepository().getAccounts().first;
      final context = tester.element(find.byType(AccountListItem).first);
      expect(
        find.text(
          MaterialLocalizations.of(
            context,
          ).formatMediumDate(firstAccount.createdAt),
        ),
        findsOneWidget,
      );

      await tester.ensureVisible(find.text('Show more'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show more'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, AppRoutes.accounts);
      expect(find.text('All accounts'), findsOneWidget);
      expect(
        find.text('8 accounts · Sample data · Newest first'),
        findsOneWidget,
      );
      expect(Get.find<AccountsController>().accounts.length, 8);

      await tester.scrollUntilVisible(
        find.text('Vijay Desai'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Vijay Desai'), findsOneWidget);
      expect(find.text('Account 000101'), findsOneWidget);
      expect(tester.takeException(), isNull);
      Get.back<void>();
      await tester.pumpAndSettle();
      expect(Get.isRegistered<AccountsController>(), isFalse);
      expect(find.byType(AccountListItem), findsNWidgets(5));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }

  testWidgets('account rows wrap without clipping at large text sizes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        initialRoute: AppRoutes.accounts,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    for (final text
        in find
            .descendant(
              of: find.byType(AccountListItem),
              matching: find.byType(RichText),
            )
            .evaluate()) {
      expect(
        (text.renderObject! as RenderParagraph).didExceedMaxLines,
        isFalse,
      );
    }
    expect(Get.currentRoute, AppRoutes.accounts);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
