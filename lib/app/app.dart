import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:entry_ui/entry_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:entry_book/app/bindings/app_binding.dart';
import 'package:entry_book/routes/app_pages.dart';

class App extends StatelessWidget {
  const App({super.key});

  /// Initialises storage and app-wide dependencies. Call before [runApp].
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await GetStorage.init();
    Get.put<PackageInfo>(await PackageInfo.fromPlatform(), permanent: true);
    // Registered before the first frame so the saved ThemeMode is applied
    // immediately (initialBinding runs too late for that).
    AppBinding().dependencies();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Daily Collection',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeController.to.themeMode,
      initialRoute: AppPages.initialRoute,
      getPages: AppPages.pages,
    );
  }
}
