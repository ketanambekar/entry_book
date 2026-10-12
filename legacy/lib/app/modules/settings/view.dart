import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = controller.settingsService;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: Obx(
          () => ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Card(
                child: ListTile(
                  leading: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(controller.appName.value),
                  subtitle: Text(controller.appVersion.value),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Theme Mode'),
                  subtitle: Text(_themeLabel(settings.themeMode.value)),
                  onTap: () => _showThemePicker(context),
                ),
              ),
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.view_stream_outlined),
                  title: const Text('Compact Entries View'),
                  value: settings.compactEntries.value,
                  onChanged: controller.setCompactEntries,
                ),
              ),
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.warning_amber_outlined),
                  title: const Text('Confirm Before Closing Account'),
                  value: settings.confirmBeforeClose.value,
                  onChanged: controller.setConfirmBeforeClose,
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: const Text('Import CSV Backup'),
                  subtitle: const Text('Restore accounts and entries from CSV file'),
                  trailing: controller.isImportingCsv.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: controller.isImportingCsv.value ? null : controller.importCsv,
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.download_for_offline_outlined),
                  title: const Text('Take Backup'),
                  subtitle: const Text('Download all app data as CSV backup'),
                  trailing: controller.isTakingBackup.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: controller.isTakingBackup.value ? null : controller.takeBackup,
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('App Version'),
                  trailing: Text(controller.appVersion.value),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.update_outlined),
                  title: const Text('Last Updated Time'),
                  subtitle: Text(
                    controller.lastUpdatedAt == null
                        ? 'No data yet'
                        : DateFormat('dd MMM yyyy, hh:mm a').format(controller.lastUpdatedAt!),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  Future<void> _showThemePicker(BuildContext context) async {
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('System Default'),
                onTap: () => Navigator.of(context).pop(ThemeMode.system),
              ),
              ListTile(
                title: const Text('Light'),
                onTap: () => Navigator.of(context).pop(ThemeMode.light),
              ),
              ListTile(
                title: const Text('Dark'),
                onTap: () => Navigator.of(context).pop(ThemeMode.dark),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      await controller.setThemeMode(selected);
    }
  }
}

