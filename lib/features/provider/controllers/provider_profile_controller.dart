import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

 // Profile Controller
class ProviderProfileController extends GetxController {
  RxBool isEditing = false.obs;
  Rx<File?> selectedImage = Rx<File?>(null);

  // Business information
  RxString businessName = 'Add a business name'.obs;
  RxString category = 'Add a business category'.obs;
  RxString subCategory = 'Add a business sub-category'.obs;
  RxString location = 'Add a business location (State/Province/County)'.obs;
  RxString advertising = 'Add a business advertising'.obs;
  RxString contactDetails = 'Add a business contact details'.obs;

  // Text controllers for editing
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController subCategoryController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController advertisingController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  // Image picker instance
  // final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
  }

  @override
  void onClose() {
    nameController.dispose();
    categoryController.dispose();
    subCategoryController.dispose();
    locationController.dispose();
    advertisingController.dispose();
    contactController.dispose();
    super.onClose();
  }

  void _initializeControllers() {
    nameController.text = businessName.value == 'Add a business name' ? '' : businessName.value;
    categoryController.text = category.value == 'Add a business category' ? '' : category.value;
    subCategoryController.text = subCategory.value == 'Add a business sub-category'
        ? ''
        : subCategory.value;
    locationController.text = location.value == 'Add a business location (State/Province/County)'
        ? ''
        : location.value;
    advertisingController.text = advertising.value == 'Add a business advertising'
        ? ''
        : advertising.value;
    contactController.text = contactDetails.value == 'Add a business contact details'
        ? ''
        : contactDetails.value;
  }

  // Image Picker Methods
  Future<void> pickImageFromGallery() async {
    try {
      // Simulated image picker for demo - Replace with actual ImagePicker
      final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImage.value = File(image.path);
      }

      // Demo implementation
      Get.snackbar(
        'Gallery',
        'Image selected from gallery (Demo)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image from gallery',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      // Simulated image picker for demo - Replace with actual ImagePicker
      final XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image != null) {
        selectedImage.value = File(image.path);
      }

      // Demo implementation
      Get.snackbar(
        'Camera',
        'Photo taken from camera (Demo)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take photo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void showImagePickerDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Select Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildImagePickerOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: pickImageFromGallery,
                ),
                _buildImagePickerOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: pickImageFromCamera,
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Get.back();
        onTap();
      },
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
            child: Icon(icon, size: 30, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void removeImage() {
    selectedImage.value = null;
    Get.snackbar(
      'Image Removed',
      'Business image has been removed',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void toggleEdit() {
    if (isEditing.value) {
      // Save changes
      businessName.value = nameController.text.isEmpty
          ? 'Add a business name'
          : nameController.text;
      category.value = categoryController.text.isEmpty
          ? 'Add a business category'
          : categoryController.text;
      subCategory.value = subCategoryController.text.isEmpty
          ? 'Add a business sub-category'
          : subCategoryController.text;
      location.value = locationController.text.isEmpty
          ? 'Add a business location (State/Province/County)'
          : locationController.text;
      advertising.value = advertisingController.text.isEmpty
          ? 'Add a business advertising'
          : advertisingController.text;
      contactDetails.value = contactController.text.isEmpty
          ? 'Add a business contact details'
          : contactController.text;

      Get.snackbar(
        'Profile Updated',
        'Your business information has been saved',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      // Enter edit mode
      _initializeControllers();
    }
    isEditing.toggle();
  }

  void cancelEdit() {
    _initializeControllers();
    isEditing.value = false;
  }
}