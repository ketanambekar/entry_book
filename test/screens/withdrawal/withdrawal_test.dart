import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:entry_ui/entry_ui.dart';
import 'package:get/get.dart';

import 'package:entry_book/domain/withdrawal/withdrawal_calculator.dart';
import 'package:entry_book/routes/app_pages.dart';
import 'package:entry_book/routes/app_routes.dart';
import 'package:entry_book/screens/withdrawal/withdrawal_controller.dart';
import 'package:entry_book/widgets/withdrawal/withdrawal_schedule.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('varying collections sum to principal, including zero entries', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light,
        initialRoute: AppRoutes.withdrawal,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();
    final controller = Get.find<WithdrawalController>();
    controller.balanceController.text = '100';
    for (final amount in ['0', '200', '300']) {
      controller.addCollection();
      controller.additionalCollections.last.text = amount;
    }
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(4));
    expect(controller.collectedPrincipalPaise, BigInt.from(60000));
    controller.openedAt.value = DateTime(2026, 1, 1);
    controller.withdrawnAt.value = DateTime(2026, 6, 1);
    controller.calculate();
    expect(controller.result.value!.deductionPaise, BigInt.from(1800));
    expect(controller.result.value!.payoutPaise, BigInt.from(58200));
    controller.withdrawnAt.value = DateTime(2026, 7, 1);
    controller.calculate();
    expect(controller.result.value!.interestPaise, BigInt.from(1200));
    expect(controller.result.value!.payoutPaise, BigInt.from(61200));
    controller.removeCollection(controller.additionalCollections.last);
    await tester.pumpAndSettle();
    expect(controller.result.value, isNull);
    expect(controller.collectedPrincipalPaise, BigInt.from(30000));
    controller.additionalCollections.first.text = '-1';
    controller.calculate();
    await tester.pumpAndSettle();
    expect(controller.result.value, isNull);
    expect(
      find.text('Enter 0 or more, with up to 2 decimal places.'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  test('zero, small, and decimal principal balances use the same rules', () {
    for (final (balance, early, sixMonths, twelveMonths) in [
      ('0', '0.00', '0.00', '0.00'),
      ('100', '97.00', '102.00', '104.00'),
      ('200', '194.00', '204.00', '208.00'),
      ('300', '291.00', '306.00', '312.00'),
      ('100.50', '97.48', '102.51', '104.52'),
    ]) {
      final principal = WithdrawalCalculator.parsePaise(balance);
      for (var month = 0; month < 6; month++) {
        final result = WithdrawalCalculator.estimate(principal, month);
        expect(WithdrawalCalculator.formatPaise(result.payoutPaise), early);
        expect(result.interestPaise, BigInt.zero);
      }
      expect(
        WithdrawalCalculator.formatPaise(
          WithdrawalCalculator.estimate(principal, 6).payoutPaise,
        ),
        sixMonths,
      );
      expect(
        WithdrawalCalculator.formatPaise(
          WithdrawalCalculator.estimate(principal, 12).payoutPaise,
        ),
        twelveMonths,
      );
    }
  });

  testWidgets('schedule shows every month including 1-5 for small balances', (
    tester,
  ) async {
    for (final balance in ['0', '100', '200', '300']) {
      final principal = WithdrawalCalculator.parsePaise(balance);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(
              child: WithdrawalSchedule(principalPaise: principal),
            ),
          ),
        ),
      );
      for (var month = 1; month <= 5; month++) {
        expect(
          find.text(
            '$month ${month == 1 ? 'month' : 'months'} · −3% deduction',
          ),
          findsOneWidget,
        );
      }
      expect(find.textContaining('6 months · 2% interest'), findsOneWidget);
      expect(find.textContaining('12 months · 4% interest'), findsOneWidget);
      expect(
        find.text(
          'Payout ₹${WithdrawalCalculator.formatPaise(WithdrawalCalculator.estimate(principal, 1).payoutPaise)}',
        ),
        balance == '0' ? findsNWidgets(12) : findsNWidgets(5),
      );
      expect(tester.takeException(), isNull);
    }
  });

  test('exact payout for every threshold and 6-12 month rate', () {
    final principal = WithdrawalCalculator.parsePaise('10000');
    for (var months = 0; months < 6; months++) {
      final estimate = WithdrawalCalculator.estimate(principal, months);
      expect(estimate.interestPaise, BigInt.zero);
      expect(estimate.deductionPaise, BigInt.from(30000));
      expect(estimate.payoutPaise, BigInt.from(970000));
    }
    for (final (months, payout) in [
      (6, '10200.00'),
      (7, '10233.33'),
      (8, '10266.67'),
      (9, '10300.00'),
      (10, '10333.33'),
      (11, '10366.67'),
      (12, '10400.00'),
      (18, '10600.00'),
      (24, '10800.00'),
    ]) {
      final result = WithdrawalCalculator.estimate(principal, months);
      expect(result.deductionPaise, BigInt.zero);
      expect(WithdrawalCalculator.formatPaise(result.payoutPaise), payout);
    }
    expect(
      WithdrawalCalculator.estimate(BigInt.zero, 6).payoutPaise,
      BigInt.zero,
    );
    expect(
      WithdrawalCalculator.estimate(BigInt.from(50), 0).deductionPaise,
      BigInt.two,
    );
    expect(
      WithdrawalCalculator.parsePaise('00012345678901234567890.12').toString(),
      '1234567890123456789012',
    );
    expect(() => WithdrawalCalculator.parsePaise('-1'), throwsFormatException);
    expect(
      () => WithdrawalCalculator.estimate(BigInt.one, -1),
      throwsArgumentError,
    );
  });

  test('completed calendar months respect anniversaries and leap years', () {
    expect(
      WithdrawalCalculator.completedMonths(
        DateTime(2026, 1, 19),
        DateTime(2026, 7, 18),
      ),
      5,
    );
    expect(
      WithdrawalCalculator.completedMonths(
        DateTime(2026, 1, 19),
        DateTime(2026, 7, 19),
      ),
      6,
    );
    expect(
      WithdrawalCalculator.completedMonths(
        DateTime(2026, 8, 31),
        DateTime(2027, 2, 28),
      ),
      6,
    );
    expect(
      WithdrawalCalculator.completedMonths(
        DateTime(2023, 8, 31),
        DateTime(2024, 2, 28),
      ),
      5,
    );
    expect(
      WithdrawalCalculator.completedMonths(
        DateTime(2023, 8, 31),
        DateTime(2024, 2, 29),
      ),
      6,
    );
    expect(
      WithdrawalCalculator.completedMonths(
        DateTime(2026, 1, 19, 18),
        DateTime(2026, 1, 19),
      ),
      0,
    );
    expect(
      () => WithdrawalCalculator.completedMonths(
        DateTime(2026, 2),
        DateTime(2026, 1),
      ),
      throwsArgumentError,
    );
  });

  testWidgets('calculator validates dates and invalidates edited results', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light,
        initialRoute: AppRoutes.withdrawal,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();
    final controller = Get.find<WithdrawalController>();
    await tester.ensureVisible(find.text('Calculate'));
    await tester.tap(find.text('Calculate'));
    await tester.pumpAndSettle();
    expect(find.text('Choose both dates.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '10000');
    controller.openedAt.value = DateTime(2026, 1, 19);
    controller.withdrawnAt.value = DateTime(2026, 7, 18);
    await tester.ensureVisible(find.text('Calculate'));
    await tester.tap(find.text('Calculate'));
    await tester.pumpAndSettle();
    expect(controller.result.value!.payoutPaise, BigInt.from(970000));
    controller.withdrawnAt.value = DateTime(2026, 7, 19);
    controller.calculate();
    await tester.pumpAndSettle();
    expect(controller.result.value!.payoutPaise, BigInt.from(1020000));
    expect(find.text('You receive'), findsOneWidget);
    expect(find.text('₹10200.00'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '20000');
    await tester.pumpAndSettle();
    expect(controller.result.value, isNull);
    controller.withdrawnAt.value = DateTime(2025);
    controller.calculate();
    await tester.pumpAndSettle();
    expect(
      find.text('Withdrawal date cannot be before opening date.'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('calculator date picker and results fit a small dark screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.dark,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        initialRoute: AppRoutes.withdrawal,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Account opening date'));
    await tester.tap(find.text('Account opening date'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    Get.back<void>();
    await tester.pumpAndSettle();
    expect(Get.find<WithdrawalController>().openedAt.value, isNull);
    await tester.enterText(find.byType(TextField), '10000');
    final controller = Get.find<WithdrawalController>();
    controller.openedAt.value = DateTime(2026, 1, 1);
    controller.withdrawnAt.value = DateTime(2027, 1, 1);
    controller.calculate();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('You receive'));
    await tester.pumpAndSettle();
    expect(controller.result.value!.payoutPaise, BigInt.from(1040000));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
