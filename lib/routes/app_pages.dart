import 'package:get/get.dart';

import 'package:entry_ui/entry_ui.dart';
import 'package:entry_book/routes/app_routes.dart';

abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.playground, page: () => const PlaygroundView()),
  ];
}
