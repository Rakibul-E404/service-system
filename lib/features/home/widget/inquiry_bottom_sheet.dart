import 'package:flutter/material.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import '../../../core/common/widgets/time_picker_widget.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/token_service/token_storage_service.dart';
import '../../auth/widgets/app_custom_textfield.dart';
import 'category_subCategory_picker.dart';

class InquiryService {
  static const String baseUrl = AppUrl.postInquiryQuote;
  static const String bookingUrl = AppUrl.bookingUrl;

  static Future<Map<String, dynamic>> submitInquiry({
    required String category,
    required String subCategory,
    required String region,
    required String location,
    required String date,
    required String additionalInfo,
    String? accessToken,
  }) async {
    try {
      debugPrint('🚀 ========== SUBMITTING INQUIRY ==========');
      debugPrint('📋 Category: $category');
      debugPrint('📋 SubCategory: $subCategory');
      debugPrint('🌍 Region: $region');
      debugPrint('📍 Location: $location');
      debugPrint('📅 Date: $date');
      debugPrint('📝 Additional Info: $additionalInfo');
      debugPrint('🔑 Access Token: ${accessToken != null ? "Present" : "Not Present"}');

      final Map<String, String>? headers = accessToken != null && accessToken.isNotEmpty
          ? {'Authorization': 'Bearer $accessToken'}
          : null;

      final Map<String, dynamic> body = {
        'category': category,
        'subCategory': subCategory,
        'region': region,
        'location': location,
        'date': date,
        'additionalInfo': additionalInfo,
      };

      debugPrint('📦 Request Body: $body');

      final NetworkResponse response = await NetworkCaller().postRequest(
        baseUrl,
        body: body,
        headers: headers,
      );

      debugPrint('📬 Response Status Code: ${response.statusCode}');
      debugPrint('✅ Response Success: ${response.isSuccess}');
      debugPrint('📄 Response JSON: ${response.jsonResponse}');
      debugPrint('🚫 Response Error: ${response.errorMessage}');

      if (response.isSuccess) {
        debugPrint('✅ ========== INQUIRY SUBMITTED SUCCESSFULLY ==========');
        return {
          'success': true,
          'data': response.jsonResponse,
        };
      } else {
        debugPrint('❌ ========== INQUIRY SUBMISSION FAILED ==========');
        return {
          'success': false,
          'message': response.errorMessage ?? 'Failed to submit inquiry',
          'error': response.jsonResponse,
        };
      }
    } catch (e) {
      debugPrint('💥 ========== INQUIRY SUBMISSION ERROR ==========');
      debugPrint('❌ Exception: $e');
      return {
        'success': false,
        'message': 'Error submitting inquiry: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> submitBooking({
    required String service,
    required String description,
    required String bookingDate,
    required String location,
    String? accessToken,
  }) async {
    try {
      debugPrint('🚀 ========== SUBMITTING BOOKING ==========');
      debugPrint('🛠️ Service: $service');
      debugPrint('📝 Description: $description');
      debugPrint('📅 Booking Date: $bookingDate');
      debugPrint('📍 Location: $location');
      debugPrint('🔑 Access Token: ${accessToken != null ? "Present" : "Not Present"}');

      final Map<String, String>? headers = accessToken != null && accessToken.isNotEmpty
          ? {'Authorization': 'Bearer $accessToken'}
          : null;

      final Map<String, dynamic> body = {
        'service': service,
        'description': description,
        'bookingDate': bookingDate,
        'location': location.toLowerCase(),
      };

      debugPrint('📦 Request Body: $body');

      final NetworkResponse response = await NetworkCaller().postRequest(
        bookingUrl,
        body: body,
        headers: headers,
      );

      debugPrint('📬 Response Status Code: ${response.statusCode}');
      debugPrint('✅ Response Success: ${response.isSuccess}');
      debugPrint('📄 Response JSON: ${response.jsonResponse}');
      debugPrint('🚫 Response Error: ${response.errorMessage}');

      if (response.isSuccess) {
        debugPrint('✅ ========== BOOKING SUBMITTED SUCCESSFULLY ==========');
        return {
          'success': true,
          'data': response.jsonResponse,
        };
      } else {
        debugPrint('❌ ========== BOOKING SUBMISSION FAILED ==========');
        return {
          'success': false,
          'message': response.errorMessage ?? 'Failed to submit booking',
          'error': response.jsonResponse,
        };
      }
    } catch (e) {
      debugPrint('💥 ========== BOOKING SUBMISSION ERROR ==========');
      debugPrint('❌ Exception: $e');
      return {
        'success': false,
        'message': 'Error submitting booking: $e',
      };
    }
  }
}

class InquiryBottomSheet extends StatefulWidget {
  const InquiryBottomSheet({
    super.key,
    required TextEditingController serviceNameTEController,
    required TextEditingController dateTEController,
    required this.timeController,
    required TextEditingController locationTEController,
    required TextEditingController additionalNoteTEController,
    this.onSubmitSuccess,
    this.isFromHomeScreen = false,
    this.preSelectedServiceId,
    this.preSelectedDate,
    this.preSelectedTime,
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
  final bool isFromHomeScreen;
  final String? preSelectedServiceId;
  final DateTime? preSelectedDate;
  final String? preSelectedTime;

  @override
  State<InquiryBottomSheet> createState() => InquiryBottomSheetState();
}

class InquiryBottomSheetState extends State<InquiryBottomSheet> {
  String? _catName;
  String? _catId;
  String? _subName;
  String? _subId;

  bool _isLocationDisabled = false;
  String? _selectedLocation;
  bool _isSubmitting = false;

  // Address field with dropdown suggestions
  final TextEditingController _addressController = TextEditingController();
  final FocusNode _addressFocusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  final OverlayPortalController _overlayController = OverlayPortalController();

  // Static address data for suggestions
  final List<String> _addressSuggestions = [
    'Dhaka, Bangladesh',
    'Dhaka City, Bangladesh',
    'Dhaka Division, Bangladesh',
    'Dhaka Cantonment, Bangladesh',
    'Dhaka Metropolitan, Bangladesh',
    'Dhaka University Area, Bangladesh',
    'Chittagong, Bangladesh',
    'Sylhet, Bangladesh',
    'Khulna, Bangladesh',
    'Rajshahi, Bangladesh',
    'Barisal, Bangladesh',
    'Rangpur, Bangladesh',
    'Mymensingh, Bangladesh',
    'Cox\'s Bazar, Bangladesh',
    'Gazipur, Bangladesh',
    'Narayanganj, Bangladesh',
    'Comilla, Bangladesh',
  ];

  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _selectedLocation = null;

    // Pre-fill the date and time if provided
    if (widget.preSelectedDate != null) {
      widget._dateTEController.text = _formatDate(widget.preSelectedDate!);
    }
    if (widget.preSelectedTime != null) {
      widget.timeController.updateSelectedTime(widget.preSelectedTime!);
    }

    // Listen to address field changes
    _addressController.addListener(_onAddressChanged);

    // Handle focus changes
    _addressFocusNode.addListener(() {
      if (_addressFocusNode.hasFocus && _addressController.text.isNotEmpty) {
        _filterSuggestions(_addressController.text);
        _overlayController.show();
      } else if (!_addressFocusNode.hasFocus) {
        // Hide overlay after a delay to allow for suggestion selection
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _overlayController.hide();
          }
        });
      }
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime date, String time) {
    final timeParts = time.replaceAll(RegExp(r'[apm]'), '').split(':');
    int hour = int.parse(timeParts[0]);
    final int minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;

    if (time.toLowerCase().contains('pm') && hour < 12) hour += 12;
    if (time.toLowerCase().contains('am') && hour == 12) hour = 0;

    final DateTime dateTime = DateTime(date.year, date.month, date.day, hour, minute);
    return dateTime.toIso8601String();
  }

  void _onAddressChanged() {
    _filterSuggestions(_addressController.text);
  }

  void _filterSuggestions(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredSuggestions.clear();
      });
      _overlayController.hide();
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredSuggestions = _addressSuggestions
          .where((address) => address.toLowerCase().contains(lowercaseQuery))
          .toList();
    });

    if (_filteredSuggestions.isNotEmpty && _addressFocusNode.hasFocus) {
      _overlayController.show();
    } else {
      _overlayController.hide();
    }
  }

  void _selectSuggestion(String suggestion) {
    setState(() {
      _addressController.text = suggestion;
    });
    _overlayController.hide();
    _addressFocusNode.unfocus();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _addressFocusNode.dispose();
    widget._locationTEController.clear();
    widget._additionalNoteTEController.clear();
    super.dispose();
  }

  bool _validateFields() {
    debugPrint('🔍 ========== VALIDATING FIELDS ==========');

    if (widget.isFromHomeScreen) {
      if (_catId == null || _catId!.isEmpty) {
        debugPrint('❌ Validation Failed: Category not selected');
        _showSnackBar('Please select a category', isError: true);
        return false;
      }
      debugPrint('✅ Category ID: $_catId');

      if (_subId == null || _subId!.isEmpty) {
        debugPrint('❌ Validation Failed: Sub-category not selected');
        _showSnackBar('Please select a sub-category', isError: true);
        return false;
      }
      debugPrint('✅ Sub-category ID: $_subId');
    }

    if (_selectedLocation == null || _selectedLocation!.isEmpty) {
      debugPrint('❌ Validation Failed: Region not selected');
      _showSnackBar('Please select a region', isError: true);
      return false;
    }
    debugPrint('✅ Region: $_selectedLocation');

    if (_addressController.text.trim().isEmpty) {
      debugPrint('❌ Validation Failed: Address is empty');
      _showSnackBar('Please enter your address', isError: true);
      return false;
    }
    debugPrint('✅ Address: ${_addressController.text.trim()}');

    if (widget._dateTEController.text.trim().isEmpty) {
      debugPrint('❌ Validation Failed: Date is empty');
      _showSnackBar('Please select a date', isError: true);
      return false;
    }
    debugPrint('✅ Date: ${widget._dateTEController.text.trim()}');

    if (widget._additionalNoteTEController.text.trim().isEmpty) {
      debugPrint('❌ Validation Failed: Additional notes are empty');
      _showSnackBar('Please add additional notes', isError: true);
      return false;
    }
    debugPrint('✅ Additional Notes: ${widget._additionalNoteTEController.text.trim()}');

    if (!widget.isFromHomeScreen && widget.preSelectedServiceId == null) {
      debugPrint('❌ Validation Failed: Service ID is required');
      _showSnackBar('Service ID is required', isError: true);
      return false;
    }

    debugPrint('✅ ========== ALL FIELDS VALIDATED SUCCESSFULLY ==========');
    return true;
  }

  Future<void> submitInquiry({
    String? serviceId,
    DateTime? selectedDate,
    String? selectedTime,
  }) async {
    debugPrint('🎬 ========== SUBMIT INQUIRY INITIATED ==========');

    if (!_validateFields()) {
      debugPrint('⚠️ Validation failed, submission aborted');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final sharedPrefService = SharedPrefService();
      final accessToken = await sharedPrefService.getAccessToken();

      debugPrint('🔐 Retrieved Access Token: ${accessToken != null ? "Present (${accessToken.substring(0, 20)}...)" : "Not Found"}');

      Map<String, dynamic> result;

      if (widget.isFromHomeScreen) {
        debugPrint('🏠 Submitting from HOME SCREEN');
        // Get the date from the controller
        final String dateString = widget._dateTEController.text.trim();

        result = await InquiryService.submitInquiry(
          category: _catId!,
          subCategory: _subId!,
          region: _selectedLocation!,
          location: _addressController.text.trim(),
          date: dateString,
          additionalInfo: widget._additionalNoteTEController.text.trim(),
          accessToken: accessToken,
        );
      } else {
        debugPrint('📋 Submitting BOOKING from Service Details');
        final String finalServiceId = serviceId ?? widget.preSelectedServiceId!;
        final DateTime finalDate = selectedDate ?? widget.preSelectedDate!;
        final String finalTime = selectedTime ?? widget.preSelectedTime ?? '10:00';
        final String formattedDateTime = _formatDateTime(finalDate, finalTime);

        // Combine location and address
        final fullLocation = '${_selectedLocation} - ${_addressController.text.trim()}';

        result = await InquiryService.submitBooking(
          service: finalServiceId,
          description: widget._additionalNoteTEController.text.trim(),
          bookingDate: formattedDateTime,
          location: fullLocation,
          accessToken: accessToken,
        );
      }

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      debugPrint('📊 Final Result: $result');

      if (result['success'] == true) {
        final successMessage = widget.isFromHomeScreen
            ? 'Inquiry submitted successfully!'
            : 'Booking submitted successfully!';

        debugPrint('🎉 $successMessage');
        _showSnackBar(successMessage);

        // Clear fields after success
        widget._additionalNoteTEController.clear();
        widget._dateTEController.clear();
        _addressController.clear();
        setState(() {
          _selectedLocation = null;
          _subId = null;
          _subName = null;
          _catId = null;
          _catName = null;
        });

        debugPrint('🧹 Fields cleared after successful submission');

        widget.onSubmitSuccess?.call();

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            debugPrint('👋 Closing bottom sheet');
            Navigator.pop(context);
          }
        });
      } else {
        debugPrint('❌ Submission failed with message: ${result['message']}');
        _showSnackBar(
          result['message'] ?? 'Failed to submit',
          isError: true,
        );
      }
    } catch (e) {
      debugPrint('💥 Exception caught in submitInquiry: $e');
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      _showSnackBar('Error: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    debugPrint('${isError ? "❌" : "✅"} SnackBar: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSuggestionsOverlay(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 200,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: _filteredSuggestions.length,
          itemBuilder: (context, index) {
            final suggestion = _filteredSuggestions[index];
            return ListTile(
              leading: const Icon(Icons.location_on, size: 20, color: Colors.grey),
              title: Text(suggestion),
              onTap: () => _selectSuggestion(suggestion),
              tileColor: Colors.white,
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.sm,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true, // Always show the scroll thumb
      thickness: 6,          // Width of the scrollbar
      radius: const Radius.circular(8), // Rounded edges
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            /// ==================== CATEGORY + SUB-CATEGORY ====================
            if (widget.isFromHomeScreen) ...[
              CategorySubCategoryPicker(
                onCategoryChanged: (name, id) {
                  setState(() {
                    _catName = name;
                    _catId = id;
                  });
                  debugPrint('🏷️ Category Selected: $_catName (ID: $_catId)');
                },
                onSubCategoryChanged: (name, id) {
                  setState(() {
                    _subName = name;
                    _subId = id;
                  });
                  debugPrint('🏷️ Sub-Category Selected: $_subName (ID: $_subId)');
                },
              ),
              const SizedBox(height: AppSizes.md),
            ],

            /// ==================== LOCATION DROPDOWN ====================
            AppCustomContainerField(
              containerChild: DropdownButtonFormField<String>(
                value: _selectedLocation,
                onChanged: _isLocationDisabled
                    ? null
                    : (String? newValue) {
                  setState(() {
                    _selectedLocation = newValue ?? '';
                  });
                  debugPrint('🌍 Region Selected: $_selectedLocation');
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
                    borderSide:
                    BorderSide(color: AppColors.primaryColor, width: 1.8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide:
                    BorderSide(color: AppColors.primaryColor, width: 1.8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide:
                    BorderSide(color: AppColors.primaryColor, width: 2.0),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Colors.grey, width: 1.8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.md),

            /// ==================== ADDRESS FIELD WITH DROPDOWN SUGGESTIONS ====================
            OverlayPortal(
              controller: _overlayController,
              overlayChildBuilder: (BuildContext context) {
                return Positioned(
                  width: MediaQuery.of(context).size.width - 32, // Match padding
                  child: _buildSuggestionsOverlay(context),
                );
              },
              child: CompositedTransformTarget(
                link: _layerLink,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.primaryColor, width: 1.8),
                  ),
                  child: TextFormField(
                    controller: _addressController,
                    focusNode: _addressFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      hintText: 'Enter your address (e.g., Dhaka, Bangladesh)',
                      prefixIcon: const Icon(Icons.location_on, color: AppColors.primaryColor),
                      suffixIcon: _filteredSuggestions.isNotEmpty && _addressFocusNode.hasFocus
                          ? const Icon(Icons.arrow_drop_down, color: AppColors.primaryColor)
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      labelStyle: TextStyle(
                        color: _addressFocusNode.hasFocus
                            ? AppColors.primaryColor
                            : Colors.grey[600],
                      ),
                    ),
                    onTap: () {
                      if (_addressController.text.isNotEmpty) {
                        _filterSuggestions(_addressController.text);
                        _overlayController.show();
                      }
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.md),

            /// ==================== DATE PICKER ====================
            if (widget.isFromHomeScreen) ...[
              GestureDetector(
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      widget._dateTEController.text = _formatDate(pickedDate);
                    });
                    debugPrint('📅 Date Selected: ${widget._dateTEController.text}');
                  }
                },
                child: AbsorbPointer(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.primaryColor, width: 1.8),
                    ),
                    child: TextFormField(
                      controller: widget._dateTEController,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        hintText: 'Select date',
                        prefixIcon: const Icon(Icons.calendar_today, color: AppColors.primaryColor),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        labelStyle: const TextStyle(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
            ],

            /// ==================== ADDITIONAL NOTE ====================
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(18),
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
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  border: InputBorder.none,
                  hintText: "Additional note",
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.xxxL),
            const SizedBox(height: AppSizes.xxxL),
            const SizedBox(height: AppSizes.xxxL),
            const SizedBox(height: AppSizes.xxxL),
            const SizedBox(height: AppSizes.xxxL),

            /// Show loading indicator when submitting
            if (_isSubmitting)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Submitting...'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}