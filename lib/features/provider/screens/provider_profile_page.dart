import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/features/provider/controllers/provider_profile_controller.dart';
import 'package:manx_mate/features/provider/screens/availablity_page.dart';
import 'package:manx_mate/features/provider/screens/provider_availablity_screen.dart';

class ProviderProfilePage extends GetView<ProviderProfileController> {
  const ProviderProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(closeOverlays: false),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: <Widget>[
          Obx(
            () => Container(
              margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : () => controller.toggleEdit(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[600],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : Text(
                        controller.isEditing.value ? 'Save' : 'Edit',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && !controller.isEditing.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading your profile...'),
              ],
            ),
          );
        }

        if (controller.providerId.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'Unable to load profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please check your login and try again',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => controller.forceRefresh(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[600],
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchBusinessProfile(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Business Information Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primaryColor, width: 1),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Business information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Form Fields
                      Obx(
                        () => Column(
                          children: <Widget>[
                            _buildFormField(
                              label: 'Business Name',
                              value: controller.businessName.value,
                              controller: controller.nameController,
                              isEditing: controller.isEditing.value,
                              placeholder: 'Add a business name',
                              showLocationDropdown: false,
                            ),
                            const SizedBox(height: 20),
                            _buildFormField(
                              showLocationDropdown: true,
                              label: 'Location',
                              value: controller.location.value,
                              controller: controller.locationController,
                              isEditing: controller.isEditing.value,
                              placeholder: 'Add business location (State/Province/County)',
                            ),

                            const SizedBox(height: 20),
                            _buildDescriptionField(
                              label: 'Address',
                              value: controller.description.value,
                              controller: controller.descriptionController,
                              isEditing: controller.isEditing.value,
                              placeholder: 'Add business address',
                            ),
                            const SizedBox(height: 20),
                            _buildFormField(
                              showLocationDropdown: false,
                              label: 'Telephone Number',
                              value: controller.contactDetails.value,
                              controller: controller.contactController,
                              isEditing: controller.isEditing.value,
                              placeholder: 'Add a business telephone number',
                            ),
                            const SizedBox(height: 20),
                            _buildFormField(
                              label: 'E-mail',
                              value: controller.contactDetails.value,
                              controller: controller.contactController,
                              isEditing: controller.isEditing.value,
                              placeholder: 'Add a business e-mail',
                              showLocationDropdown: false,
                            ),
                            const SizedBox(height: 20),
                            _buildDescriptionField(
                              label: 'Business Description',
                              value: controller.description.value,
                              controller: controller.descriptionController,
                              isEditing: controller.isEditing.value,
                              placeholder: 'Add a business description',
                            ),
                            const SizedBox(height: 20),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [Text("Open & Close Hour",style: TextStyle(fontSize: 18,),)],
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ), // Set your desired radius
                                  ),
                                ),
                                onPressed: () {
                                  Get.to(() => const ProviderAvailabilityScreen());
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Today: 9:00AM - 6:00PM',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward, color: AppColors.primaryColor),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Business Image Section
                      Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Business Image',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Show current image if exists
                            if (controller.businessImage.value.isNotEmpty) ...[
                              Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(11),
                                      child: Image.network(
                                        controller.getFullImageUrl(),
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                        loadingProgress.expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.broken_image,
                                                  size: 50,
                                                  color: Colors.grey[400],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Failed to load image',
                                                  style: TextStyle(color: Colors.grey[600]),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),

                                  // Edit button only in edit mode
                                  if (controller.isEditing.value)
                                    Positioned(
                                      bottom: 12,
                                      right: 12,
                                      child: ElevatedButton.icon(
                                        onPressed: controller.isUploadingImage.value
                                            ? null
                                            : () => controller.showImagePickerDialog(),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.amber[600],
                                          foregroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          elevation: 2,
                                        ),
                                        icon: controller.isUploadingImage.value
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    Colors.black,
                                                  ),
                                                ),
                                              )
                                            : const Icon(Icons.edit, size: 18),
                                        label: Text(
                                          controller.isUploadingImage.value
                                              ? 'Uploading...'
                                              : 'Change Image',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                controller.isEditing.value
                                    ? 'Tap "Change Image" to replace your business image'
                                    : 'Your current business image',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],

                            // Show placeholder when no image
                            if (controller.businessImage.value.isEmpty) ...[
                              GestureDetector(
                                onTap:
                                    controller.isEditing.value && !controller.isUploadingImage.value
                                    ? () => controller.showImagePickerDialog()
                                    : null,
                                child: Container(
                                  width: double.infinity,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: controller.isEditing.value
                                          ? Colors.amber[600]!
                                          : Colors.grey[300]!,
                                      width: controller.isEditing.value ? 2 : 1,
                                    ),
                                  ),
                                  child: controller.isUploadingImage.value
                                      ? const Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              CircularProgressIndicator(),
                                              SizedBox(height: 16),
                                              Text(
                                                'Uploading image...',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              controller.isEditing.value
                                                  ? Icons.add_photo_alternate
                                                  : Icons.image_not_supported,
                                              size: 60,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              controller.isEditing.value
                                                  ? 'Tap to add business image'
                                                  : 'No business image',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            if (controller.isEditing.value) ...[
                                              const SizedBox(height: 8),
                                              Text(
                                                'JPEG, PNG • Max 25 MB',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                ),
                              ),
                              if (controller.isEditing.value &&
                                  !controller.isUploadingImage.value) ...[
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => controller.showImagePickerDialog(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber[600],
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      elevation: 0,
                                    ),
                                    icon: const Icon(Icons.upload, size: 20),
                                    label: const Text(
                                      'Upload Business Image',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Cancel button
                Obx(
                  () => controller.isEditing.value
                      ? SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => controller.cancelEdit(),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ),
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFormField({
    required String label,
    required String value,
    required TextEditingController controller,
    required bool isEditing,
    required String placeholder,
    required bool showLocationDropdown, // Determines if the location dropdown should be shown
  }) {
    final displayValue = value.isEmpty ? placeholder : value;
    final isPlaceholder = value.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: isEditing ? AppColors.primaryColor : Colors.grey[300]!,
              width: isEditing ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: isEditing
              ? showLocationDropdown // Only show dropdown for location
                    ? DropdownButton<String>(
                        value: value.isEmpty ? null : value,
                        // null if the location is empty
                        onChanged: (String? newValue) {
                          // Update the controller or state when a new location is selected
                          controller.text = newValue ?? ''; // Updates the controller
                        },
                        hint: Text(
                          placeholder,
                          style: TextStyle(color: Colors.grey[500], fontSize: 14),
                        ),
                        isExpanded: true,
                        underline: Container(),
                        // Remove default underline
                        items: [
                          // Add a null item for "no selection"
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text('Select $label', style: TextStyle(color: Colors.grey[500])),
                          ),
                          const DropdownMenuItem(value: 'north', child: Text('North')),
                          const DropdownMenuItem(value: 'south', child: Text('South')),
                          const DropdownMenuItem(value: 'east', child: Text('East')),
                          const DropdownMenuItem(value: 'west', child: Text('West')),
                        ],
                      )
                    : TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: placeholder,
                          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Text(
                    displayValue,
                    style: TextStyle(
                      fontSize: 14,
                      color: isPlaceholder ? Colors.grey[500] : Colors.black87,
                      fontStyle: isPlaceholder ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField({
    required String label,
    required String value,
    required TextEditingController controller,
    required bool isEditing,
    required String placeholder,
  }) {
    final displayValue = value.isEmpty ? placeholder : value;
    final isPlaceholder = value.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: isEditing ? AppColors.primaryColor : Colors.grey[300]!,
              width: isEditing ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: isEditing
              ? TextField(
                  controller: controller,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: placeholder,
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Text(
                    displayValue,
                    style: TextStyle(
                      fontSize: 14,
                      color: isPlaceholder ? Colors.grey[500] : Colors.black87,
                      fontStyle: isPlaceholder ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
