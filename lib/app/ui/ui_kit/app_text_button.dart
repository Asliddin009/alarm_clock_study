import 'package:flutter/material.dart';

class AppTextButton extends StatelessWidget {
  const AppTextButton({
    required this.onPressed,
    required this.text,
    super.key,
    this.buttonStyle,
    this.height = 35,
    this.width = 350,
    this.alignment,
  });

  final VoidCallback onPressed;
  final String text;
  final ButtonStyle? buttonStyle;
  final double height;
  final double width;
  final Alignment? alignment;
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
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
