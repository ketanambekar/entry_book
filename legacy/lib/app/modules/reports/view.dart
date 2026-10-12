import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/helpers.dart';
import '../../widgets/app_button.dart';
import 'controller.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            _SummaryTile(
              title: 'Total Accounts',
              value: '${controller.summary['totalAccounts'] ?? 0}',
            ),
            _SummaryTile(
              title: 'Active Accounts',
              value: '${controller.summary['activeAccounts'] ?? 0}',
            ),
            _SummaryTile(
              title: 'Closed Accounts',
              value: '${controller.summary['closedAccounts'] ?? 0}',
            ),
            _SummaryTile(
              title: 'Total Balance',
              trailing: Helpers.amountText(
                (controller.summary['totalBalance'] ?? 0).toDouble(),
              ),
            ),
            _SummaryTile(
              title: 'Total Entries',
              value: '${controller.summary['totalEntries'] ?? 0}',
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Import CSV Backup',
              icon: Icons.upload_file,
              onPressed: controller.importCsv,
              isLoading: controller.isImporting.value,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.title,
    this.value,
    this.trailing,
  });

  final String title;
  final String? value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: trailing ??
            Text(
              value ?? '-',
              style: Theme.of(context).textTheme.titleLarge,
            ),
      ),
    );
  }
}
