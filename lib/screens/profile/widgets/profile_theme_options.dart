import 'package:flutter/material.dart';
import 'package:entry_ui/entry_ui.dart';

class ProfileThemeOptions extends StatelessWidget {
  const ProfileThemeOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (mode, label) in [
                (ThemeMode.system, 'System'),
                (ThemeMode.light, 'Light'),
                (ThemeMode.dark, 'Dark'),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppSelectionCard<ThemeMode>(
                    title: label,
                    value: mode,
                    groupValue: ThemeController.to.themeMode,
                    onChanged: (mode) {
                      ThemeController.to.setThemeMode(mode);
                      Navigator.pop(context);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
