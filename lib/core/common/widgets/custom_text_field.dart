import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';

import '../../config/app_colors.dart';
import '../../config/app_icons.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool? isObscureText;
  final String? obscureCharacrter;
  final Color? filColor;
  final Color? borderColor;
  final int? maxLines;
  final int? minLines;
  final Widget? prefixIcon;
  final String? labelText;
  final String? hintText;
  final double? contenpaddingHorizontal;
  final double? borderRadius;
  final double? contenpaddingVertical;
  final Widget? suffixIcons;
  final FormFieldValidator? validator;
  final VoidCallback? onTab;
  final bool isPassword;
  final bool? isEmail;
  final bool isBorder;
  final bool? readOnly;
  final FloatingLabelBehavior floatingLabelBehavior;
  final VoidCallback prefixIconCallBack;
  final ValueChanged<String>? onChange;

  static void _emptyCallBack(){}


  const CustomTextField({
    super.key,
    this.contenpaddingHorizontal,
    this.contenpaddingVertical,
    this.hintText,
    this.prefixIcon,
    this.suffixIcons,
    this.validator,
    this.isEmail,
    this.borderColor = AppColors.primaryColor,
    required this.controller,
    this.floatingLabelBehavior = FloatingLabelBehavior.always,
    this.keyboardType = TextInputType.text,
    this.isObscureText = false,
    this.obscureCharacrter = '*',
    this.filColor,
    this.maxLines= 1,
    this.minLines= 1,
    this.labelText,
    this.borderRadius,
    this.isBorder = false,
    this.isPassword = false,
    this.readOnly = false,
    this.onTab,
    this.prefixIconCallBack= _emptyCallBack,
    this.onChange,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscureText = true;

  void toggle() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      onTap: widget.onTab,
      onChanged: widget.onChange,
      readOnly: widget.readOnly!,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscuringCharacter: widget.obscureCharacrter!,
      validator: widget.validator,
      onTapOutside: (PointerDownEvent pointerDownEvent) => context.hideKeyboard,
      cursorColor: AppColors.primaryColor,
      obscureText: widget.isPassword && obscureText,
      style: context.txtTheme.bodySmall,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
            horizontal: widget.contenpaddingHorizontal ?? 12.0,
            vertical: widget.contenpaddingVertical ?? 20.0),
        filled: true,
        fillColor: widget.filColor ?? Colors.transparent,
        prefixIcon: GestureDetector(
          onTap: widget.prefixIconCallBack,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.prefixIcon != null ? 8.0 : 0.0),
            child: widget.prefixIcon,
          ),
        ),
        suffixIcon: widget.isPassword
            ? GestureDetector(
          onTap: toggle,
          child: _suffixIcon(obscureText ? AppIcons.eyeCloseIcon : AppIcons.eyeOpenIcon),
        )
            : widget.suffixIcons,
        prefixIconConstraints: const BoxConstraints(minHeight: 24.0, minWidth: 24.0),
        suffixIconConstraints: const BoxConstraints(minHeight: 24.0, minWidth: 24.0),
        errorStyle: const TextStyle(color: Colors.red),
        suffixIconColor: AppColors.primaryColor,
        prefixIconColor: AppColors.primaryColor,
        labelText: widget.labelText,
        floatingLabelBehavior: widget.floatingLabelBehavior,
        floatingLabelStyle: context.txtTheme.bodySmall?.copyWith(
          color: AppColors.primaryColor,
        ),
        hintText: widget.hintText,
        hintStyle: context.txtTheme.bodySmall?.copyWith(
          color: AppColors.greyColor
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius != null ? widget.borderRadius! : 8.0),
          borderSide: BorderSide(
            width: widget.isBorder == true ? 1.0 : 0.0,
            color:  widget.isBorder == true ? widget.borderColor ?? AppColors.borderColor : Colors.transparent,
          ),
        ),
        errorBorder: _buildOutlineInputBorder(),
        focusedBorder: _buildOutlineInputBorder(),
        enabledBorder: _buildOutlineInputBorder(),
        disabledBorder: _buildOutlineInputBorder(),
      ),
    );
  }

  Padding _suffixIcon(String icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 15.0),
      child: SvgPicture.asset(
        colorFilter: const ColorFilter.mode(AppColors.primaryColor, BlendMode.srcATop),
        icon,
      ),
    );
  }

  OutlineInputBorder _buildOutlineInputBorder() {
    return OutlineInputBorder(
      borderSide: BorderSide(
        width: widget.isBorder == true ? 1.0 : 0.0,
        color:  widget.isBorder == true ? widget.borderColor ?? AppColors.borderColor : Colors.transparent,
        strokeAlign: BorderSide.strokeAlignOutside,
        // color: AppColors.borderColor,
      ),
      borderRadius: BorderRadius.circular(widget.borderRadius != null ? widget.borderRadius! : 4.0)
    );
  }
}