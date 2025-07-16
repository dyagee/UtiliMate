// lib/widgets/custom_button.dart
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Changed to nullable VoidCallback?
  final IconData? icon;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed, // No longer required, can be null
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.textStyle,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed:
          onPressed, // This will now correctly accept null for disabled state
      style: ElevatedButton.styleFrom(
        backgroundColor:
            backgroundColor ?? Theme.of(context).colorScheme.primary,
        foregroundColor:
            foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
        padding: padding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: Theme.of(context).colorScheme.shadow,
      ),
      icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
      label: Text(
        text,
        style:
            textStyle ??
            Theme.of(context).textTheme.labelLarge?.copyWith(
              color: foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
            ),
      ),
    );
  }
}
