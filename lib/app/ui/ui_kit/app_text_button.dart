import 'package:flutter/material.dart';

class AppTextButton extends StatelessWidget {
  const AppTextButton({
    required this.onPressed,
    required this.text,
    super.key,
    this.buttonStyle,
    this.height = 54,
    this.width,
    this.alignment,
    this.icon,
  });

  final VoidCallback onPressed;
  final String text;
  final ButtonStyle? buttonStyle;
  final double height;
  final double? width;
  final Alignment? alignment;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment ?? Alignment.center,
      child: SizedBox(
        height: height,
        width: width,
        child: ElevatedButton(
          onPressed: onPressed,
          style: buttonStyle,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 10),
              ],
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}
