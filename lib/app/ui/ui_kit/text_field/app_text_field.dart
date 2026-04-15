import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BaseTextField extends StatelessWidget {
  const BaseTextField({
    super.key,
    this.onTap,
    this.controller,
    this.hintText,
    this.hintStyle,
    this.filled,
    this.autoFocus,
    this.suffixIcon,
    this.prefixIcon,
    this.padding,
    this.suffixIconConstraints,
    this.focusNode,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.errorStyle,
    this.style = const TextStyle(),
    this.onChanged,
    this.onEditingComplete,
    this.textInputAction,
    this.keyboardType,
    this.inputFormatters,
    this.onTapOutside,
    this.prefix,
    this.errorText,
    this.suffix,
    this.textCapitalization = TextCapitalization.sentences,
    this.prefixIconConstraints,
    this.obscureText = false,
    this.autocorrect = false,
    this.enableSuggestions = true,
    this.isDense = false,
    this.validator,
    this.enabled,
    this.fillColor,
    this.counterText,
    this.onFieldSubmitted,
    this.autovalidateMode,
    this.focusedBorder,
    this.border,
    this.disabledBorder,
    this.enabledBorder,
    this.cursorHeight,
    this.errorBorder,
    this.focusedErrorBorder,
    this.expands = false,
    this.scrollPhysics,
    this.cursorColor,
    this.readOnly = false,
  });

  final void Function()? onTap;
  final TextEditingController? controller;
  final String? hintText;
  final TextStyle? hintStyle;
  final bool? filled;
  final bool? autoFocus;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? suffixIconConstraints;
  final FocusNode? focusNode;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextStyle? errorStyle;
  final TextStyle style;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TapRegionCallback? onTapOutside;
  final Widget? prefix;
  final Widget? suffix;
  final String? errorText;
  final TextCapitalization textCapitalization;
  final BoxConstraints? prefixIconConstraints;
  final bool obscureText;
  final bool enableSuggestions;
  final bool autocorrect;
  final String? Function(String?)? validator;
  final bool? enabled;
  final Color? fillColor;
  final String? counterText;
  final ValueChanged<String>? onFieldSubmitted;
  final InputBorder? focusedBorder;
  final InputBorder? border;
  final InputBorder? disabledBorder;
  final InputBorder? enabledBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final bool isDense;
  final AutovalidateMode? autovalidateMode;
  final double? cursorHeight;
  final bool expands;
  final ScrollPhysics? scrollPhysics;
  final bool readOnly;
  final Color? cursorColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
    );

    return TextFormField(
      onChanged: onChanged,
      cursorHeight: cursorHeight,
      autovalidateMode: autovalidateMode,
      onTap: onTap,
      key: key,
      focusNode: focusNode,
      enabled: enabled,
      validator: validator,
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      readOnly: readOnly,
      textCapitalization: textCapitalization,
      minLines: minLines,
      onFieldSubmitted: onFieldSubmitted,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      obscureText: obscureText,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      keyboardType: keyboardType,
      style: style,
      inputFormatters: inputFormatters,
      cursorColor: cursorColor,
      onTapOutside: onTapOutside,
      decoration: InputDecoration(
        errorText: errorText,
        filled: filled,
        fillColor: fillColor,
        hintText: hintText,
        hintStyle: hintStyle,
        prefix: prefix,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        suffix: suffix,
        counterText: counterText,
        contentPadding: padding,
        isDense: isDense,
        errorStyle: errorStyle,
        focusedBorder: focusedBorder ??
            defaultBorder.copyWith(
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
        border: border ?? defaultBorder,
        disabledBorder: disabledBorder ?? defaultBorder,
        enabledBorder: enabledBorder ?? defaultBorder,
        errorBorder: errorBorder ??
            defaultBorder.copyWith(
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
        focusedErrorBorder: focusedErrorBorder ??
            defaultBorder.copyWith(
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
        prefixIconConstraints: prefixIconConstraints,
        suffixIconConstraints: suffixIconConstraints,
      ),
      scrollPhysics: scrollPhysics,
      expands: expands,
    );
  }
}
