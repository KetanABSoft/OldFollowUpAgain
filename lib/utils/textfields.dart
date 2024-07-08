import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:followup/utils/textstyles.dart';
import 'app_color.dart';

class CustomTextField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool? obscureText;
  final bool? border;
  final EdgeInsets? padding;
  final String? Function(String?)? validator;
  final Color? cursorColor;
  final InputDecoration? decoration;
  final bool? filled;
  final bool? isRequired;
  final double? height;
  final double? width;
  final int? maxLength;
  final TextDirection? textDirection;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final List<TextInputFormatter>? textInputFormatter;
  final int? maxLines;
  final void Function(String?)? onSaved;
  final void Function(String)? onChange;
  final void Function(String)? onSubmitted;
  final Function()? onTap;
  final bool readOnly;
  final AutovalidateMode? autovalidateMode;
  final TextCapitalization? textCapitalization;
  final bool isShowCounterText;
  final TextStyle? labelStyle;
  final TextStyle? style;
  final Color? hintTextColor;
  final Color? borderColor;
  final Color? focusedBorderColor;

  const CustomTextField({
    Key? key,
    this.controller,
    this.labelText,
    this.hintText,
    this.height,
    this.textInputAction,
    this.keyboardType,
    this.filled,
    this.prefixIcon,
    this.obscureText,
    this.suffixIcon,
    this.border,
    this.padding,
    this.cursorColor,
    this.decoration,
    this.onSaved,
    this.validator,
    this.width,
    this.maxLength,
    this.textDirection,
    this.textInputFormatter,
    this.floatingLabelBehavior,
    this.maxLines,
    this.onChange,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.autovalidateMode,
    this.errorText,
    this.isRequired = false,
    this.textCapitalization,
    this.isShowCounterText = false,
    this.labelStyle,
    this.style,
    this.hintTextColor,
    this.borderColor,
    this.focusedBorderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: height ?? 55,
      width: width,
      child: TextFormField(
        style: style ??
            TextHelper.size15.copyWith(
              fontFamily: mediumFont,
              color: ColorsForApp.blackColor,
            ),
        cursorColor: cursorColor ?? ColorsForApp.primaryColor,
        onSaved: onSaved,
        autofocus: false,
        onChanged: onChange,
        onFieldSubmitted: onSubmitted,
        obscureText: obscureText ?? false,
        textAlignVertical: TextAlignVertical.center,
        controller: controller,
        maxLength: maxLength,
        textDirection: textDirection,
        textInputAction: textInputAction ?? TextInputAction.next,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        validator: validator,
        onTap: onTap,
        readOnly: readOnly,
        enableSuggestions: true,
        autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        decoration: decoration ??
            InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: borderColor ?? Colors.black,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: borderColor ?? Colors.black,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: focusedBorderColor ?? ColorsForApp.primaryColor,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              counterText: isShowCounterText ? null : '',
              labelStyle: TextHelper.size16,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              hintText: hintText,
              labelText: labelText,
              hintStyle: TextHelper.size14.copyWith(
                color: hintTextColor ?? Colors.black,
              ),
              errorText: errorText,
              fillColor: ColorsForApp.blackColor,
              filled: filled,
            ),
      ),
    );
  }
}