/**

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/common/components/custom_network_image.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';
import '../controllers/personal_profile_information_controller.dart';

class PersonalInformationScreen extends GetView<ProfileInformationController> {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileInformationController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Personal information',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return controller.isEditing.value
            ? _buildEditMode(controller, context)
            : _buildViewMode(controller);
      }),
    );
  }

  // View Mode
  Widget _buildViewMode(ProfileInformationController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 20),

          // Profile Picture
          Obx(() {
            final imageUrl = controller.getImageUrl();
            final isLocal = controller.isLocalImage();

            return Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 3),
              ),
              child: ClipOval(
                child: imageUrl.isNotEmpty
                    ? (isLocal
                    ? Image.file(
                  File(imageUrl),
                  fit: BoxFit.cover,
                )
                    : CustomCachedImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                ))
                    : const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            );
          }),

          // Edit Profile Button
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () => controller.toggleEdit(),
              child: const Text(
                'Edit profile',
                style: TextStyle(
                  color: AppColors.greyColor,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),

          // Personal Information Section
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Personal information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 24),

                Obx(() => _buildInfoItem(
                  icon: Icons.person_outline,
                  label: 'Name',
                  value: controller.name.value.isNotEmpty
                      ? controller.name.value
                      : 'Not provided',
                  iconColor: Colors.amber[600]!,
                )),

                const SizedBox(height: 20),

                Obx(() => _buildInfoItem(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: controller.email.value.isNotEmpty
                      ? controller.email.value
                      : 'Not provided',
                  iconColor: Colors.amber[600]!,
                )),

                const SizedBox(height: 20),

                Obx(() => _buildInfoItem(
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  value: controller.location.value.isNotEmpty
                      ? controller.location.value[0].toUpperCase() +
                      controller.location.value.substring(1)
                      : 'Not provided',
                  iconColor: Colors.amber[600]!,
                )),

                const SizedBox(height: 20),

                Obx(() => _buildInfoItem(
                  icon: Icons.badge_outlined,
                  label: 'Role',
                  value: controller.role.value.isNotEmpty
                      ? controller.role.value[0].toUpperCase() +
                      controller.role.value.substring(1)
                      : 'Not provided',
                  iconColor: Colors.amber[600]!,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Edit Mode
  Widget _buildEditMode(
      ProfileInformationController controller, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 20),

          // Profile Picture with Edit Button
          Obx(() {
            final imageUrl = controller.getImageUrl();
            final isLocal = controller.isLocalImage();

            return Stack(
              children: <Widget>[
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 3),
                  ),
                  child: ClipOval(
                    child: imageUrl.isNotEmpty
                        ? (isLocal
                        ? Image.file(
                      File(imageUrl),
                      fit: BoxFit.cover,
                    )
                        : CustomCachedImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                    ))
                        : const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => controller.showImagePickerOptions(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.black,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ).centered;
          }),

          const SizedBox(height: 24),

          // Name Field
          const Text(
            'Name',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: controller.nameController,
            hintText: 'Enter name',
          ),

          const SizedBox(height: 24),

          // Location Field
          const Text(
            'Location',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: controller.locationController,
            hintText: 'Enter Location',
          ),

          const SizedBox(height: 24),

          // Email Field (Read-only)
          const Text(
            'Email',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: controller.emailController,
            hintText: 'Enter Email',
            enabled: false,
          ),

          const SizedBox(height: 40),

          // Update Profile Button
          Obx(
                () => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.updateProfile(), // Here update the profile
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[600],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Update Profile',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => controller.cancelEdit(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: enabled ? Colors.white : Colors.grey[100],
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: TextStyle(
          fontSize: 16,
          color: enabled ? Colors.black87 : Colors.grey[600],
        ),
      ),
    );
  }
}

 */






///
///
///
///
///
/// todo::: adding hte location as dropdown
///
///
///
///
///
///




import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/common/components/custom_network_image.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';
import '../controllers/personal_profile_information_controller.dart';

class PersonalInformationScreen extends GetView<ProfileInformationController> {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileInformationController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Personal information',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return controller.isEditing.value
            ? _buildEditMode(controller, context)
            : _buildViewMode(controller);
      }),
    );
  }

  // View Mode
  Widget _buildViewMode(ProfileInformationController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 20),

          // Profile Picture
          Obx(() {
            final imageUrl = controller.getImageUrl();
            final isLocal = controller.isLocalImage();

            return Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 3),
              ),
              child: ClipOval(
                child: imageUrl.isNotEmpty
                    ? (isLocal
                    ? Image.file(
                  File(imageUrl),
                  fit: BoxFit.cover,
                )
                    : CustomCachedImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                ))
                    : const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            );
          }),

          // Edit Profile Button
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () => controller.toggleEdit(),
              child: const Text(
                'Edit profile',
                style: TextStyle(
                  color: AppColors.greyColor,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),

          // Personal Information Section
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Personal information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 24),

                Obx(() => _buildInfoItem(
                  icon: Icons.person_outline,
                  label: 'Name',
                  value: controller.name.value.isNotEmpty
                      ? controller.name.value
                      : 'Not provided',
                  iconColor: Colors.amber[600]!,
                )),

                const SizedBox(height: 20),

                Obx(() => _buildInfoItem(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: controller.email.value.isNotEmpty
                      ? controller.email.value
                      : 'Not provided',
                  iconColor: Colors.amber[600]!,
                )),

                const SizedBox(height: 20),

                Obx(() => _buildInfoItem(
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  value: controller.getDisplayLocation(),
                  iconColor: Colors.amber[600]!,
                )),

                const SizedBox(height: 20),

                Obx(() => _buildInfoItem(
                  icon: Icons.badge_outlined,
                  label: 'Role',
                  value: controller.role.value.isNotEmpty
                      ? controller.role.value[0].toUpperCase() +
                      controller.role.value.substring(1)
                      : 'Not provided',
                  iconColor: Colors.amber[600]!,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Edit Mode
  Widget _buildEditMode(
      ProfileInformationController controller, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 20),

          // Profile Picture with Edit Button
          Obx(() {
            final imageUrl = controller.getImageUrl();
            final isLocal = controller.isLocalImage();

            return Stack(
              children: <Widget>[
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 3),
                  ),
                  child: ClipOval(
                    child: imageUrl.isNotEmpty
                        ? (isLocal
                        ? Image.file(
                      File(imageUrl),
                      fit: BoxFit.cover,
                    )
                        : CustomCachedImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                    ))
                        : const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => controller.showImagePickerOptions(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.black,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ).centered;
          }),

          const SizedBox(height: 24),

          // Name Field
          const Text(
            'Name',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: controller.nameController,
            hintText: 'Enter name',
          ),

          const SizedBox(height: 24),

          // Location Field (Dropdown)
          const Text(
            'Location',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedLocation.value.isEmpty ? null : controller.selectedLocation.value,
                isExpanded: true,
                hint: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Select Location',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                items: [
                  ...controller.locationOptions.map((String location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          location[0].toUpperCase() + location.substring(1),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  }).toList(),
                ],
                onChanged: (String? newValue) {
                  controller.selectedLocation.value = newValue ?? '';
                },
              ),
            ),
          )),

          const SizedBox(height: 24),

          // Email Field (Read-only)
          const Text(
            'Email',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: controller.emailController,
            hintText: 'Enter Email',
            enabled: false,
          ),

          const SizedBox(height: 40),

          // Update Profile Button
          Obx(
                () => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.updateProfile(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[600],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Update Profile',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => controller.cancelEdit(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: enabled ? Colors.white : Colors.grey[100],
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: TextStyle(
          fontSize: 16,
          color: enabled ? Colors.black87 : Colors.grey[600],
        ),
      ),
    );
  }
}
