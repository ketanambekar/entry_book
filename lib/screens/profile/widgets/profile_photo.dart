import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:entry_book/screens/profile/profile_controller.dart';
import 'package:entry_book/screens/profile/widgets/profile_photo_options.dart';

class ProfilePhoto extends GetView<ProfileController> {
  const ProfilePhoto({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Obx(() {
        final bytes = controller.photo.value;
        final busy = controller.isPickingPhoto.value;
        return Semantics(
          button: true,
          label: busy ? 'Updating profile photo' : 'Edit profile photo',
          child: InkResponse(
            onTap: busy
                ? null
                : () => showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    isScrollControlled: true,
                    builder: (_) => const ProfilePhotoOptions(),
                  ),
            radius: 48,
            child: SizedBox.square(
              dimension: 88,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: colors.primaryContainer,
                    backgroundImage: bytes == null ? null : MemoryImage(bytes),
                    child: busy
                        ? const CircularProgressIndicator()
                        : bytes == null
                        ? Icon(
                            Icons.person_outline_rounded,
                            size: 40,
                            color: colors.primary,
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.surface, width: 2),
                      ),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        size: 16,
                        color: colors.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
