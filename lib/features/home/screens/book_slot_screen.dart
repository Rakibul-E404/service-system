import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/common/widgets/time_picker_widget.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';
import '../../auth/widgets/app_custom_textfield.dart';
import '../widget/category_subCategory_picker.dart';

class BookASlotScreen extends StatefulWidget {
  const BookASlotScreen({
    super.key,
    required TextEditingController serviceNameTEController,
    required TextEditingController dateTEController,
    required this.timeController,
    required TextEditingController locationTEController,
    required TextEditingController additionalNoteTEController,
    this.onSubmitSuccess,
  })  : _serviceNameTEController = serviceNameTEController,
        _dateTEController = dateTEController,
        _locationTEController = locationTEController,
        _additionalNoteTEController = additionalNoteTEController;

  final TextEditingController _serviceNameTEController;
  final TextEditingController _dateTEController;
  final TimeController timeController;
  final TextEditingController _locationTEController;
  final TextEditingController _additionalNoteTEController;
  final VoidCallback? onSubmitSuccess;

  @override
  State<BookASlotScreen> createState() => BookASlotScreenState();
}

class BookASlotScreenState extends State<BookASlotScreen> {
  String? _catName;
  String? _catId;
  String? _subName;
  String? _subId;

  bool _isLocationDisabled = false;
  String? _selectedLocation;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = null;
  }

  @override
  void dispose() {
    widget._locationTEController.clear();
    widget._additionalNoteTEController.clear();
    super.dispose();
  }

  bool _validateFields() {
    if (_subId == null || _subId!.isEmpty) {
      _showSnackBar('Please select a service category', isError: true);
      return false;
    }
    if (_selectedLocation == null || _selectedLocation!.isEmpty) {
      _showSnackBar('Please select a location', isError: true);
      return false;
    }
    if (widget._additionalNoteTEController.text.trim().isEmpty) {
      _showSnackBar('Please add additional notes', isError: true);
      return false;
    }
    return true;
  }

  Future<void> submitBooking() async {
    if (!_validateFields()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      debugPrint('🚀 Starting API submission...');
      debugPrint('📌 Service Category ID: $_subId');
      debugPrint('📌 Location: $_selectedLocation');
      debugPrint('📌 Additional Note: ${widget._additionalNoteTEController.text.trim()}');

      final sharedPrefService = SharedPrefService();
      final accessToken = await sharedPrefService.getAccessToken();

      debugPrint('🔑 Retrieved access token: ${accessToken != null ? "Yes" : "No"}');

      final result = await BookSlotService.submitBooking(
        serviceCategory: _subId!,
        location: _selectedLocation!,
        additional: widget._additionalNoteTEController.text.trim(),
        accessToken: accessToken,
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      if (result['success'] == true) {
        _showSnackBar('Booking submitted successfully!');

        widget._additionalNoteTEController.clear();
        setState(() {
          _selectedLocation = null;
          _subId = null;
          _subName = null;
          _catId = null;
          _catName = null;
        });

        widget.onSubmitSuccess?.call();

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        _showSnackBar(result['message'] ?? 'Failed to submit booking', isError: true);
      }
    } catch (e) {
      debugPrint('❌ Exception during submission: $e');
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      _showSnackBar('Error: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
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
                  borderSide: const BorderSide(color: Colors.grey, width: 1.8),
                ),
              ),
            ),
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
              controller: widget._additionalNoteTEController,
              textInputAction: TextInputAction.done,
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

          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}



class BookSlotService {
  static const String baseUrl = AppUrl.searchQuoteUrl;

  static Future<Map<String, dynamic>> submitBooking({
    required String serviceCategory,
    required String location,
    required String additional,
    String? accessToken,
  }) async {
    try {
      // Prepare headers
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      // Add authorization header if token exists
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
        debugPrint('🔑 Authorization header added');
      } else {
        debugPrint('⚠️ No access token available');
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode({
          'serviceCategory': serviceCategory,
          'location': location.toLowerCase(), // Ensure lowercase
          'additional': additional,
        }),
      );

      debugPrint('📤 API Request: $baseUrl');
      debugPrint('📝 Body: ${jsonEncode({
        'serviceCategory': serviceCategory,
        'location': location.toLowerCase(),
        'additional': additional,
      })}');
      debugPrint('📥 Response Status: ${response.statusCode}');
      debugPrint('📥 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to submit booking: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      return {
        'success': false,
        'message': 'Error submitting booking: $e',
      };
    }
  }
}
