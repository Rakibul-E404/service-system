/**

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
  static const String baseUrl = AppUrl.searchQuoteUrl;

  static Future<Map<String, dynamic>> submitInquiry({
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
          'message': 'Failed to submit inquiry: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      return {
        'success': false,
        'message': 'Error submitting inquiry: $e',
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

  // Validation method
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

  // Public method that can be called from outside
  Future<void> submitInquiry() async {
    if (!_validateFields()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      debugPrint('🚀 Starting API submission...');
      debugPrint('📌 Service Category ID: $_subId');
      debugPrint('📌 Location: $_selectedLocation');
      debugPrint('📌 Additional Note: ${widget._additionalNoteTEController.text.trim()}');

      // Get access token from SharedPreferences
      final sharedPrefService = SharedPrefService();
      final accessToken = await sharedPrefService.getAccessToken();

      debugPrint('🔑 Retrieved access token: ${accessToken != null ? "Yes" : "No"}');

      final result = await InquiryService.submitInquiry(
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
        _showSnackBar('Inquiry submitted successfully!');

        // Clear fields after success
        widget._additionalNoteTEController.clear();
        setState(() {
          _selectedLocation = null;
          _subId = null;
          _subName = null;
          _catId = null;
          _catName = null;
        });

        // Call success callback if provided
        widget.onSubmitSuccess?.call();

        // Close bottom sheet after short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        _showSnackBar(
          result['message'] ?? 'Failed to submit inquiry',
          isError: true,
        );
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

          /// Show loading indicator when submitting
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


*/








///
///
///
///
/// todo:: updating the page navigation
///
///
///
///




// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:manx_mate/core/utils/api/app_url.dart';
// import '../../../core/common/widgets/time_picker_widget.dart';
// import '../../../core/config/app_colors.dart';
// import '../../../core/config/app_sizes.dart';
// import '../../../core/utils/token_service/token_storage_service.dart';
// import '../../auth/widgets/app_custom_textfield.dart';
// import 'category_subCategory_picker.dart';
//
// class InquiryService {
//   static const String baseUrl = AppUrl.searchQuoteUrl;
//
//   static Future<Map<String, dynamic>> submitInquiry({
//     required String serviceCategory,
//     required String location,
//     required String additional,
//     String? accessToken,
//   }) async {
//     try {
//       // Prepare headers
//       final headers = <String, String>{
//         'Content-Type': 'application/json',
//       };
//
//       // Add authorization header if token exists
//       if (accessToken != null && accessToken.isNotEmpty) {
//         headers['Authorization'] = 'Bearer $accessToken';
//         debugPrint('🔑 Authorization header added');
//       } else {
//         debugPrint('⚠️ No access token available');
//       }
//
//       final response = await http.post(
//         Uri.parse(baseUrl),
//         headers: headers,
//         body: jsonEncode({
//           'serviceCategory': serviceCategory,
//           'location': location.toLowerCase(), // Ensure lowercase
//           'additional': additional,
//         }),
//       );
//
//       debugPrint('📤 API Request: $baseUrl');
//       debugPrint('📝 Body: ${jsonEncode({
//         'serviceCategory': serviceCategory,
//         'location': location.toLowerCase(),
//         'additional': additional,
//       })}');
//       debugPrint('📥 Response Status: ${response.statusCode}');
//       debugPrint('📥 Response Body: ${response.body}');
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return {
//           'success': true,
//           'data': jsonDecode(response.body),
//         };
//       } else {
//         return {
//           'success': false,
//           'message': 'Failed to submit inquiry: ${response.statusCode}',
//           'error': response.body,
//         };
//       }
//     } catch (e) {
//       debugPrint('❌ Error: $e');
//       return {
//         'success': false,
//         'message': 'Error submitting inquiry: $e',
//       };
//     }
//   }
// }
//
// class InquiryBottomSheet extends StatefulWidget {
//   const InquiryBottomSheet({
//     super.key,
//     required TextEditingController serviceNameTEController,
//     required TextEditingController dateTEController,
//     required this.timeController,
//     required TextEditingController locationTEController,
//     required TextEditingController additionalNoteTEController,
//     this.onSubmitSuccess,
//     this.isFromHomeScreen = false, // New parameter to detect navigation source
//   })  : _serviceNameTEController = serviceNameTEController,
//         _dateTEController = dateTEController,
//         _locationTEController = locationTEController,
//         _additionalNoteTEController = additionalNoteTEController;
//
//   final TextEditingController _serviceNameTEController;
//   final TextEditingController _dateTEController;
//   final TimeController timeController;
//   final TextEditingController _locationTEController;
//   final TextEditingController _additionalNoteTEController;
//   final VoidCallback? onSubmitSuccess;
//   final bool isFromHomeScreen; // Flag to check if coming from HomeScreen
//
//   @override
//   State<InquiryBottomSheet> createState() => InquiryBottomSheetState();
// }
//
// class InquiryBottomSheetState extends State<InquiryBottomSheet> {
//   String? _catName;
//   String? _catId;
//   String? _subName;
//   String? _subId;
//
//   bool _isLocationDisabled = false;
//   String? _selectedLocation;
//   bool _isSubmitting = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedLocation = null;
//   }
//
//   @override
//   void dispose() {
//     widget._locationTEController.clear();
//     widget._additionalNoteTEController.clear();
//     super.dispose();
//   }
//
//   // Validation method
//   bool _validateFields() {
//     // Only validate category/sub-category if coming from HomeScreen
//     if (widget.isFromHomeScreen && (_subId == null || _subId!.isEmpty)) {
//       _showSnackBar('Please select a service category', isError: true);
//       return false;
//     }
//     if (_selectedLocation == null || _selectedLocation!.isEmpty) {
//       _showSnackBar('Please select a location', isError: true);
//       return false;
//     }
//     if (widget._additionalNoteTEController.text.trim().isEmpty) {
//       _showSnackBar('Please add additional notes', isError: true);
//       return false;
//     }
//     return true;
//   }
//
//   // Public method that can be called from outside (by the Send button)
//   Future<void> submitInquiry() async {
//     if (!_validateFields()) return;
//
//     setState(() {
//       _isSubmitting = true;
//     });
//
//     try {
//       debugPrint('🚀 Starting API submission...');
//       debugPrint('📌 Service Category ID: $_subId');
//       debugPrint('📌 Location: $_selectedLocation');
//       debugPrint('📌 Additional Note: ${widget._additionalNoteTEController.text.trim()}');
//
//       // Get access token from SharedPreferences
//       final sharedPrefService = SharedPrefService();
//       final accessToken = await sharedPrefService.getAccessToken();
//
//       debugPrint('🔑 Retrieved access token: ${accessToken != null ? "Yes" : "No"}');
//
//       final result = await InquiryService.submitInquiry(
//         serviceCategory: _subId!,
//         location: _selectedLocation!,
//         additional: widget._additionalNoteTEController.text.trim(),
//         accessToken: accessToken,
//       );
//
//       if (!mounted) return;
//
//       setState(() {
//         _isSubmitting = false;
//       });
//
//       if (result['success'] == true) {
//         _showSnackBar('Inquiry submitted successfully!');
//
//         // Clear fields after success
//         widget._additionalNoteTEController.clear();
//         setState(() {
//           _selectedLocation = null;
//           _subId = null;
//           _subName = null;
//           _catId = null;
//           _catName = null;
//         });
//
//         // Call success callback if provided
//         widget.onSubmitSuccess?.call();
//
//         // Close bottom sheet after short delay
//         Future.delayed(const Duration(seconds: 1), () {
//           if (mounted) {
//             Navigator.pop(context);
//           }
//         });
//       } else {
//         _showSnackBar(
//           result['message'] ?? 'Failed to submit inquiry',
//           isError: true,
//         );
//       }
//     } catch (e) {
//       debugPrint('❌ Exception during submission: $e');
//       if (!mounted) return;
//       setState(() {
//         _isSubmitting = false;
//       });
//       _showSnackBar('Error: $e', isError: true);
//     }
//   }
//
//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//           /// ==================== CATEGORY + SUB-CATEGORY ====================
//           // Only show category selection if navigating from HomeScreen
//           if (widget.isFromHomeScreen) ...[
//             CategorySubCategoryPicker(
//               onCategoryChanged: (name, id) {
//                 setState(() {
//                   _catName = name;
//                   _catId = id;
//                 });
//               },
//               onSubCategoryChanged: (name, id) {
//                 setState(() {
//                   _subName = name;
//                   _subId = id;
//                 });
//               },
//             ),
//             const SizedBox(height: AppSizes.md),
//           ],
//
//           /// ==================== LOCATION (Dropdown) ====================
//           AppCustomContainerField(
//             containerChild: DropdownButtonFormField<String>(
//               value: _selectedLocation,
//               onChanged: _isLocationDisabled
//                   ? null
//                   : (String? newValue) {
//                 setState(() {
//                   _selectedLocation = newValue ?? '';
//                   widget._locationTEController.text = newValue ?? '';
//                 });
//               },
//               items: ['north', 'south', 'east', 'west']
//                   .map<DropdownMenuItem<String>>((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//               decoration: InputDecoration(
//                 labelText: 'Location',
//                 labelStyle: TextStyle(color: AppColors.primaryColor),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(18),
//                   borderSide:
//                   BorderSide(color: AppColors.primaryColor, width: 1.8),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(18),
//                   borderSide:
//                   BorderSide(color: AppColors.primaryColor, width: 1.8),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(18),
//                   borderSide:
//                   BorderSide(color: AppColors.primaryColor, width: 2.0),
//                 ),
//                 disabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(18),
//                   borderSide: const BorderSide(color: Colors.grey, width: 1.8),
//                 ),
//               ),
//             ),
//           ),
//
//           const SizedBox(height: AppSizes.md),
//
//           /// ==================== ADDITIONAL NOTE ====================
//           Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: AppColors.whiteColor,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: AppColors.primaryColor, width: 1.8),
//             ),
//             child: TextFormField(
//               controller: widget._additionalNoteTEController,
//               textInputAction: TextInputAction.done,
//               maxLines: 5,
//               decoration: InputDecoration(
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(18),
//                   borderSide: const BorderSide(color: Colors.transparent),
//                 ),
//                 hintText: "Additional note",
//                 contentPadding:
//                 const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//               ),
//             ),
//           ),
//
//           const SizedBox(height: AppSizes.md),
//
//           /// Show loading indicator when submitting (will be shown when Send button is pressed)
//           if (_isSubmitting)
//             const Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 8),
//                   Text('Submitting inquiry...'),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }













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
  static const String baseUrl = AppUrl.searchQuoteUrl;
  static const String bookingUrl = AppUrl.bookingUrl; // Add booking URL

  static Future<Map<String, dynamic>> submitInquiry({
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
          'message': 'Failed to submit inquiry: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      return {
        'success': false,
        'message': 'Error submitting inquiry: $e',
      };
    }
  }

  // New method for booking API
  static Future<Map<String, dynamic>> submitBooking({
    required String service,
    required String description,
    required String bookingDate,
    required String location,
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
        debugPrint('🔑 Authorization header added for booking');
      } else {
        debugPrint('⚠️ No access token available for booking');
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

      debugPrint('📤 Booking API Request: $bookingUrl');
      debugPrint('📝 Booking Body: ${jsonEncode({
        'service': service,
        'description': description,
        'bookingDate': bookingDate,
        'location': location.toLowerCase(),
      })}');
      debugPrint('📥 Booking Response Status: ${response.statusCode}');
      debugPrint('📥 Booking Response Body: ${response.body}');

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
      debugPrint('❌ Booking Error: $e');
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
    this.preSelectedServiceId, // Pre-selected service ID
    this.preSelectedDate, // Pre-selected date
    this.preSelectedTime, // Pre-selected time
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
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime date, String time) {
    // Convert time string to 24-hour format and create ISO string
    final timeParts = time.replaceAll(RegExp(r'[apm]'), '').split(':');
    int hour = int.parse(timeParts[0]);
    final int minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;

    // Adjust for PM
    if (time.toLowerCase().contains('pm') && hour < 12) hour += 12;
    if (time.toLowerCase().contains('am') && hour == 12) hour = 0;

    final DateTime dateTime = DateTime(date.year, date.month, date.day, hour, minute);
    return dateTime.toIso8601String();
  }

  @override
  void dispose() {
    widget._locationTEController.clear();
    widget._additionalNoteTEController.clear();
    super.dispose();
  }

  // Validation method
  bool _validateFields() {
    // Only validate category/sub-category if coming from HomeScreen
    if (widget.isFromHomeScreen && (_subId == null || _subId!.isEmpty)) {
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
    // Validate service ID if not from HomeScreen
    if (!widget.isFromHomeScreen && widget.preSelectedServiceId == null) {
      _showSnackBar('Service ID is required', isError: true);
      return false;
    }
    return true;
  }

  // Public method that can be called from outside (by the Send button)
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
      debugPrint('🚀 Starting submission...');
      debugPrint('📌 Is From HomeScreen: ${widget.isFromHomeScreen}');

      // Get access token from SharedPreferences
      final sharedPrefService = SharedPrefService();
      final accessToken = await sharedPrefService.getAccessToken();

      debugPrint('🔑 Retrieved access token: ${accessToken != null ? "Yes" : "No"}');

      Map<String, dynamic> result;

      if (widget.isFromHomeScreen) {
        // Use inquiry API for HomeScreen
        debugPrint('📌 Service Category ID: $_subId');
        debugPrint('📌 Location: $_selectedLocation');
        debugPrint('📌 Additional Note: ${widget._additionalNoteTEController.text.trim()}');

        result = await InquiryService.submitInquiry(
          serviceCategory: _subId!,
          location: _selectedLocation!,
          additional: widget._additionalNoteTEController.text.trim(),
          accessToken: accessToken,
        );
      } else {
        // Use booking API for non-HomeScreen
        final String finalServiceId = serviceId ?? widget.preSelectedServiceId!;
        final DateTime finalDate = selectedDate ?? widget.preSelectedDate!;
        final String finalTime = selectedTime ?? widget.preSelectedTime ?? '10:00';
        final String formattedDateTime = _formatDateTime(finalDate, finalTime);

        debugPrint('📌 Service ID: $finalServiceId');
        debugPrint('📌 Location: $_selectedLocation');
        debugPrint('📌 Description: ${widget._additionalNoteTEController.text.trim()}');
        debugPrint('📌 Booking Date: $formattedDateTime');

        result = await InquiryService.submitBooking(
          service: finalServiceId,
          description: widget._additionalNoteTEController.text.trim(),
          bookingDate: formattedDateTime,
          location: _selectedLocation!,
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
        setState(() {
          _selectedLocation = null;
          _subId = null;
          _subName = null;
          _catId = null;
          _catName = null;
        });

        // Call success callback if provided
        widget.onSubmitSuccess?.call();

        // Close bottom sheet after short delay
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
          /// ==================== CATEGORY + SUB-CATEGORY ====================
          // Only show category selection if navigating from HomeScreen
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

          /// Show loading indicator when submitting (will be shown when Send button is pressed)
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