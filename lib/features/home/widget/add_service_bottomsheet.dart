import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../../../core/common/widgets/time_picker_widget.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../auth/widgets/app_custom_textfield.dart';
import '../../auth/widgets/custom_text_field.dart';
import '../../auth/widgets/reusable_date_picker_field.dart';

/// ===================================================================
/// CONTROLLER: Category and SubCategory Management (Add Service)
/// ===================================================================
class AddServiceCategoryController extends GetxController {
  var isLoadingCategories = false.obs;
  var isLoadingSubCategories = false.obs;
  var isSubmittingService = false.obs;
  var categories = <Map<String, dynamic>>[].obs;
  var subCategories = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  // final String baseUrl = 'https://d7001.sobhoy.com/api/v1';
  final String baseUrl = 'https://5003.dipudebnath.tech/api/v1';

  var selectedCategoryId = ''.obs;
  var selectedCategoryName = ''.obs;
  var selectedSubCategoryId = ''.obs;
  var selectedSubCategoryName = ''.obs;

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('accessToken');
    } catch (e) {
      print('❌ Error retrieving token: $e');
      return null;
    }
  }

  Future<void> fetchCategories() async {
    try {
      isLoadingCategories.value = true;
      errorMessage.value = '';
      categories.clear();

      // Clear subcategories when fetching new categories
      subCategories.clear();
      selectedCategoryId.value = '';
      selectedCategoryName.value = '';
      selectedSubCategoryId.value = '';
      selectedSubCategoryName.value = '';

      final token = await _getAuthToken();
      // if (token == null) {
      //   errorMessage.value = 'Please login again.';
      //   isLoadingCategories.value = false;
      //   return;
      // }

      final url = Uri.parse('$baseUrl/category');
      print('🌐 Fetching categories from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['data']['data'] ?? [];
          categories.value = list.cast<Map<String, dynamic>>();
          print('✅ Loaded ${categories.length} categories');
        } else {
          errorMessage.value = data['message'] ?? 'Failed to fetch categories';
        }
      } else {
        errorMessage.value = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> fetchSubCategories(String categoryId) async {
    try {
      isLoadingSubCategories.value = true;
      subCategories.clear();
      selectedSubCategoryId.value = '';
      selectedSubCategoryName.value = '';

      final token = await _getAuthToken();
      // if (token == null) {
      //   errorMessage.value = 'Please login again.';
      //   isLoadingSubCategories.value = false;
      //   return;
      // }

      final url = Uri.parse('$baseUrl/category/$categoryId/subcategories');
      print('🌐 Fetching sub-categories from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['data']['data'] ?? [];
          subCategories.value = list.cast<Map<String, dynamic>>();
          print('✅ Loaded ${subCategories.length} sub-categories');
        } else {
          errorMessage.value = data['message'] ?? 'Failed to fetch sub-categories';
        }
      } else {
        errorMessage.value = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoadingSubCategories.value = false;
    }
  }

  void selectCategory(String categoryId, String categoryName) {
    selectedCategoryId.value = categoryId;
    selectedCategoryName.value = categoryName;
    // Fetch sub-categories when category is selected
    fetchSubCategories(categoryId);
  }

  void selectSubCategory(String subCategoryId, String subCategoryName) {
    selectedSubCategoryId.value = subCategoryId;
    selectedSubCategoryName.value = subCategoryName;
  }

  void clearSelection() {
    selectedCategoryId.value = '';
    selectedCategoryName.value = '';
    selectedSubCategoryId.value = '';
    selectedSubCategoryName.value = '';
    subCategories.clear();
  }

  /// 🚀 POST API: Submit service to API with multipart/form-data
  /// API Endpoint: POST https://d7001.sobhoy.com/api/v1/service
  Future<bool> submitService({
    required String serviceName,
    required String description,
    required String startDate,
    required File? imageFile,
  }) async {
    try {
      isSubmittingService.value = true;
      errorMessage.value = '';

      print('📤 Starting service submission...');

      // Validate required fields
      if (selectedSubCategoryId.value.isEmpty) {
        throw Exception('Please select a sub-category');
      }

      if (serviceName.isEmpty) {
        throw Exception('Please enter service name');
      }

      if (imageFile == null) {
        throw Exception('Please select an image');
      }

      final token = await _getAuthToken();
      // if (token == null) {
      //   throw Exception('Please login again');
      // }

      // 🌐 POST API ENDPOINT
      final url = Uri.parse('$baseUrl/service');
      print('🌐 POST API URL: $url');

      // Create multipart request
      var request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      print('✅ Authorization header added');

      // Add form fields
      request.fields['subCategory'] = selectedSubCategoryId.value;
      request.fields['name'] = serviceName;
      request.fields['description'] = description.isNotEmpty ? description : serviceName;
      request.fields['startDate'] = startDate;

      print('✅ Form fields added:');
      print('   - subCategory: ${selectedSubCategoryId.value}');
      print('   - name: $serviceName');
      print('   - description: ${description.isNotEmpty ? description : serviceName}');
      print('   - startDate: $startDate');

      // Validate and add image file with proper MIME type
      final mimeType = _getMimeType(imageFile);
      if (mimeType == null) {
        throw Exception('Invalid image format. Please select JPEG, PNG, GIF, WebP, or BMP');
      }

      print('📎 Uploading image: ${imageFile.path}');
      print('📎 MIME Type: $mimeType');

      final imageStream = http.ByteStream(imageFile.openRead());
      final imageLength = await imageFile.length();

      final multipartFile = http.MultipartFile(
        'image',
        imageStream,
        imageLength,
        filename: imageFile.path.split('/').last,
        contentType: MediaType.parse(mimeType),
      );

      request.files.add(multipartFile);
      print('✅ Image file added to request');

      // Send request
      print('🚀 Sending POST request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ Service created successfully!');
          print('✅ Service ID: ${data['data']['_id']}');

          Get.snackbar(
            'Success',
            'Service added successfully!',
            backgroundColor: Colors.green[100],
            colorText: Colors.green[900],
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );

          return true;
        } else {
          throw Exception(data['message'] ?? 'Failed to create service');
        }
      } else {
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['message'] ?? 'Server Error: ${response.statusCode}');
        } catch (e) {
          throw Exception('Server Error: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('❌ Error submitting service: $e');
      errorMessage.value = e.toString();

      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );

      return false;
    } finally {
      isSubmittingService.value = false;
    }
  }

  /// Get MIME type from file
  String? _getMimeType(File file) {
    try {
      final path = file.path.toLowerCase();
      final mimeType = lookupMimeType(path);

      // Validate against allowed types
      const allowedMimeTypes = [
        'image/jpeg',
        'image/jpg',
        'image/png',
        'image/gif',
        'image/webp',
        'image/bmp',
      ];

      if (mimeType != null && allowedMimeTypes.contains(mimeType)) {
        return mimeType;
      }

      return null;
    } catch (e) {
      print('❌ Error getting MIME type: $e');
      return null;
    }
  }

  @override
  void onClose() {
    clearSelection();
    super.onClose();
  }
}

/// ===================================================================
/// WIDGET: Custom Dropdown Field
/// ===================================================================
class CustomDropdownField extends StatelessWidget {
  final String hintText;
  final List<Map<String, dynamic>> items;
  final bool isLoading;
  final String? selectedValue;
  final Function(String, String) onChanged;
  final String? errorText;

  const CustomDropdownField({
    super.key,
    required this.hintText,
    required this.items,
    required this.isLoading,
    required this.selectedValue,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryColor, width: 2),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: DropdownButtonFormField<String>(
          value: selectedValue?.isEmpty ?? true ? null : selectedValue,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            errorText: errorText,
          ),
          items: [
            // Default hint item
            DropdownMenuItem<String>(
              value: null,
              enabled: false,
              child: Text(
                hintText,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            // Dynamic items from API
            ...items.map((item) {
              return DropdownMenuItem<String>(
                value: item['_id'],
                child: Text(item['name'] ?? 'Unknown'),
              );
            }).toList(),
          ],
          onChanged: (String? newValue) {
            if (newValue != null) {
              final selectedItem = items.firstWhere(
                    (item) => item['_id'] == newValue,
                orElse: () => {},
              );
              if (selectedItem.isNotEmpty) {
                onChanged(newValue, selectedItem['name'] ?? 'Unknown');
              }
            }
          },
          icon: isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryColor,
            ),
          )
              : const Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
          isExpanded: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select $hintText';
            }
            return null;
          },
        ),
      ),
    );
  }
}

/// ===================================================================
/// ENHANCED IMAGE PICKER WIDGET WITH MIME TYPE VALIDATION
/// ===================================================================
class EnhancedImagePickerWidget extends StatefulWidget {
  final Function(File) onImageSelected;
  final Function(String)? onError;

  const EnhancedImagePickerWidget({
    super.key,
    required this.onImageSelected,
    this.onError,
  });

  @override
  State<EnhancedImagePickerWidget> createState() => _EnhancedImagePickerWidgetState();
}

class _EnhancedImagePickerWidgetState extends State<EnhancedImagePickerWidget> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;

  // Allowed MIME types for images
  static const List<String> _allowedMimeTypes = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/gif',
    'image/webp',
    'image/bmp',
  ];

  // Allowed file extensions
  static const List<String> _allowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'bmp',
  ];

  /// Validates the MIME type of the selected file
  bool _isValidMimeType(File file) {
    try {
      final path = file.path.toLowerCase();
      final mimeType = lookupMimeType(path);

      // Check MIME type
      if (mimeType != null && _allowedMimeTypes.contains(mimeType)) {
        return true;
      }

      // Fallback to extension check
      final extension = path.split('.').last;
      if (_allowedExtensions.contains(extension)) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Shows image source selection dialog
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: const Text('Choose how you want to select an image'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
              child: const Text('Gallery'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
              child: const Text('Camera'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  /// Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        await _handleSelectedImage(File(pickedFile.path));
      }
    } catch (e) {
      _handleError('Failed to pick image from gallery: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Pick image from camera
  Future<void> _pickImageFromCamera() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        await _handleSelectedImage(File(pickedFile.path));
      }
    } catch (e) {
      _handleError('Failed to capture image from camera: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Handle the selected image with validation
  Future<void> _handleSelectedImage(File imageFile) async {
    try {
      // Check if file exists and has valid size
      final stat = await imageFile.stat();
      if (stat.size == 0) {
        _handleError('Selected file is empty');
        return;
      }

      // Check file size (max 10MB)
      const maxSize = 10 * 1024 * 1024; // 10MB in bytes
      if (stat.size > maxSize) {
        _handleError('Image size too large. Maximum allowed is 10MB');
        return;
      }

      // Validate MIME type
      if (!_isValidMimeType(imageFile)) {
        _handleError('Invalid image format. Please select JPEG, PNG, GIF, WebP, or BMP');
        return;
      }

      // Image is valid, proceed
      setState(() {
        _selectedImage = imageFile;
      });

      widget.onImageSelected(imageFile);

      Get.snackbar(
        'Success',
        'Image selected successfully!',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      _handleError('Error processing image: $e');
    }
  }

  /// Handle errors
  void _handleError(String error) {
    print('❌ Image Picker Error: $error');
    widget.onError?.call(error);

    Get.snackbar(
      'Error',
      error,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[900],
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  /// Remove selected image
  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image picker button
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primaryColor, width: 2),
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
          ),
          child: _isLoading
              ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            ),
          )
              : InkWell(
            onTap: _showImageSourceDialog,
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Select Image',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Selected image preview
        if (_selectedImage != null)
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 1),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                  color: Colors.green[50],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700], size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Image Selected',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: _removeImage,
                          child: Icon(Icons.close, color: Colors.red[700], size: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedImage!.path.split('/').last,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Image preview
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                        image: DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Supported formats: JPEG, PNG, GIF, WebP, BMP (Max 10MB)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// ===================================================================
/// WIDGET: Add Service Bottom Sheet
/// ===================================================================
class AddServiceBottomSheet extends StatefulWidget {
  const AddServiceBottomSheet({
    super.key,
    required TextEditingController serviceNameTEController,
    required TextEditingController dateTEController,
    required TextEditingController typeTEController,
    required this.timeController,
    required TextEditingController locationTEController,
    required TextEditingController additionalNoteTEController,
    this.formKey,
    this.onSubmit,
    this.onButtonPressed,
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
  final GlobalKey<FormState>? formKey;
  final VoidCallback? onSubmit;
  final Future<void> Function()? onButtonPressed;

  @override
  State<AddServiceBottomSheet> createState() => AddServiceBottomSheetState();
}

class AddServiceBottomSheetState extends State<AddServiceBottomSheet> {
  late final AddServiceCategoryController categoryController;
  late final GlobalKey<FormState> _formKey;
  File? _selectedImage;
  final String _controllerTag = 'add_service_${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    _formKey = widget.formKey ?? GlobalKey<FormState>();

    // Use a unique tag for this controller instance
    categoryController = Get.put(
      AddServiceCategoryController(),
      tag: _controllerTag,
    );

    // Fetch categories when bottom sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      categoryController.fetchCategories();
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
    Get.delete<AddServiceCategoryController>(tag: _controllerTag);
    super.dispose();
  }

  /// 🚀 This is the main submit function that calls the POST API
  Future<void> submitForm() async {
    print('🔥 Submit button pressed!');

    if (_formKey.currentState?.validate() ?? false) {
      // Additional validation for image
      if (_selectedImage == null) {
        Get.snackbar(
          'Validation Error',
          'Please select an image for the service',
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[900],
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Format the date to ISO 8601 format
      String formattedDate;
      try {
        final dateText = widget._dateTEController.text.trim();
        if (dateText.isEmpty) {
          formattedDate = DateTime.now().toIso8601String();
        } else {
          DateTime parsedDate;
          if (dateText.contains('/')) {
            final parts = dateText.split('/');
            if (parts.length == 3) {
              parsedDate = DateTime(
                int.parse(parts[2]), // year
                int.parse(parts[1]), // month
                int.parse(parts[0]), // day
              );
            } else {
              parsedDate = DateTime.now();
            }
          } else {
            parsedDate = DateTime.tryParse(dateText) ?? DateTime.now();
          }
          formattedDate = parsedDate.toIso8601String();
        }
      } catch (e) {
        print('❌ Date parsing error: $e');
        formattedDate = DateTime.now().toIso8601String();
      }

      print('✅ Form validated successfully');
      print('📤 Calling POST API with data:');
      print('   Service Name: ${widget._serviceNameTEController.text}');
      print('   SubCategory ID: ${categoryController.selectedSubCategoryId.value}');
      print('   Date: $formattedDate');
      print('   Description: ${widget._additionalNoteTEController.text}');
      print('   Image: ${_selectedImage?.path}');

      // 🚀🚀🚀 CALLING THE POST API HERE 🚀🚀🚀
      final success = await categoryController.submitService(
        serviceName: widget._serviceNameTEController.text.trim(),
        description: widget._additionalNoteTEController.text.trim(),
        startDate: formattedDate,
        imageFile: _selectedImage,
      );

      if (success) {
        print('✅ API call successful!');

        // Call the onSubmit callback if provided
        widget.onSubmit?.call();

        // Close the bottom sheet
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        print('❌ API call failed!');
      }
    } else {
      print('❌ Form validation failed');
      Get.snackbar(
        'Validation Error',
        'Please fill in all required fields',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show loading overlay when submitting
      if (categoryController.isSubmittingService.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Submitting your service...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }

      return Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Service Name Field
            AppCustomContainerField(
              containerChild: MyTextFormFieldWithIcon(
                formHintText: "Service Name",
                controller: widget._serviceNameTEController,
                validator: (String? value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter service name';
                  }
                  return null;
                },
                onChanged: (String value) {},
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Category Dropdown
            Obx(() => CustomDropdownField(
              hintText: "Select Category",
              items: categoryController.categories,
              isLoading: categoryController.isLoadingCategories.value,
              selectedValue: categoryController.selectedCategoryId.value,
              onChanged: (String categoryId, String categoryName) {
                categoryController.selectCategory(categoryId, categoryName);
              },
              errorText: categoryController.errorMessage.value.isEmpty
                  ? null
                  : categoryController.errorMessage.value,
            )),
            const SizedBox(height: AppSizes.md),

            // Sub-Category Dropdown
            Obx(() => CustomDropdownField(
              hintText: "Select Sub-Category",
              items: categoryController.subCategories,
              isLoading: categoryController.isLoadingSubCategories.value,
              selectedValue: categoryController.selectedSubCategoryId.value,
              onChanged: (String subCategoryId, String subCategoryName) {
                categoryController.selectSubCategory(subCategoryId, subCategoryName);
              },
              errorText: categoryController.selectedCategoryId.value.isNotEmpty &&
                  categoryController.subCategories.isEmpty &&
                  !categoryController.isLoadingSubCategories.value
                  ? 'No sub-categories available'
                  : null,
            )),
            const SizedBox(height: AppSizes.md),

            // Date Picker
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryColor, width: 2),
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
              ),
              child: ReusableDatePickerField(
                controller: widget._dateTEController,
                hintText: 'Select the Date',
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Additional Notes
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
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  hintText: "Additional note (Description)",
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                validator: (value) {
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Enhanced Image Picker with MIME type validation
            EnhancedImagePickerWidget(
              onImageSelected: (File file) {
                setState(() {
                  _selectedImage = file;
                });
                print('✅ Image selected: ${file.path}');
              },
              onError: (String error) {
                print('❌ Image selection error: $error');
              },
            ),

            // Selected Values Display
            Obx(() => categoryController.selectedCategoryId.value.isNotEmpty ||
                categoryController.selectedSubCategoryId.value.isNotEmpty
                ? Column(
              children: [
                const SizedBox(height: AppSizes.md),
                Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (categoryController.selectedCategoryId.value.isNotEmpty)
                        Text(
                          'Selected Category: ${categoryController.selectedCategoryName.value}',
                          style: const TextStyle(fontSize: 12, color: Colors.green),
                        ),
                      if (categoryController.selectedSubCategoryId.value.isNotEmpty)
                        Text(
                          'Selected Sub-Category: ${categoryController.selectedSubCategoryName.value}',
                          style: const TextStyle(fontSize: 12, color: Colors.green),
                        ),
                    ],
                  ),
                ),
              ],
            )
                : const SizedBox.shrink()),
          ],
        ),
      );
    });
  }
}