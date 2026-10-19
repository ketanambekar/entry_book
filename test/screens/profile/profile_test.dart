import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:entry_ui/entry_ui.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:entry_book/routes/app_pages.dart';
import 'package:entry_book/routes/app_routes.dart';
import 'package:entry_book/screens/profile/profile_binding.dart';
import 'package:entry_book/screens/profile/profile_controller.dart';

class TestImagePicker extends ImagePicker {
  XFile? result;
  PlatformException? error;
  ImageSource? source;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    this.source = source;
    if (error case final failure?) throw failure;
    return result;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory storage;

  setUpAll(() async {
    storage = Directory.systemTemp.createTempSync(
      'daily-collection-profile-test-',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => storage.path,
        );
    await GetStorage.init();
  });

  setUp(() {
    Get.put(ThemeController(), permanent: true);
    Get.put(
      PackageInfo(
        appName: 'Daily Collection',
        packageName: 'com.krdlabs.daily_collection',
        version: '3.2.1',
        buildNumber: '7',
      ),
      permanent: true,
    );
  });

  tearDown(() async {
    debugDefaultTargetPlatformOverride = null;
    Get.reset();
    await GetStorage().erase();
  });

  tearDownAll(() async => storage.delete(recursive: true));

  testWidgets(
    'profile validates, keeps demo changes, changes theme, and logs out',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          getPages: AppPages.pages,
          initialRoute: AppRoutes.dashboard,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Profile'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, AppRoutes.profile);
      expect(find.text('v3.2.1 (7)'), findsOneWidget);
      expect(find.text('Choose photo'), findsNothing);
      expect(find.text('Camera'), findsNothing);
      expect(find.byType(AppButton), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Edit profile photo'));
      await tester.pumpAndSettle();
      expect(find.text('Choose photo'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      Navigator.pop(tester.element(find.text('Choose photo')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your name.'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Asha');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(Get.find<ProfileController>().savedName.value, 'Asha');
      expect(
        find.text('Profile updated for this demo session.'),
        findsOneWidget,
      );

      for (final (label, mode) in [
        ('Dark', ThemeMode.dark),
        ('Light', ThemeMode.light),
        ('System', ThemeMode.system),
      ]) {
        await tester.tap(find.text('Appearance'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(label));
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(ThemeController.to.themeMode, mode);
      }

      Get.back<void>();
      await tester.pumpAndSettle();
      expect(find.text('Asha'), findsOneWidget);
      await tester.tap(find.byTooltip('Profile'));
      await tester.pumpAndSettle();
      expect(Get.find<ProfileController>().nameController.text, 'Asha');
      await tester.ensureVisible(find.text('Logout'));
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, AppRoutes.login);
      expect(Get.find<ProfileController>().savedName.value, isEmpty);
      expect(Get.find<ProfileController>().photo.value, isNull);
      expect(find.text('Welcome back'), findsOneWidget);
      expect(
        Navigator.of(tester.element(find.text('Welcome back'))).canPop(),
        isFalse,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

  testWidgets('photo selection, cancellation, permission errors, and removal', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final picker = TestImagePicker();
    final controller = Get.put(
      ProfileController(imagePicker: picker),
      permanent: true,
    );
    expect(controller.supportsCamera, isTrue);
    await controller.pickPhoto(ImageSource.gallery);
    expect(controller.photo.value, isNull);
    expect(controller.isPickingPhoto.value, isFalse);

    picker.result = XFile.fromData(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=',
      ),
      mimeType: 'image/png',
      name: 'avatar.png',
    );
    await tester.runAsync(() => controller.pickPhoto(ImageSource.camera));
    expect(picker.source, ImageSource.camera);
    expect(controller.photo.value, isNotNull);
    final photo = controller.photo.value;
    picker.result = null;
    await controller.pickPhoto(ImageSource.gallery);
    expect(controller.photo.value, same(photo));
    picker.error = PlatformException(code: 'photo_access_denied');
    await controller.pickPhoto(ImageSource.gallery);
    expect(controller.message.value, contains('Check permissions'));
    expect(controller.photo.value, same(photo));
    controller.removePhoto();
    expect(controller.photo.value, isNull);

    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    expect(controller.supportsCamera, isFalse);
    await controller.pickPhoto(ImageSource.camera);
    expect(controller.message.value, contains('not available'));
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('profile fits a narrow screen with keyboard and enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = FakeViewPadding(bottom: 240);
    addTearDown(tester.view.reset);
    ProfileBinding().dependencies();
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.dark,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        getPages: AppPages.pages,
        initialRoute: AppRoutes.profile,
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Logout'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
