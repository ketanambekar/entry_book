import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Helpers {
  static final NumberFormat _inrFormat = NumberFormat('#,##,##0.00', 'en_IN');

  static String formatDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);

  static String formatAmount(double amount) => '₹${_inrFormat.format(amount)}';

  static Text amountText(
    double amount, {
    TextStyle? style,
    TextAlign? textAlign,
  }) {
    final base = style ?? const TextStyle();
    final amountColor = Get.isDarkMode ? Colors.green.shade300 : Colors.green.shade700;
    return Text(
      formatAmount(amount),
      textAlign: textAlign,
      style: base.copyWith(
        color: base.color ?? amountColor,
        fontWeight: base.fontWeight ?? FontWeight.w600,
      ),
    );
  }

  static void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  static void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
