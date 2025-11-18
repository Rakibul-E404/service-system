

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/features/provider/controllers/provider_profile_controller.dart';

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
          // onPressed: () => Get.back(),
          onPressed: () => Navigator.pop(context),
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
      body: Obx(
            () {
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

          // Check if we have a provider ID
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
                  // Business Information Section with Border
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
                        Obx(
                              () => Column(
                            children: <Widget>[
                              _buildFormField(
                                label: 'Name',
                                value: controller.businessName.value,
                                controller: controller.nameController,
                                isEditing: controller.isEditing.value,
                                placeholder: 'Add a business name',
                              ),
                              const SizedBox(height: 20),
                              _buildFormField(
                                label: 'Location',
                                value: controller.location.value,
                                controller: controller.locationController,
                                isEditing: controller.isEditing.value,
                                placeholder: 'Add a business location (State/Province/County)',
                              ),
                              const SizedBox(height: 20),
                              _buildFormField(
                                label: 'Contact details',
                                value: controller.contactDetails.value,
                                controller: controller.contactController,
                                isEditing: controller.isEditing.value,
                                placeholder: 'Add a business contact details',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
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
                              if (!controller.isEditing.value && controller.businessImage.value.isNotEmpty)
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
                                      controller.businessImage.value,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(Icons.broken_image, size: 50, color: Colors.grey[400]),
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
                              if (controller.isEditing.value)
                                Column(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () => controller.showImagePickerDialog(),
                                      child: Container(
                                        width: double.infinity,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey[300]!),
                                        ),
                                        child: controller.selectedImage.value != null
                                            ? Stack(
                                          children: <Widget>[
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(11),
                                              child: Image.file(
                                                controller.selectedImage.value!,
                                                width: double.infinity,
                                                height: double.infinity,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: GestureDetector(
                                                onTap: () => controller.removeImage(),
                                                child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: const BoxDecoration(
                                                    color: Colors.red,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                            : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.cloud_upload_outlined,
                                              size: 40,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Tap to upload image',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Format: jpeg, png & Max file size: 25 MB',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => controller.showImagePickerDialog(),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.amber[600],
                                              foregroundColor: Colors.black,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              elevation: 0,
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                const Icon(Icons.upload, size: 18),
                                                const SizedBox(width: 8),
                                                Text(
                                                  controller.selectedImage.value != null
                                                      ? 'Change Image'
                                                      : 'Upload Image',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (controller.selectedImage.value != null) ...<Widget>[
                                          const SizedBox(width: 12),
                                          ElevatedButton(
                                            onPressed: () => controller.removeImage(),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red[100],
                                              foregroundColor: Colors.red[700],
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 12,
                                                horizontal: 16,
                                              ),
                                              elevation: 0,
                                            ),
                                            child: const Icon(Icons.delete, size: 18),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
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
        },
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String value,
    required TextEditingController controller,
    required bool isEditing,
    required String placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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
              value,
              style: TextStyle(
                fontSize: 14,
                color: value.startsWith('Add a') ? Colors.grey[500] : Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }
}








///
///
///
/// todO:::: :::: fixing the provider Id
///
///
///
///


