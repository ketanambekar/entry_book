import 'package:flutter/material.dart';
import 'package:entry_ui/entry_ui.dart';
import 'package:get/get.dart';

import 'package:entry_book/routes/app_routes.dart';
import 'package:entry_book/screens/profile/profile_controller.dart';

class DashboardIntro extends StatelessWidget {
  const DashboardIntro({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: AppTextStyles.bodyM.medium.copyWith(
                    color: colors.onPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Text(
                    Get.find<ProfileController>().savedName.value.isEmpty
                        ? 'Daily Collection'
                        : Get.find<ProfileController>().savedName.value,
                    style: AppTextStyles.subtitleM.bold.copyWith(
                      color: colors.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Demo',
                  style: AppTextStyles.bodyS.medium.copyWith(
                    color: colors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            tooltip: 'Profile',
            onPressed: () => Get.toNamed<void>(AppRoutes.profile),
            icon: Obx(() {
              final photo = Get.find<ProfileController>().photo.value;
              return CircleAvatar(
                backgroundColor: colors.surface,
                backgroundImage: photo == null ? null : MemoryImage(photo),
                child: photo == null
                    ? Icon(Icons.person_outline_rounded, color: colors.primary)
                    : null,
              );
            }),
          ),
        ],
      ),
    );
  }
}
