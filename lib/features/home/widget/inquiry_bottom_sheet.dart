
import 'package:flutter/material.dart';
import '../../../core/common/widgets/time_picker_widget.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../auth/widgets/app_custom_textfield.dart';
import 'category_subCategory_picker.dart';

class InquiryBottomSheet extends StatefulWidget {
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
  State<InquiryBottomSheet> createState() => _InquiryBottomSheetState();
}

class _InquiryBottomSheetState extends State<InquiryBottomSheet> {
  String? _catName;
  String? _catId;
  String? _subName;
  String? _subId;

  // Variable to track if selection is disabled
  bool _isLocationDisabled = false;

  // Variable to track location dropdown value
  String? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = null; // Initialize with no value.
  }

  @override
  void dispose() {
    super.dispose();
    // Reset controllers when the bottom sheet is disposed
    widget._locationTEController.clear();
    widget._additionalNoteTEController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          /// ==================== CATEGORY + SUB-CATEGORY ====================
          CategorySubCategoryPicker(
            onCategoryChanged: (name, id) {
              setState(() {
                _catName = name;
                _catId = id;
              });
            },
            onSubCategoryChanged: (name, id) {
              setState(() {
                _subName = name;
                _subId = id;
              });
            },
          ),

          const SizedBox(height: AppSizes.md),

          /// ==================== LOCATION (Dropdown) ====================
          AppCustomContainerField(
            containerChild: DropdownButtonFormField<String>(
              value: _selectedLocation,
              onChanged: _isLocationDisabled
                  ? null
                  : (String? newValue) {
                setState(() {
                  _selectedLocation = newValue ?? '';
                  widget._locationTEController.text = newValue ?? '';
                });
              },
              items: ['north', 'south', 'east', 'west']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Location',
                labelStyle: TextStyle(color: AppColors.primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: AppColors.primaryColor, width: 1.8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: AppColors.primaryColor, width: 1.8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: Colors.grey, width: 1.8),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSizes.md),

          /// ==================== ADDITIONAL NOTE ====================
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryColor, width: 1.8),
            ),
            child: TextFormField(
              controller: widget._additionalNoteTEController,
              textInputAction: TextInputAction.next,
              maxLines: 5,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                hintText: "Additional note",
                contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              ),
            ),
          ),

          const SizedBox(height: AppSizes.md),

          /// ==================== SUBMIT (example) ====================
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                debugPrint('Category: $_catName ($_catId)');
                debugPrint('Sub-Category: $_subName ($_subId)');
                debugPrint('Location: ${_selectedLocation}');
                debugPrint('Note: ${widget._additionalNoteTEController.text}');

                // Disable location selection after submit
                setState(() {
                  _isLocationDisabled = true;
                });

                // Close the modal and reset the data
                Navigator.of(context).pop(); // Close the bottom sheet and reset form data
              },
              child: const Text(
                'Submit Inquiry',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
