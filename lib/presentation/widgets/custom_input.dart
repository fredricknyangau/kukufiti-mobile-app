import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String? label;
  final String? hintText;
  final bool obscureText;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final int? maxLines;
  final FocusNode? focusNode;

  const CustomInput({
    super.key,
    this.label,
    this.hintText,
    this.obscureText = false,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.onChanged,
    this.maxLines = 1,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          keyboardType: keyboardType,
          onChanged: onChanged,
          maxLines: maxLines,
          focusNode: focusNode,
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
            prefixIcon: prefixIcon != null ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: prefixIcon,
            ) : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 40),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: theme.colorScheme.brightness == Brightness.light
                ? const Color(0xFFF1F5F9) // Slate 100
                : theme.colorScheme.surface.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5), width: 1),
            ),
          ),
        ),

      ],
    );
  }
}
