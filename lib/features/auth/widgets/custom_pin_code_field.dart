/**
import 'package:flutter/material.dart';
import 'package:manx_mate/core/config/app_colors.dart' show AppColors;
import 'package:pin_code_fields/pin_code_fields.dart';


class CustomPinCodeTextField extends StatelessWidget {
  const CustomPinCodeTextField({super.key, this.textEditingController});

  final TextEditingController? textEditingController;

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      backgroundColor: Colors.transparent,
      cursorColor: AppColors.primaryColor,
      controller: textEditingController,
      textStyle: TextStyle(color: Colors.black),
      autoFocus: false,
      appContext: context,
      length: 6,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(8),
        selectedColor: AppColors.primaryColor,
        activeFillColor: AppColors.primaryColor,
        selectedFillColor: AppColors.greyColor,
        inactiveFillColor: AppColors.primaryColor,
        fieldHeight: 57 ,
        fieldWidth: 44 ,
        inactiveColor: AppColors.primaryColor,
        activeColor: AppColors.primaryColor,
      ),
      obscureText: false,
      keyboardType: TextInputType.number,
      onChanged: (value) {},
    );
  }
}
*/





///
///
///
///
///
///
///
///
///




import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../core/config/app_colors.dart';

class CustomPinCodeTextField extends StatelessWidget {
  final Function(String)? onChanged;
  final Function(String)? onCompleted;
  final TextEditingController? controller;

  const CustomPinCodeTextField({
    super.key,
    this.onChanged,
    this.onCompleted,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      length: 6,
      obscureText: false,
      animationType: AnimationType.scale,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(8),
        fieldHeight: 50,
        fieldWidth: 45,
        activeFillColor: Colors.white,
        inactiveFillColor: Colors.white,
        selectedFillColor: Colors.white,
        activeColor: AppColors.primaryColor,
        inactiveColor: Colors.grey[300],
        selectedColor: AppColors.primaryColor,
        borderWidth: 2,
      ),
      animationDuration: const Duration(milliseconds: 200),
      backgroundColor: Colors.transparent,
      enableActiveFill: true,
      cursorColor: AppColors.primaryColor,
      controller: controller,
      onCompleted: onCompleted,
      onChanged: onChanged ?? (value) {},
      beforeTextPaste: (text) {
        return text?.length == 6;
      },
      keyboardType: TextInputType.number,
      autoFocus: true,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}