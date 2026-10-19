import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:entry_book/screens/login/login_controller.dart';
import 'package:entry_book/screens/login/widgets/login_header.dart';
import 'package:entry_book/screens/login/widgets/login_otp_form.dart';
import 'package:entry_book/screens/login/widgets/login_phone_form.dart';
import 'package:entry_book/screens/login/widgets/login_version_footer.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const LoginVersionFooter(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 32),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const LoginHeader(),
                  const SizedBox(height: 40),
                  Obx(
                    () => controller.isOtpStep.value
                        ? const LoginOtpForm()
                        : const LoginPhoneForm(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
