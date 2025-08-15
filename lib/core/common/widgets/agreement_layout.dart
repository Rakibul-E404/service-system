import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';

import '../../config/app_colors.dart';
import '../../config/app_strings.dart';
import '../../routes/app_routes.dart';

class AgreementLayout extends StatelessWidget {
  final bool value;
  final Function(bool? value) onChange;

  const AgreementLayout({
    super.key, 
    required this.value, 
    required this.onChange
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Checkbox(
          side: const BorderSide(
            color: AppColors.primaryColor,
          ),
          checkColor: value ? AppColors.whiteColor : AppColors.primaryColor,
          fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            if(states.contains(WidgetState.selected)) {
              return AppColors.primaryColor;
            } else {
              return Colors.transparent;
            }
          }),
          value: value, 
          onChanged: onChange,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              onChange(!value);
            },
            child: RichText(
              text: TextSpan(
                text: AppStrings.agreeToThe,
                style: context.txtTheme.bodyLarge,
                children: <TextSpan>[
                  TextSpan(
                    text: " ${AppStrings.termsAndCondition}",
                    style: context.txtTheme.bodyLarge?.copyWith(
                      color: Colors.red
                    ),
                    recognizer: TapGestureRecognizer()..onTap = (){

                    }
                  ),
                  TextSpan(
                    text: " ${AppStrings.and} ",
                    style: context.txtTheme.bodyLarge
                  ),
                  TextSpan(
                    text: " ${AppStrings.privacyPolicy}",
                    style: context.txtTheme.bodyLarge?.copyWith(
                      color: Colors.red
                    ),
                    recognizer: TapGestureRecognizer()..onTap = (){
                      //  Get.toNamed(
                      //   AppRoutes.generalRoute,
                      //
                      // );
                    }
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}