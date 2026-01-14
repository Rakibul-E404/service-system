

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:manx_mate/core/config/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/provider_profile_controller.dart';

class EditBusinessProfileScreen extends StatefulWidget {
  const EditBusinessProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditBusinessProfileScreen> createState() => _EditBusinessProfileScreenState();
}

class _EditBusinessProfileScreenState extends State<EditBusinessProfileScreen> {
  // Access the controller directly
  final profileCtrl = Get.find<ProviderProfileController>();

  // Local Controllers
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController; // Exact Location
  late TextEditingController _locationController; // General Region
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();

    // Initialize with current values from the Controller
    _nameController = TextEditingController(text: profileCtrl.businessName.value);
    _bioController = TextEditingController(text: profileCtrl.description.value);
    _phoneController = TextEditingController(text: profileCtrl.contactDetails.value);
    _addressController = TextEditingController(text: profileCtrl.location.value);
    _locationController = TextEditingController(text: profileCtrl.address.value);
    _categoryController = TextEditingController(text: profileCtrl.category.value);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    bool isCategoryReadOnly = profileCtrl.category.value.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() => SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Image Upload Section ---
            Center(
              child: Stack(
                children: [
                  Obx(() => CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: profileCtrl.selectedImageFile.value != null
                        ? FileImage(profileCtrl.selectedImageFile.value!)
                        : (profileCtrl.businessImage.value.isNotEmpty
                        ? NetworkImage(profileCtrl.getFullImageUrl()) as ImageProvider
                        : null),
                    child: (profileCtrl.selectedImageFile.value == null && profileCtrl.businessImage.value.isEmpty)
                        ? Icon(Icons.business, size: 60, color: Colors.grey[400])
                        : null,
                  )),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => profileCtrl.pickImage(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            _buildSectionTitle('General Information'),
            _buildTextField('Business Name', _nameController, Icons.person_outline),
            _buildTextField('Business Bio', _bioController, Icons.info_outline, maxLines: 3),

            const SizedBox(height: 20),

            _buildSectionTitle('Categories & Location'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  // Updated Category Field with readOnly logic
                  _buildTextField(
                    'Category',
                    _categoryController,
                    Icons.category_outlined,
                    readOnly: isCategoryReadOnly, // Lock if data exists
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('General Region (North/South/etc)', _locationController, Icons.map_outlined),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _buildSectionTitle('Contact Details'),
            _buildTextField('Exact Address / City', _addressController, Icons.location_on_outlined),
            _buildTextField('Phone Number', _phoneController, Icons.phone_android_outlined, keyboardType: TextInputType.phone),

            const SizedBox(height: 40),

            // --- Update Button ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: profileCtrl.isLoading.value
                    ? null
                    : () {
                  profileCtrl.updateBusinessProfile(
                    name: _nameController.text,
                    phone: _phoneController.text,
                    description: _bioController.text,
                    serviceCategory: _categoryController.text, // Sending as plain text as requested
                    region: _locationController.text,
                    location: _addressController.text,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: profileCtrl.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Update Profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      )),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      IconData icon, {
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
        bool readOnly = false, // Added parameter
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: readOnly, // Set the readOnly state
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: readOnly ? Colors.grey : AppColors.primaryColor, size: 22),
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          filled: true,
          // Change color to indicate it is disabled/read-only
          fillColor: readOnly ? Colors.grey[200] : Colors.grey[50],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: readOnly ? Colors.grey[200]! : AppColors.primaryColor),
          ),
        ),
      ),
    );
  }
}