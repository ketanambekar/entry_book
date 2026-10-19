import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:entry_ui/entry_ui.dart';
import 'package:get/get.dart';

import 'package:entry_book/routes/app_pages.dart';
import 'package:entry_book/routes/app_routes.dart';
import 'package:entry_book/screens/collections/collections_controller.dart';
import 'package:entry_book/screens/collections/widgets/collection_account_card.dart';

void main() {
  tearDown(Get.reset);

  test(
    'pending by default; search includes all accounts by name or number',
    () {
      final controller = CollectionsController();
      addTearDown(controller.onClose);
      expect(controller.filteredAccounts.length, 5);
      expect(
        controller.filteredAccounts.every((a) => a.hasPendingInstalment),
        isTrue,
      );
      expect(
        controller.filteredAccounts.any((a) => a.openingBalancePaise == 0),
        isTrue,
      );

      controller.updateSearch('  rAvI  ');
      expect(controller.filteredAccounts.single.name, 'Ravi Kumar');
      expect(controller.filteredAccounts.single.hasPendingInstalment, isFalse);
      controller.updateSearch('000107');
      expect(controller.filteredAccounts.single.name, 'Ravi Kumar');
      controller.updateSearch('00010');
      expect(controller.filteredAccounts.length, 8);
      controller.updateSearch('sh');
      expect(controller.filteredAccounts.map((account) => account.name), [
        'Asha Patil',
        'Meera Shah',
        'Imran Shaikh',
      ]);
      controller.updateSearch('unknown');
      expect(controller.filteredAccounts, isEmpty);
      controller.updateSearch('   ');
      expect(controller.filteredAccounts.length, 5);
      expect(controller.isSearching, isFalse);
      controller.clearSearch();
      expect(controller.filteredAccounts.length, 5);
    },
  );

  for (final dark in [false, true]) {
    testWidgets('search, empty result, and clear (dark: $dark)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        GetMaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          initialRoute: AppRoutes.collections,
          getPages: AppPages.pages,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Pending instalments (5)'), findsOneWidget);
      expect(find.text('Sample data'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'ravi');
      await tester.pumpAndSettle();
      expect(find.text('Search results (1)'), findsOneWidget);
      expect(find.text('Ravi Kumar'), findsOneWidget);
      expect(find.text('Account 000107'), findsOneWidget);
      expect(find.text('No pending instalment'), findsOneWidget);
      expect(find.byType(CollectionAccountCard), findsOneWidget);

      await tester.enterText(find.byType(TextField), '000108');
      await tester.pumpAndSettle();
      expect(find.text('Asha Patil'), findsOneWidget);
      expect(find.text('Instalment pending'), findsOneWidget);

      tester.view.viewInsets = FakeViewPadding(bottom: 240);
      await tester.enterText(find.byType(TextField), 'no match');
      await tester.pumpAndSettle();
      expect(
        find.text('No accounts found. Try another name or number.'),
        findsOneWidget,
      );
      expect(find.byType(CollectionAccountCard), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      expect(find.text('Pending instalments (5)'), findsOneWidget);
      expect(Get.find<CollectionsController>().searchController.text, isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }
}
