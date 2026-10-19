import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:entry_book/screens/profile/profile_controller.dart';

class ProfilePhotoOptions extends GetView<ProfileController> {
  const ProfilePhotoOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose photo'),
              onTap: () {
                Navigator.pop(context);
                controller.pickPhoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              subtitle: controller.supportsCamera
                  ? null
                  : const Text('Unavailable on this platform'),
              enabled: controller.supportsCamera,
              onTap: () {
                Navigator.pop(context);
                controller.pickPhoto(ImageSource.camera);
              },
            ),
            if (controller.photo.value != null)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: const Text('Remove photo'),
                onTap: () {
                  Navigator.pop(context);
                  controller.removePhoto();
                },
              ),
          ],
        ),
      ),
    );
  }
}
