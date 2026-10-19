import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:entry_ui/entry_ui.dart';
import 'package:get/get.dart';

import 'package:entry_book/routes/app_pages.dart';
import 'package:entry_book/routes/app_routes.dart';
import 'package:entry_book/screens/dashboard/dashboard_controller.dart';
import 'package:entry_book/screens/open_account/open_account_controller.dart';

Finder input(String label) => find.descendant(
  of: find.byWidgetPredicate(
    (widget) => widget is AppInput && widget.label == label,
  ),
  matching: find.byType(TextField),
);

Future<void> tapVisible(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  tearDown(Get.reset);

  test('account validation and exact opening amount formatting', () {
    final controller = OpenAccountController();
    addTearDown(controller.onClose);

    expect(controller.validateName(' '), isNotNull);
    expect(controller.validateName('Ravi Kumar'), isNull);
    expect(controller.validateName('李'), isNull);
    for (final value in ['', '12A', '-12', '1.2']) {
      expect(controller.validateAccountNumber(value), isNotNull);
    }
    for (final value in ['0', '000123', '123456789012345678901234567890']) {
      expect(controller.validateAccountNumber(value), isNull);
    }
    for (final value in ['', '0', '0.00', '12.3', '0012.34']) {
      expect(controller.validateOpeningAmount(value), isNull);
    }
    for (final value in [
      '-1',
      '1.234',
      'abc',
      'NaN',
      'Infinity',
      '1e3',
      '.5',
    ]) {
      expect(controller.validateOpeningAmount(value), isNotNull);
    }
    expect(controller.openingAmountDisplay, '0.00');
    controller.openingAmountController.text = '00012345678901234567890.1';
    expect(controller.openingAmountDisplay, '12345678901234567890.10');
    expect(controller.validatePhone(''), isNull);
    expect(controller.validatePhone('9876543210'), isNull);
    expect(controller.validatePhone('123'), isNotNull);
    expect(controller.validatePhone('+919876543210'), isNotNull);
  });

  testWidgets('dashboard opens account form and reviews required details', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light,
        initialRoute: AppRoutes.dashboard,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppMiniCard), findsNWidgets(4));
    expect(find.byType(AppAlertCard), findsNothing);
    expect(find.byType(AppOverviewCard), findsNothing);
    expect(find.text('Recent accounts'), findsNothing);
    expect(find.text('Transaction'), findsOneWidget);
    expect(find.text('Collections'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('Demo'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Customer & account opening'), findsOneWidget);
    expect(find.byIcon(Icons.person_add_alt_1_outlined), findsOneWidget);
    expect(Get.isRegistered<DashboardController>(), isTrue);
    await tapVisible(tester, 'Withdrawal calculator');
    expect(Get.currentRoute, AppRoutes.withdrawal);
    expect(find.text('Daily / monthly collections'), findsOneWidget);
    Get.back<void>();
    await tester.pumpAndSettle();
    await tapVisible(tester, 'Collections');
    expect(Get.currentRoute, AppRoutes.collections);
    expect(find.text('Pending instalments (5)'), findsOneWidget);
    Get.back<void>();
    await tester.pumpAndSettle();
    for (final label in ['Reports']) {
      await tapVisible(tester, label);
      expect(
        find.text('Coming soon. This feature is not available yet.'),
        findsOneWidget,
      );
      await tapVisible(tester, 'Close');
    }
    await tapVisible(tester, 'Open account');
    expect(Get.currentRoute, AppRoutes.openAccount);
    expect(Get.isRegistered<OpenAccountController>(), isTrue);
    expect(find.text('Account details'), findsOneWidget);
    expect(find.text('Optional details'), findsOneWidget);
    expect(find.text('Demo only · Nothing is saved'), findsOneWidget);
    final reviewButton = find.byWidgetPredicate(
      (widget) => widget is AppButton && widget.label == 'Review details',
    );
    expect(tester.getSize(reviewButton).height, greaterThanOrEqualTo(48));
    expect(
      tester.getBottomLeft(reviewButton).dy,
      lessThanOrEqualTo(
        tester.view.physicalSize.height / tester.view.devicePixelRatio,
      ),
    );

    await tapVisible(tester, 'Review details');
    expect(find.text('Enter the account holder name.'), findsOneWidget);
    expect(find.text('Enter the account number.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.enterText(input('Account holder name'), 'Ravi Kumar');
    await tester.enterText(input('Account number'), '000123');
    await tapVisible(tester, 'Review details');
    expect(find.text('Ravi Kumar'), findsWidgets);
    expect(find.text('000123'), findsWidgets);
    expect(find.text('₹0.00'), findsOneWidget);
    expect(find.text('Not provided'), findsOneWidget);
    expect(
      find.text('Demo only. No account is opened or saved.'),
      findsOneWidget,
    );

    await tapVisible(tester, 'Back to form');
    expect(Get.find<OpenAccountController>().nameController.text, 'Ravi Kumar');
    Get.back<void>();
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.dashboard);
    expect(Get.isRegistered<OpenAccountController>(), isFalse);
    await tapVisible(tester, 'Open account');
    expect(Get.find<OpenAccountController>().nameController.text, isEmpty);
    expect(
      Get.find<OpenAccountController>().openingAmountController.text,
      isEmpty,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets(
    'account form validates optional fields and previews INR amount',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.light,
          initialRoute: AppRoutes.openAccount,
          getPages: AppPages.pages,
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(input('Account holder name'), 'Asha');
      await tester.enterText(input('Account number'), '12a34');
      expect(
        Get.find<OpenAccountController>().accountNumberController.text,
        '1234',
      );
      await tester.enterText(input('Opening amount (optional)'), '-1');
      await tester.enterText(input('Phone number (optional)'), '123');
      await tapVisible(tester, 'Review details');
      expect(
        find.text('Enter 0 or more, with up to 2 decimal places.'),
        findsOneWidget,
      );
      expect(find.textContaining('or leave it blank.'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);

      await tester.enterText(input('Opening amount (optional)'), '100.50');
      await tester.pumpAndSettle();
      expect(find.text('Payout ₹102.51'), findsOneWidget);
      expect(find.text('Payout ₹104.52'), findsOneWidget);
      await tester.enterText(input('Phone number (optional)'), '9876543210');
      await tapVisible(tester, 'Review details');
      expect(find.text('₹100.50'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Payout ₹102.51'),
        ),
        findsOneWidget,
      );
      expect(find.text('+919876543210'), findsOneWidget);
      await tapVisible(tester, 'Back to form');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

  for (final dark in [false, true]) {
    testWidgets('small screen with large text (dark: $dark)', (tester) async {
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
          initialRoute: AppRoutes.dashboard,
          getPages: AppPages.pages,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final actionText = tester.renderObject<RenderParagraph>(
        find.text('Open account'),
      );
      expect(actionText.didExceedMaxLines, isFalse);
      await tapVisible(tester, 'Open account');
      tester.view.viewInsets = FakeViewPadding(bottom: 260);
      await tester.pumpAndSettle();
      await tester.enterText(input('Account holder name'), 'Asha');
      await tester.enterText(input('Account number'), '42');
      await tapVisible(tester, 'Review details');
      expect(find.text('₹0.00'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tapVisible(tester, 'Back to form');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }
}
