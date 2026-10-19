import 'package:flutter/material.dart';
import 'package:entry_ui/entry_ui.dart';
import 'package:get/get.dart';

import 'package:entry_book/screens/profile/profile_controller.dart';
import 'package:entry_book/screens/profile/widgets/profile_photo.dart';

class ProfileForm extends GetView<ProfileController> {
  const ProfileForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ProfilePhoto(),
          const SizedBox(height: 24),
          AppInput(
            label: 'Your name',
            isRequired: true,
            hint: 'Enter your name',
            controller: controller.nameController,
            validator: controller.validateName,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.name],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => controller.saveProfile(),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              label: 'Save',
              size: AppButtonSize.medium,
              onPressed: controller.saveProfile,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Demo · Changes reset on logout',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Obx(() {
            final message = controller.message.value;
            return message == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Semantics(liveRegion: true, child: Text(message)),
                  );
          }),
        ],
      ),
    );
  }
}
