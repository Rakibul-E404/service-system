
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import '../../../core/common/widgets/time_picker_widget.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/utils/token_service/token_storage_service.dart';
import '../../auth/widgets/app_custom_textfield.dart';
import 'category_subCategory_picker.dart';

class InquiryService {
  static const String baseUrl = AppUrl.postInquiryQuote;
  static const String bookingUrl = AppUrl.bookingUrl;

  static Future<Map<String, dynamic>> submitInquiry({
    required String serviceCategory,
    required String location,
    required String additional,
    String? accessToken,
  }) async {
    try {
      final Map<String, String> headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final http.Response response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode({
          'serviceCategory': serviceCategory,
          'location': location.toLowerCase(),
          'additional': additional,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to submit inquiry: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
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
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await http.post(
        Uri.parse(bookingUrl),
        headers: headers,
        body: jsonEncode({
          'service': service,
          'description': description,
          'bookingDate': bookingDate,
          'location': location.toLowerCase(),
        }),
      );

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
    if (widget.isFromHomeScreen && (_subId == null || _subId!.isEmpty)) {
      _showSnackBar('Please select a service category', isError: true);
      return false;
    }
    if (_selectedLocation == null || _selectedLocation!.isEmpty) {
      _showSnackBar('Please select a location', isError: true);
      return false;
    }
    if (_addressController.text.trim().isEmpty) {
      _showSnackBar('Please enter your address', isError: true);
      return false;
    }
    if (widget._additionalNoteTEController.text.trim().isEmpty) {
      _showSnackBar('Please add additional notes', isError: true);
      return false;
    }
    if (!widget.isFromHomeScreen && widget.preSelectedServiceId == null) {
      _showSnackBar('Service ID is required', isError: true);
      return false;
    }
    return true;
  }

  Future<void> submitInquiry({
    String? serviceId,
    DateTime? selectedDate,
    String? selectedTime,
  }) async {
    if (!_validateFields()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final sharedPrefService = SharedPrefService();
      final accessToken = await sharedPrefService.getAccessToken();

      Map<String, dynamic> result;

      if (widget.isFromHomeScreen) {
        // Combine location and address
        final fullLocation = '${_selectedLocation} - ${_addressController.text.trim()}';

        result = await InquiryService.submitInquiry(
          serviceCategory: _subId!,
          location: fullLocation,
          additional: widget._additionalNoteTEController.text.trim(),
          accessToken: accessToken,
        );
      } else {
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

      if (result['success'] == true) {
        final successMessage = widget.isFromHomeScreen
            ? 'Inquiry submitted successfully!'
            : 'Booking submitted successfully!';

        _showSnackBar(successMessage);

        // Clear fields after success
        widget._additionalNoteTEController.clear();
        _addressController.clear();
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
        _showSnackBar(
          result['message'] ?? 'Failed to submit',
          isError: true,
        );
      }
    } catch (e) {
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
    return SingleChildScrollView(
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
              },
              onSubCategoryChanged: (name, id) {
                setState(() {
                  _subName = name;
                  _subId = id;
                });
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

          const SizedBox(height: AppSizes.md),

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
    );
  }
}







