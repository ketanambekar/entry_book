import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:entry_ui/entry_ui.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:entry_book/routes/app_pages.dart';
import 'package:entry_book/routes/app_routes.dart';
import 'package:entry_book/screens/login/login_binding.dart';
import 'package:entry_book/screens/login/login_controller.dart';
import 'package:entry_book/screens/login/login_view.dart';
import 'package:entry_book/screens/login/widgets/login_header.dart';
import 'package:entry_book/screens/login/widgets/login_phone_form.dart';
import 'package:entry_book/screens/login/widgets/login_version_footer.dart';

void main() {
  setUp(() {
    Get.put<PackageInfo>(
      PackageInfo(
        appName: 'Daily Collection',
        packageName: 'com.krdlabs.daily_collection',
        version: '2.3.4',
        buildNumber: '56',
      ),
      permanent: true,
    );
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    Get.reset();
  });

  test('only native macOS starts at the playground', () {
    for (final platform in TargetPlatform.values) {
      debugDefaultTargetPlatformOverride = platform;
      final isMacOS = platform == TargetPlatform.macOS && !kIsWeb;
      expect(
        AppPages.initialRoute,
        isMacOS ? AppRoutes.playground : AppRoutes.login,
      );
      expect(
        AppPages.pages.any((page) => page.name == AppRoutes.playground),
        isMacOS,
      );
      expect(
        AppPages.pages.any((page) => page.name == AppRoutes.login),
        isTrue,
      );
    }
  });

  test('validates 10-digit phone numbers and six-digit codes', () {
    final controller = LoginController();
    addTearDown(controller.onClose);

    for (final value in [
      null,
      '',
      '987654321',
      '98765432101',
      '+012345678',
      '+1234567',
      '+1234567890123456',
      '+123abc45678',
    ]) {
      expect(controller.validatePhone(value), isNotNull);
    }
    for (final value in ['7022480958', '9876543210']) {
      expect(controller.validatePhone(value), isNull);
    }
    controller.phoneController.text = '7022480958';
    expect(controller.fullPhoneNumber, '+917022480958');
    for (final value in [null, '', '12345', '1234567', 'abcdef']) {
      expect(controller.validateOtp(value), isNotNull);
    }
    expect(controller.validateOtp('123456'), isNull);
  });

  testWidgets('login validates input before entering the labelled demo', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light,
        initialRoute: AppRoutes.login,
        getPages: AppPages.pages,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Daily Collection'), findsOneWidget);
    expect(find.text('v2.3.4 (56)'), findsOneWidget);
    final footer = find.ancestor(
      of: find.text('v2.3.4 (56)'),
      matching: find.byType(SafeArea),
    );
    expect(footer, findsOneWidget);
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).bottomNavigationBar,
      isNotNull,
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your phone number.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '9876543210');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(AppOtp), findsOneWidget);
    expect(find.text('v2.3.4 (56)'), findsOneWidget);
    expect(find.text('OTP preview for +919876543210'), findsOneWidget);

    expect(find.textContaining('No SMS is sent'), findsOneWidget);
    await tester.tap(find.text('Continue to demo'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a 6-digit code.'), findsOneWidget);

    await tester.tap(find.text('Change phone number'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    expect(Get.find<LoginController>().phoneController.text, '9876543210');
    expect(Get.find<LoginController>().otpController.text, isEmpty);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.text('Continue to demo'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.dashboard);
    expect(find.text('Open account'), findsOneWidget);
    expect(find.text('Demo'), findsOneWidget);
    expect(Get.isRegistered<LoginController>(), isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('login fits a small dark screen with the keyboard open', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = FakeViewPadding(bottom: 260);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.dark,
        initialRoute: AppRoutes.login,
        getPages: [
          GetPage(
            name: AppRoutes.login,
            page: () => const LoginView(),
            binding: LoginBinding(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.enterText(find.byType(TextField), '9876543210');
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(AppOtp), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('phone input matches the fixed +91 layout and limits digits', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    LoginBinding().dependencies();

    await tester.pumpWidget(
      GetMaterialApp(theme: AppTheme.light, home: const LoginView()),
    );
    await tester.pumpAndSettle();

    final field = find.byKey(const ValueKey('login-phone-box'));
    final prefix = find
        .ancestor(of: find.text('+91'), matching: find.byType(Container))
        .first;
    final label = find.text('Phone number*');
    expect(tester.getSize(prefix), const Size(54, 48));
    expect(tester.getSize(field), const Size(279, 48));
    expect(tester.getTopLeft(field).dx - tester.getTopRight(prefix).dx, 10);
    expect(
      tester.getTopLeft(prefix).dy - tester.getBottomLeft(label).dy,
      closeTo(6, 0.01),
    );
    final labelStyle = tester.widget<Text>(label).style!;
    expect(labelStyle.fontSize, 12);
    expect(labelStyle.fontWeight, FontWeight.w500);
    expect(labelStyle.color, const Color(0xFF7A7A7A));

    await tester.tap(field);
    await tester.pumpAndSettle();
    final input = tester.widget<TextField>(find.byType(TextField));
    final decoration =
        tester.widget<Container>(field).decoration! as BoxDecoration;
    final border = decoration.border! as Border;
    expect(border.top, const BorderSide(color: Color(0xFFED6010), width: 1.5));
    expect(decoration.borderRadius, BorderRadius.circular(8));
    expect(input.style!.fontSize, 16);
    expect(input.style!.height, 1.3);
    expect(decoration.color, Colors.white);

    double baselineOf(Finder finder) {
      final box = tester.renderObject<RenderBox>(finder);
      return box.localToGlobal(Offset.zero).dy +
          box.getDryBaseline(box.constraints, TextBaseline.alphabetic)!;
    }

    await tester.enterText(find.byType(TextField), '70a2248095899');
    await tester.pumpAndSettle();
    expect(
      baselineOf(find.byType(EditableText)),
      closeTo(baselineOf(find.text('+91')), 0.5),
    );
    expect(Get.find<LoginController>().phoneController.text, '7022480958');
    expect(find.text('+91'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '702');
    await tester.pumpAndSettle();
    expect(find.text('Enter a 10-digit phone number.'), findsOneWidget);
    expect(tester.getSize(field), const Size(279, 48));
    expect(tester.getTopLeft(field).dy, tester.getTopLeft(prefix).dy);
    expect(
      baselineOf(find.byType(EditableText)),
      closeTo(baselineOf(find.text('+91')), 0.5),
    );
    Get.find<LoginController>().phoneFocusNode.unfocus();
    await tester.pumpAndSettle();
    expect(
      baselineOf(find.byType(EditableText)),
      closeTo(baselineOf(find.text('+91')), 0.5),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('login groups branding and form while keeping footer at bottom', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    LoginBinding().dependencies();

    await tester.pumpWidget(
      GetMaterialApp(theme: AppTheme.light, home: const LoginView()),
    );
    await tester.pumpAndSettle();

    final header = find.byType(LoginHeader);
    final form = find.byType(LoginPhoneForm);
    expect(tester.getTopLeft(header), const Offset(60, 40));
    expect(tester.getSize(form).width, 480);
    final label = find.text('Phone number*');
    final button = find.byWidgetPredicate(
      (widget) => widget is AppButton && widget.label == 'Continue',
    );
    expect(tester.getTopLeft(label).dx, tester.getTopLeft(header).dx);
    expect(tester.getTopLeft(button).dx, tester.getTopLeft(header).dx);
    expect(tester.getSize(button).width, tester.getSize(form).width);
    final footer = find.byType(LoginVersionFooter);
    expect(tester.getTopLeft(form).dy - tester.getBottomLeft(header).dy, 40);
    expect(tester.getBottomLeft(footer).dy, 1000);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
