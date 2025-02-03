import 'package:alearn/app/ui/theme/app_color.dart';
import 'package:alearn/app/ui/ui_kit/text_field/input_formatters.dart';
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
    this.preffixIcon,
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
    this.preffix,
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
    this.firstWorkCapitalization = true,
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
  final Widget? preffixIcon;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? suffixIconConstraints;
  final FocusNode? focusNode;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextStyle? errorStyle;
  final TextStyle style;
  final Function(String value)? onChanged;
  final VoidCallback? onEditingComplete;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Function(PointerDownEvent)? onTapOutside;
  final Widget? preffix;
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
  final bool firstWorkCapitalization;
  final Function(String)? onFieldSubmitted;
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
      inputFormatters: inputFormatters ??
          [
            LetterWithSpaceInputFormatter(
              firstWordCapitalization: firstWorkCapitalization,
            ),
          ],
      cursorColor: cursorColor,
      decoration: InputDecoration(
        errorText: errorText,
        filled: filled,
        focusedErrorBorder: focusedErrorBorder ??
            const OutlineInputBorder(
              borderSide: BorderSide(color: ColorResource.primaryRed500),
              borderRadius: BorderRadius.all(
                Radius.circular(16),
              ),
            ),
        errorBorder: errorBorder ??
            const OutlineInputBorder(
              borderSide: BorderSide(color: ColorResource.primaryRed500),
              borderRadius: BorderRadius.all(
                Radius.circular(16),
              ),
            ),
        contentPadding: padding,
        isDense: isDense,
        fillColor: fillColor,
        hintText: hintText,
        hintStyle: hintStyle,
        prefix: preffix,
        prefixIcon: preffixIcon,
        suffixIcon: suffixIcon,
        suffix: suffix,
        counterText: counterText,
        focusedBorder: focusedBorder ??
            const OutlineInputBorder(
              borderSide: BorderSide(color: ColorResource.naturalGrey950),
              borderRadius: BorderRadius.all(
                Radius.circular(16),
              ),
            ),
        border: border ??
            const OutlineInputBorder(
              borderSide: BorderSide(color: ColorResource.naturalGrey950),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
        disabledBorder: disabledBorder ??
            const OutlineInputBorder(
              borderSide: BorderSide(color: ColorResource.naturalGrey950),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
        enabledBorder: enabledBorder ??
            const OutlineInputBorder(
              borderSide: BorderSide(color: ColorResource.naturalGrey950),
              borderRadius: BorderRadius.all(
                Radius.circular(16),
              ),
            ),
        prefixIconConstraints: prefixIconConstraints ??
            const BoxConstraints(
              minHeight: 20,
              maxHeight: 40,
              minWidth: 20,
              maxWidth: 40,
            ),
      ),
      scrollPhysics: scrollPhysics,
      expands: expands,
    );
  }
}
