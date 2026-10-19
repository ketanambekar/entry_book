import 'package:flutter/material.dart';
import 'package:entry_ui/entry_ui.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:entry_book/screens/profile/profile_controller.dart';
import 'package:entry_book/screens/profile/widgets/profile_theme_options.dart';

class ProfileSettings extends GetView<ProfileController> {
  const ProfileSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = Get.find<PackageInfo>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              Obx(
                () => ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Appearance'),
                  subtitle: Text(switch (ThemeController.to.themeMode) {
                    ThemeMode.system => 'System',
                    ThemeMode.light => 'Light',
                    ThemeMode.dark => 'Dark',
                  }),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    isScrollControlled: true,
                    builder: (_) => const ProfileThemeOptions(),
                  ),
                ),
              ),
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('Logout'),
                iconColor: theme.colorScheme.error,
                textColor: theme.colorScheme.error,
                onTap: controller.logout,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'v${info.version} (${info.buildNumber})',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
