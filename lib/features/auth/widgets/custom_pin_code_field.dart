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
