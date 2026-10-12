import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../theme/colors.dart';
import '../../widgets/app_button.dart';
import 'controller.dart';

class ConfirmationView extends GetView<ConfirmationController> {
  const ConfirmationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 700),
                tween: Tween<double>(begin: 0.3, end: 1),
                curve: Curves.elasticOut,
                builder: (context, value, _) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      height: 110,
                      width: 110,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 64, color: Colors.white),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(controller.title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(controller.message, textAlign: TextAlign.center),
              const SizedBox(height: 28),
              AppButton(
                label: 'Back to Dashboard',
                icon: Icons.home,
                onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
