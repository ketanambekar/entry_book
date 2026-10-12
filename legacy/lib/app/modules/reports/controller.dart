import 'package:get/get.dart';

import '../../data/repositories/account_repository.dart';
import '../../utils/helpers.dart';

class ReportsController extends GetxController {
  final AccountRepository _repository = Get.find<AccountRepository>();
  final summary = <String, num>{}.obs;
  final isImporting = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshSummary();
    ever<List<dynamic>>(_repository.accounts, (_) => refreshSummary());
  }

  void refreshSummary() {
    summary.assignAll(_repository.getSummary());
  }

  Future<void> importCsv() async {
    isImporting.value = true;
    final error = await _repository.importFromCsv();
    isImporting.value = false;

    if (error != null && error != 'Import cancelled') {
      Helpers.showError(error);
      return;
    }

    if (error == 'Import cancelled') {
      return;
    }

    refreshSummary();

    if (error != null) {
      Helpers.showError(error);
      return;
    }

    final issues = _repository.lastImportIssues;
    if (issues.isEmpty) {
      Helpers.showSuccess('CSV import completed');
      return;
    }

    Helpers.showSuccess('CSV import completed with ${issues.length} warning(s)');
    Get.defaultDialog(
      title: 'Import Warnings',
      middleText: issues.take(12).join('\n'),
      textConfirm: 'OK',
      onConfirm: Get.back,
    );
  }
}
