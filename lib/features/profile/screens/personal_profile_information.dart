import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/common/components/custom_network_image.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';
import '../controllers/profile_controller.dart';
import '../controllers/profile_information_controller.dart';

// Personal Information Screen
class PersonalInformationScreen extends GetView<ProfileInformationController> {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {

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
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Obx(
        () => controller.isEditing.value ? _buildEditMode(controller) : _buildViewMode(controller),
      ),
    );
  }

  // View Mode (Left Screen)
  Widget _buildViewMode(ProfileInformationController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 20),

          // Profile Picture
          const CircleAvatar(radius: 50),


          // Edit Profile Button
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () => controller.toggleEdit(),
              child: Text(
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
          Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Personal information',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
                ),

                const SizedBox(height: 24),

                // Information Items
                _buildInfoItem(
                  icon: Icons.person_outline,
                  label: 'Name',
                  value: controller.name.value,
                  iconColor: Colors.amber[600]!,
                ),

                const SizedBox(height: 20),

                _buildInfoItem(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: controller.email.value,
                  iconColor: Colors.amber[600]!,
                ),

                const SizedBox(height: 20),

                _buildInfoItem(
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  value: controller.location.value,
                  iconColor: Colors.amber[600]!,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Edit Mode (Right Screen)
  Widget _buildEditMode(ProfileInformationController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 20),
          Stack(
            children: <Widget>[
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!, width: 3),
                ),
                child: ClipOval(
                  child: CustomCachedImage(
                    imageUrl:
                    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, color: Colors.black, size: 16),
                ),
              ),
            ],
          ).centered,
          SizedBox(height: AppSizes.md,),
          // Name Field
          const Text(
            'Name',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          _buildTextField(controller: controller.nameController, hintText: 'Enter name'),

          const SizedBox(height: 24),

          // Location Field
          const Text(
            'Location',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          _buildTextField(controller: controller.locationController, hintText: 'Enter Location'),

          const SizedBox(height: 24),

          // Email Field
          const Text(
            'Email',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          _buildTextField(controller: controller.emailController, hintText: 'Enter Email'),

          const SizedBox(height: 40),

          // Update Profile Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.toggleEdit(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[600],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text(
                'Update Profile',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => controller.cancelEdit(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  // Build Info Item (for view mode)
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
          decoration: BoxDecoration(color: iconColor.withValues(alpha:  0.1), shape: BoxShape.circle),
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

  // Build Text Field (for edit mode)
  Widget _buildTextField({required TextEditingController controller, required String hintText}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }
}
