import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:entry_ui/entry_ui.dart';

class LoginPhoneInput extends StatelessWidget {
  const LoginPhoneInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.validator,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FormFieldValidator<String> validator;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accent = Color(0xFFED6010);
    final textStyle = AppTextStyles.subtitleS.medium.copyWith(
      height: 1.3,
      color: isDark ? colors.onSurface : const Color(0xFF4E4949),
    );

    return FormField<String>(
      initialValue: controller.text,
      validator: (_) => validator(controller.text),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phone number*',
            style: AppTextStyles.bodyS.medium.copyWith(
              color: isDark ? colors.onSurfaceVariant : const Color(0xFF7A7A7A),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark
                      ? colors.surfaceContainerHigh
                      : const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+91',
                  style: textStyle.copyWith(
                    color: isDark ? colors.onSurface : const Color(0xFF170C06),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ListenableBuilder(
                  listenable: focusNode,
                  builder: (context, _) {
                    final borderColor = field.hasError ? colors.error : accent;
                    return Container(
                      key: const ValueKey('login-phone-box'),
                      height: 48,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: isDark ? colors.surface : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: focusNode.hasFocus || field.hasError
                              ? borderColor
                              : colors.outline,
                          width: 1.5,
                        ),
                        boxShadow: [
                          if (focusNode.hasFocus)
                            BoxShadow(
                              color: borderColor.withValues(alpha: 0.25),
                              spreadRadius: 1.5,
                            ),
                        ],
                      ),
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        style: textStyle,
                        textAlignVertical: TextAlignVertical.center,
                        cursorColor: isDark
                            ? colors.onSurface
                            : const Color(0xFF141414),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [
                          AutofillHints.telephoneNumberNational,
                        ],
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        onChanged: field.didChange,
                        onSubmitted: (_) => onSubmitted(),
                        decoration:
                            InputDecoration.collapsed(
                              hintText: '7022480958',
                              hintStyle: textStyle.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ).copyWith(
                              semanticCounterText:
                                  '10-digit phone number, country code +91',
                            ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (field.errorText case final error?)
            Padding(
              padding: const EdgeInsets.only(left: 64, top: 8),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  error,
                  style: AppTextStyles.bodyS.medium.copyWith(
                    color: colors.error,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
