import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/common/widgets/time_picker_widget.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/config/app_strings.dart';
import '../../auth/widgets/app_custom_textfield.dart';
import '../../auth/widgets/custom_text_field.dart';
import '../../auth/widgets/reusable_date_picker_field.dart';
import '../../provider/widgets/image_picker_widget.dart';

class InquiryBottomSheet extends StatelessWidget {
  const InquiryBottomSheet({
    super.key,
    required TextEditingController serviceNameTEController,
    required TextEditingController dateTEController,
    required this.timeController,
    required TextEditingController locationTEController,
    required TextEditingController additionalNoteTEController,
  }) : _serviceNameTEController = serviceNameTEController,
       _dateTEController = dateTEController,
       _locationTEController = locationTEController,
       _additionalNoteTEController = additionalNoteTEController;

  final TextEditingController _serviceNameTEController;
  final TextEditingController _dateTEController;
  final TimeController timeController;
  final TextEditingController _locationTEController;
  final TextEditingController _additionalNoteTEController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AppCustomContainerField(
          containerChild: MyTextFormFieldWithIcon(
            formHintText: "Category",
            controller: _serviceNameTEController,
            validator: (String? value) {
              if (value?.isEmpty ?? true) {
                return '${AppStrings.pleaseEnterYour} ${AppStrings.email}!!';
              }
              return null;
            },
            onChanged: (String value) {
              // print("Email Input: $value");
            },
          ),
        ),
        const SizedBox(height: AppSizes.md),
        AppCustomContainerField(
          containerChild: MyTextFormFieldWithIcon(
            formHintText: "Sub Category Name",
            controller: _serviceNameTEController,
            validator: (String? value) {
              if (value?.isEmpty ?? true) {
                return '${AppStrings.pleaseEnterYour} ${AppStrings.email}!!';
              }
              return null;
            },
            onChanged: (String value) {
              // print("Email Input: $value");
            },
          ),
        ),
        const SizedBox(height: AppSizes.md),

///--------------- todo:: client asked to remove it.
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: AppColors.primaryColor, width: 2),
//             borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
//           ),
//           child: ReusableDatePickerField(
//             controller: _dateTEController,
//             hintText: 'Select the Date',
//           ),
//         ),
//         const SizedBox(height: AppSizes.md),
//
//         TimePickerWidget(
//           label: 'Pick a time',
//           controller: timeController,
//           showTimeIcon: true,
//           // Show the time icon (optional)
//           showBorder: true,
//           // Show the border (optional)
//         ),

        AppCustomContainerField(
          containerChild: MyTextFormFieldWithIcon(
            formHintText: "Location",
            controller: _locationTEController,
            validator: (String? value) {
              if (value?.isEmpty ?? true) {
                return '${AppStrings.pleaseEnterYour} ${AppStrings.email}!!';
              }
              return null;
            },
            onChanged: (String value) {
              // print("Email Input: $value");
            },
          ),
        ),
        const SizedBox(height: AppSizes.md),

        Container(
          // padding: EdgeInsets.symmetric(vertical: 12,horizontal: 8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryColor, width: 1.8),
          ),
          child: TextFormField(
            controller: _additionalNoteTEController,
            textInputAction: TextInputAction.next,
            maxLines: 5,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                // Same borderRadius for consistency
                borderSide: const BorderSide(
                  color: Colors.transparent, // Apply the primary color
                ),
              ),
              hintText: "Additional note",
              // border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.md),
      ],
    );
  }
}

class AddServiceBottomSheet extends StatelessWidget {
  const AddServiceBottomSheet({
    super.key,
    required TextEditingController serviceNameTEController,
    required TextEditingController dateTEController,
    required TextEditingController typeTEController,
    required this.timeController,
    required TextEditingController locationTEController,
    required TextEditingController additionalNoteTEController,
  }) : _serviceNameTEController = serviceNameTEController,
       _dateTEController = dateTEController,
       _typeNameTEController = typeTEController,
       _locationTEController = locationTEController,
       _additionalNoteTEController = additionalNoteTEController;

  final TextEditingController _serviceNameTEController;
  final TextEditingController _typeNameTEController;
  final TextEditingController _dateTEController;
  final TimeController timeController;
  final TextEditingController _locationTEController;
  final TextEditingController _additionalNoteTEController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AppCustomContainerField(
          containerChild: MyTextFormFieldWithIcon(
            formHintText: "Service Name",
            controller: _serviceNameTEController,
            validator: (String? value) {
              if (value?.isEmpty ?? true) {
                return '${AppStrings.pleaseEnterYour} ${AppStrings.email}!!';
              }
              return null;
            },
            onChanged: (String value) {
              // print("Email Input: $value");
            },
          ),
        ),
        const SizedBox(height: AppSizes.md),
        AppCustomContainerField(
          containerChild: MyTextFormFieldWithIcon(
            formHintText: "Type",
            controller: _typeNameTEController,
            validator: (String? value) {
              if (value?.isEmpty ?? true) {
                return '${AppStrings.pleaseEnterYour} ${AppStrings.email}!!';
              }
              return null;
            },
            onChanged: (String value) {
              // print("Email Input: $value");
            },
          ),
        ),
        const SizedBox(height: AppSizes.md),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primaryColor, width: 2),
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
          ),
          child: ReusableDatePickerField(
            controller: _dateTEController,
            hintText: 'Select the Date',
          ),
        ),

        TimePickerWidget(
          label: 'Pick a time',
          controller: timeController,
          showTimeIcon: true,
          // Show the time icon (optional)
          showBorder: true,
          // Show the border (optional)
        ),
        AppCustomContainerField(
          containerChild: MyTextFormFieldWithIcon(
            formHintText: "Location",
            controller: _locationTEController,
            validator: (String? value) {
              if (value?.isEmpty ?? true) {
                return '${AppStrings.pleaseEnterYour} ${AppStrings.email}!!';
              }
              return null;
            },
            onChanged: (String value) {
              // print("Email Input: $value");
            },
          ),
        ),
        const SizedBox(height: AppSizes.md),

        Container(
          // padding: EdgeInsets.symmetric(vertical: 12,horizontal: 8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryColor, width: 1.8),
          ),
          child: TextFormField(
            controller: _additionalNoteTEController,
            textInputAction: TextInputAction.next,
            maxLines: 5,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                // Same borderRadius for consistency
                borderSide: const BorderSide(
                  color: Colors.transparent, // Apply the primary color
                ),
              ),
              hintText: "Additional note",
              // border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.md),
        ImagePickerWidget(
          onImageSelected: (File file) {
            print('Image selected: ${file.path}');
          },
        ),
      ],
    );
  }
}






