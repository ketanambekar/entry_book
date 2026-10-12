import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/data/providers/local_storage_provider.dart';
import 'app/data/repositories/account_repository.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/app_settings_service.dart';
import 'app/services/csv_service.dart';
import 'app/services/excel_service.dart';
import 'app/services/storage_service.dart';
import 'app/theme/app_theme.dart';
import 'app/utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  final storageService = Get.put(StorageService(), permanent: true);
  final excelService = Get.put(ExcelService(), permanent: true);
  final csvService = Get.put(CsvService(), permanent: true);
  final appSettingsService = await Get.putAsync<AppSettingsService>(
    () => AppSettingsService().init(),
    permanent: true,
  );
  appSettingsService.themeMode.refresh();

  final storageProvider = Get.put(
    LocalStorageProvider(storageService),
    permanent: true,
  );

  final accountRepository = Get.put(
    AccountRepository(
      storageProvider: storageProvider,
      excelService: excelService,
      csvService: csvService,
    ),
    permanent: true,
  );
  await accountRepository.load();

  runApp(const EntryBookApp());
}

class EntryBookApp extends StatelessWidget {
  const EntryBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AppSettingsService>()) {
      return GetMaterialApp(
        title: AppConstants.appDisplayName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.dashboard,
        getPages: AppPages.pages,
        defaultTransition: Transition.cupertino,
      );
    }

    final settings = Get.find<AppSettingsService>();
    return Obx(
      () => GetMaterialApp(
        title: AppConstants.appDisplayName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: settings.themeMode.value,
        initialRoute: AppRoutes.dashboard,
        getPages: AppPages.pages,
        defaultTransition: Transition.cupertino,
      ),
    );
  }
}
