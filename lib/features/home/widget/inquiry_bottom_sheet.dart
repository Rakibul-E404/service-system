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
  })  : _serviceNameTEController = serviceNameTEController,
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
            formHintText: "Service Name",
            controller: _serviceNameTEController,
            validator: (String? value) {
              if (value?.isEmpty ?? true) {
                return '${AppStrings.pleaseEnterYour} Service Name!!';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: AppSizes.sm),


        // LOCATION DROPDOWN - FIXED
        LocationDropdown(
          initialValue: _locationTEController.text.isNotEmpty
              ? _normalizeLocation(_locationTEController.text)
              : null,
          onChanged: (value) {
            _locationTEController.text = value ?? '';
          },
        ),

        const SizedBox(height: AppSizes.sm),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryColor, width: 1.8),
          ),
          child: TextFormField(
            controller: _additionalNoteTEController,
            textInputAction: TextInputAction.newline,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: "Additional note",
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              border: InputBorder.none,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(18)),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(18)),
                borderSide: BorderSide(color: Colors.transparent),
              ),
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
  })  : _serviceNameTEController = serviceNameTEController,
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
                return '${AppStrings.pleaseEnterYour} Service Name!!';
              }
              return null;
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
                return '${AppStrings.pleaseEnterYour} Type!!';
              }
              return null;
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
        const SizedBox(height: AppSizes.md),

        TimePickerWidget(
          label: 'Pick a time',
          controller: timeController,
          showTimeIcon: true,
          showBorder: true,
        ),
        const SizedBox(height: AppSizes.md),

        // LOCATION DROPDOWN - FIXED
        LocationDropdown(
          initialValue: _locationTEController.text.isNotEmpty
              ? _normalizeLocation(_locationTEController.text)
              : null,
          onChanged: (value) {
            _locationTEController.text = value ?? '';
          },
        ),

        const SizedBox(height: AppSizes.md),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryColor, width: 1.8),
          ),
          child: TextFormField(
            controller: _additionalNoteTEController,
            textInputAction: TextInputAction.newline,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: "Additional note",
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              border: InputBorder.none,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(18)),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(18)),
                borderSide: BorderSide(color: Colors.transparent),
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSizes.md),

        ImagePickerWidget(
          onImageSelected: (File file) {
            print('Image selected: ${file.path}');
          },
        ),

        const SizedBox(height: AppSizes.md),
      ],
    );
  }
}

// Helper to normalize case
String _normalizeLocation(String location) {
  switch (location.toLowerCase()) {
    case 'north':
      return 'North';
    case 'south':
      return 'South';
    case 'east':
      return 'East';
    case 'west':
      return 'West';
    default:
      return 'North'; // fallback
  }
}

// REUSABLE LOCATION DROPDOWN - FIXED & BULLETPROOF
// REUSABLE LOCATION DROPDOWN - WITH VISIBLE BORDER (FIXED & BEAUTIFUL)
class LocationDropdown extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String?> onChanged;

  const LocationDropdown({
    super.key,
    this.initialValue,
    required this.onChanged,
  });

  @override
  State<LocationDropdown> createState() => _LocationDropdownState();
}

class _LocationDropdownState extends State<LocationDropdown> {
  late String? _selectedLocation;
  final List<String> _locations = ['North', 'South', 'East', 'West'];

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialValue != null
        ? _normalizeLocation(widget.initialValue!)
        : null;
  }

  @override
  void didUpdateWidget(covariant LocationDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _selectedLocation = widget.initialValue != null
          ? _normalizeLocation(widget.initialValue!)
          : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
        border: Border.all(
          color: AppColors.primaryColor,
          width: 2.0, // Same as your other fields
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0), // Optional: inner padding
        child: DropdownButtonFormField<String>(
          value: _selectedLocation,
          hint: const Text(
            "Select Location",
            style: TextStyle(color: Colors.grey),
          ),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
          dropdownColor: Colors.white,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 16),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
          items: _locations.map((location) {
            return DropdownMenuItem<String>(
              value: location,
              child: Text(location),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedLocation = newValue;
            });
            widget.onChanged(newValue);
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a location';
            }
            return null;
          },
        ),
      ),
    );
  }
}