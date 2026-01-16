import 'package:flutter/material.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import '../../../core/common/widgets/time_picker_widget.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/token_service/token_storage_service.dart';

class BookingBottomSheet extends StatefulWidget {
  const BookingBottomSheet({
    super.key,
    required TextEditingController dateTEController,
    required this.timeController,
    required TextEditingController additionalNoteTEController,
    this.onSubmitSuccess,
    this.preSelectedServiceId,
    this.preSelectedDate,
    this.preSelectedTime,
  })  : _dateTEController = dateTEController,
        _additionalNoteTEController = additionalNoteTEController;

  final TextEditingController _dateTEController;
  final TimeController timeController;
  final TextEditingController _additionalNoteTEController;
  final VoidCallback? onSubmitSuccess;
  final String? preSelectedServiceId;
  final DateTime? preSelectedDate;
  final String? preSelectedTime;

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  String? _selectedLocation;
  bool _isSubmitting = false;

  // Scroll controller for smooth scrolling
  final ScrollController _scrollController = ScrollController();

  // Address field (no dropdown suggestions)
  final TextEditingController _addressController = TextEditingController();
  final FocusNode _addressFocusNode = FocusNode();

  // Focus node for additional notes
  final FocusNode _notesFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _selectedLocation = null;

    // Pre-fill the date if provided
    if (widget.preSelectedDate != null) {
      widget._dateTEController.text = _formatDate(widget.preSelectedDate!);
    } else {
      // Set default to today
      widget._dateTEController.text = _formatDate(DateTime.now());
    }

    // Pre-fill time if provided
    if (widget.preSelectedTime != null) {
      widget.timeController.updateSelectedTime(widget.preSelectedTime!);
    }

    // Handle focus changes for address field
    _addressFocusNode.addListener(() {
      if (_addressFocusNode.hasFocus) {
        _scrollToCurrentField();
      }
    });

    // Handle focus changes for notes field
    _notesFocusNode.addListener(() {
      if (_notesFocusNode.hasFocus) {
        _scrollToCurrentField();
      }
    });
  }

  // Scroll to keep focused field visible above keyboard
  void _scrollToCurrentField({double extraPadding = 120.0}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && mounted) {
        final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        final double maxScrollExtent = _scrollController.position.maxScrollExtent;
        final double currentOffset = _scrollController.offset;

        // Scroll to bottom if needed
        if (keyboardHeight > 0 && currentOffset < maxScrollExtent) {
          _scrollController.animateTo(
            maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime date, String time) {
    final List<String> timeParts = time.split(' ');
    final String timeValue = timeParts[0];
    final String period = timeParts.length > 1 ? timeParts[1].toLowerCase() : 'am';

    final List<String> hourMinuteParts = timeValue.split(':');
    int hour = int.parse(hourMinuteParts[0]);
    final int minute = hourMinuteParts.length > 1 ? int.parse(hourMinuteParts[1]) : 0;

    if (period == 'pm' && hour < 12) hour += 12;
    if (period == 'am' && hour == 12) hour = 0;

    final DateTime dateTime = DateTime(date.year, date.month, date.day, hour, minute);
    return dateTime.toIso8601String();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _addressController.dispose();
    _addressFocusNode.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  bool _validateFields() {
    debugPrint('🔍 ========== VALIDATING BOOKING FIELDS ==========');

    if (widget.preSelectedServiceId == null || widget.preSelectedServiceId!.isEmpty) {
      debugPrint('❌ Validation Failed: Service ID is required');
      _showSnackBar('Service ID is required', isError: true);
      return false;
    }

    if (_selectedLocation == null || _selectedLocation!.isEmpty) {
      debugPrint('❌ Validation Failed: Region not selected');
      _showSnackBar('Please select a region', isError: true);
      return false;
    }

    if (_addressController.text.trim().isEmpty) {
      debugPrint('❌ Validation Failed: Address is empty');
      _showSnackBar('Please enter your address', isError: true);
      return false;
    }

    if (widget._dateTEController.text.trim().isEmpty) {
      debugPrint('❌ Validation Failed: Date is empty');
      _showSnackBar('Please select a date', isError: true);
      return false;
    }

    if (widget._additionalNoteTEController.text.trim().isEmpty) {
      debugPrint('❌ Validation Failed: Additional notes are empty');
      _showSnackBar('Please add additional notes', isError: true);
      return false;
    }

    debugPrint('✅ ========== ALL BOOKING FIELDS VALIDATED SUCCESSFULLY ==========');
    return true;
  }

  Future<void> _submitBooking() async {
    FocusScope.of(context).unfocus();

    debugPrint('🎬 ========== SUBMIT BOOKING INITIATED ==========');

    if (!_validateFields()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final SharedPrefService sharedPrefService = SharedPrefService();
      final String? accessToken = await sharedPrefService.getAccessToken();

      final List<String> dateParts = widget._dateTEController.text.trim().split('-');
      final DateTime selectedDate = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );

      final DateTime selectedDateTime = widget.timeController.selectedTime.value;
      final int hour = selectedDateTime.hour;
      final int minute = selectedDateTime.minute;

      final String period = hour >= 12 ? 'PM' : 'AM';
      final int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final String timeString = '$displayHour:${minute.toString().padLeft(2, '0')} $period';

      final String fullLocation = '${_selectedLocation} - ${_addressController.text.trim()}';

      final Map<String, dynamic> result = await _submitBookingToApi(
        serviceId: widget.preSelectedServiceId!,
        selectedDate: selectedDate,
        selectedTime: timeString,
        location: fullLocation,
        description: widget._additionalNoteTEController.text.trim(),
        accessToken: accessToken,
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      if (result['success'] == true) {
        const String successMessage = 'Booking submitted successfully!';
        debugPrint('🎉 $successMessage');
        _showSnackBar(successMessage);

        widget._additionalNoteTEController.clear();
        _addressController.clear();
        setState(() {
          _selectedLocation = null;
        });

        widget.onSubmitSuccess?.call();

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        _showSnackBar(
          result['message'] ?? 'Failed to submit booking',
          isError: true,
        );
      }
    } catch (e) {
      debugPrint('💥 Exception caught in _submitBooking: $e');
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<Map<String, dynamic>> _submitBookingToApi({
    required String serviceId,
    required DateTime selectedDate,
    required String selectedTime,
    required String location,
    required String description,
    String? accessToken,
  }) async {
    try {
      final Map<String, String>? headers = accessToken != null && accessToken.isNotEmpty
          ? <String, String>{'Authorization': 'Bearer $accessToken'}
          : null;

      final String formattedDateTime = _formatDateTime(selectedDate, selectedTime);

      final Map<String, dynamic> body = <String, dynamic>{
        'service': serviceId,
        'description': description,
        'bookingDate': formattedDateTime,
        'location': location.toLowerCase(),
      };

      final NetworkResponse response = await NetworkCaller().postRequest(
        AppUrl.bookingUrl,
        body: body,
        headers: headers,
      );

      if (response.isSuccess) {
        return <String, dynamic>{
          'success': true,
          'data': response.jsonResponse,
        };
      } else {
        return <String, dynamic>{
          'success': false,
          'message': response.errorMessage ?? 'Failed to submit booking',
          'error': response.jsonResponse,
        };
      }
    } catch (e) {
      debugPrint('💥 ========== BOOKING SUBMISSION ERROR ==========');
      return <String, dynamic>{
        'success': false,
        'message': 'Error submitting booking: $e',
      };
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
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Scrollbar(
        thumbVisibility: true,
        thickness: 6,
        radius: const Radius.circular(8),
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              /// ==================== REGION DROPDOWN ====================
              Container(
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.primaryColor, width: 1.8),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedLocation,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLocation = newValue ?? '';
                    });
                  },
                  items: <String>['north', 'south', 'east', 'west']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.toUpperCase()),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    labelStyle: TextStyle(color: AppColors.greyColor),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.md),

              /// ==================== SIMPLE ADDRESS FIELD ====================
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.primaryColor, width: 1.8),
                ),
                child: TextFormField(
                  controller: _addressController,
                  focusNode: _addressFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    hintText: 'Enter your full address',
                    prefixIcon: Icon(Icons.location_on, color: AppColors.primaryColor),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.md),

              /// ==================== DATE PICKER ====================
              GestureDetector(
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: widget.preSelectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      widget._dateTEController.text = _formatDate(pickedDate);
                    });
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
                      decoration: const InputDecoration(
                        hintText: 'Select date',
                        prefixIcon: Icon(Icons.calendar_today, color: AppColors.primaryColor),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        labelStyle: TextStyle(color: AppColors.primaryColor),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.sm),

              /// ==================== TIME PICKER ====================
              SizedBox(
                width: double.infinity,
                child: TimePickerWidget(
                  label: 'Time',
                  controller: widget.timeController,
                  showTimeIcon: true,
                ),
              ),

              const SizedBox(height: AppSizes.sm),

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
                  focusNode: _notesFocusNode,
                  textInputAction: TextInputAction.done,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Additional note",
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),
                ),
              ),

              const SizedBox(height: 120), // Extra space for keyboard
            ],
          ),
        ),
      ),
    );
  }
}
