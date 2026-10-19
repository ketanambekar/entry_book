import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:entry_book/routes/app_routes.dart';

class ProfileController extends GetxController {
  ProfileController({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final savedName = ''.obs;
  final photo = Rxn<Uint8List>();
  final isPickingPhoto = false.obs;
  final message = RxnString();
  int _photoRequest = 0;

  bool get supportsCamera =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  String? validateName(String? value) =>
      value == null || value.trim().isEmpty ? 'Enter your name.' : null;

  void saveProfile() {
    if (!formKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    savedName.value = nameController.text.trim();
    message.value = 'Profile updated for this demo session.';
  }

  Future<void> pickPhoto(ImageSource source) async {
    if (isPickingPhoto.value) return;
    if (source == ImageSource.camera && !supportsCamera) {
      message.value =
          'Camera is not available on this platform. Choose a photo instead.';
      return;
    }
    isPickingPhoto.value = true;
    final request = ++_photoRequest;
    message.value = null;
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      codec.dispose();
      if (request != _photoRequest) return;
      photo.value = bytes;
      message.value = 'Photo updated for this demo session.';
    } on PlatformException catch (error) {
      message.value =
          'Unable to open photos or camera. Check permissions and try again.';
      debugPrint(
        'Profile photo picker failed (${error.code}): ${error.message}',
      );
    } on Exception catch (error, stack) {
      message.value = 'Unable to read this photo. Please choose another image.';
      debugPrintStack(label: 'Profile photo failed: $error', stackTrace: stack);
    } finally {
      isPickingPhoto.value = false;
    }
  }

  void removePhoto() {
    photo.value = null;
    message.value = 'Photo removed.';
  }

  void logout() {
    _photoRequest++;
    nameController.clear();
    savedName.value = '';
    photo.value = null;
    message.value = null;
    Get.offAllNamed<void>(AppRoutes.login);
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
