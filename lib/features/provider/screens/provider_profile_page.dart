import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/features/provider/controllers/provider_profile_controller.dart';
import 'package:manx_mate/features/provider/screens/availablity_page.dart';
import 'package:manx_mate/features/provider/screens/edit_business_profile_screen.dart';
import 'package:manx_mate/features/provider/screens/provider_availablity_screen.dart';

import '../../../shared/subscriptions_controller.dart';
import '../controllers/category_controller.dart';

class ProviderProfilePage extends StatelessWidget {
  const ProviderProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // This ensures the controller is created and available in memory
    final controller = Get.put(ProviderProfileController());
    Get.put(CategoryController());

    final SubscriptionsController subController = Get.isRegistered<SubscriptionsController>()
        ? Get.find<SubscriptionsController>()
        : Get.put(SubscriptionsController());

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

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0), // Padding from the screen edge
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8), // Internal padding for the icon
                decoration: BoxDecoration(
                  color: Colors.grey[100], // Radius background color
                  borderRadius: BorderRadius.circular(10), // The radius
                  border: Border.all(color: Colors.grey[300]!, width: 0.5), // Optional subtle border
                ),
                child: InkWell(
                  onTap: () {
                    Get.to(const EditBusinessProfileScreen(
                    ));
                  },
                  child: const Icon(
                    Icons.edit,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
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
                CircularProgressIndicator(color: AppColors.primaryColor),
                SizedBox(height: 16),
                Text('Fetching your profile...'),
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
                const Text('Unable to load profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => controller.forceRefresh(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[600], foregroundColor: Colors.black),
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
                      const Text('Business information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 24),

                      Obx(() => Column(
                        children: <Widget>[
                          _buildFormField(
                            controller: controller, // Pass controller reference
                            label: 'Business Name',
                            value: controller.businessName.value,
                            textController: controller.nameController,
                            isEditing: controller.isEditing.value,
                            placeholder: 'Add a business name',
                            showLocationDropdown: false,
                          ),
                          const SizedBox(height: 20),


                          _buildFormField(
                            controller: controller,
                            label: 'Category',
                            value: controller.category.value,
                            textController: TextEditingController(text: controller.category.value),
                            isEditing: false, // 🔒 read-only for now
                            placeholder: 'Business category',
                            showLocationDropdown: false,
                          ),
                          const SizedBox(height: 20),

                          _buildFormField(
                            controller: controller,
                            showLocationDropdown: true,
                            label: 'Location',
                            value: controller.location.value,
                            textController: controller.locationController,
                            isEditing: controller.isEditing.value,
                            placeholder: 'Add business location',
                          ),
                          const SizedBox(height: 20),
                          _buildDescriptionField(
                            label: 'Address',
                            value: controller.address.value,
                            textController: controller.addressController,
                            isEditing: controller.isEditing.value,
                            placeholder: 'Add business address',
                          ),
                          const SizedBox(height: 20),
                          _buildFormField(
                            controller: controller,
                            showLocationDropdown: false,
                            label: 'Telephone Number',
                            value: controller.contactDetails.value,
                            textController: controller.contactController,
                            isEditing: controller.isEditing.value,
                            placeholder: 'Add a business telephone number',
                          ),
                          const SizedBox(height: 20),
                          _buildDescriptionField(
                            label: 'Business Description',
                            value: controller.description.value,
                            textController: controller.descriptionController,
                            isEditing: controller.isEditing.value,
                            placeholder: 'Add a business description',
                          ),
                          const SizedBox(height: 20),
                          // Inside ProviderProfilePage column...
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [Text("Open & Close Hour", style: TextStyle(fontSize: 18))],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey[200]!),
                                ),
                              ),
                              onPressed: () {
                                // 🔹 Dual Logic Check
                                final subController = Get.find<SubscriptionsController>();
                                if (subController.canAccessOpeningHours) {
                                  Get.to(() => const ProviderAvailabilityScreen());
                                } else {
                                  // 🔹 Show message if not clickable
                                  Get.snackbar(
                                    "Premium Upgrade Required",
                                    "This feature is available on our Premium plans. Upgrade now to manage your business hours.",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: const Color(0xFF1A1A1A), // Sleek Dark/Gold theme
                                    colorText: Colors.white,
                                    margin: const EdgeInsets.all(15),
                                    duration: const Duration(seconds: 4),
                                    icon: const Icon(Icons.stars, color: Colors.amber),
                                    mainButton: TextButton(
                                      onPressed: () {
                                        Get.toNamed('/subscription-plans');// Navigate to plans
                                      } ,
                                      child: const Text("UPGRADE", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                                    ),
                                  );
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Obx(() {
                                    final hoursText = controller.todayHours;
                                    final bool isOff = hoursText == 'OFF';

                                    return Row(
                                      children: [
                                        const Text("Today: ", style: TextStyle(color: Colors.grey, fontSize: 14)),
                                        Text(
                                          hoursText,
                                          style: TextStyle(
                                            color: isOff ? Colors.red : Colors.black, // 🔴 Red if OFF
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                  // 🔹 Visual feedback: change icon if locked
                                  Obx(() {
                                    final bool hasAccess = Get.find<SubscriptionsController>().canAccessOpeningHours;
                                    return Icon(
                                      hasAccess ? Icons.arrow_forward : Icons.lock_outline,
                                      color: hasAccess ? AppColors.primaryColor : Colors.grey[400],
                                      size: 20,
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )),

                      const SizedBox(height: 32),

                      Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text('Business Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 16),
                          if (controller.businessImage.value.isNotEmpty) ...[
                            _buildImagePreview(controller),
                          ] else ...[
                            _buildImagePlaceholder(controller),
                          ],
                        ],
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Obx(() => controller.isEditing.value
                    ? SizedBox(width: double.infinity, child: TextButton(onPressed: () => controller.cancelEdit(), child: Text('Cancel', style: TextStyle(color: Colors.grey[600], fontSize: 16))))
                    : const SizedBox()),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildImagePreview(ProviderProfileController controller) {
    return Stack(
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
              errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey[400])),
            ),
          ),
        ),
        if (controller.isEditing.value)
          Positioned(
            bottom: 12,
            right: 12,
            child: ElevatedButton.icon(
              onPressed: () => controller.showImagePickerDialog(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[600], foregroundColor: Colors.black),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Change Image'),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePlaceholder(ProviderProfileController controller) {
    return GestureDetector(
      onTap: controller.isEditing.value ? () => controller.showImagePickerDialog() : null,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: controller.isEditing.value ? Colors.amber[600]! : Colors.grey[300]!, width: controller.isEditing.value ? 2 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(controller.isEditing.value ? Icons.add_photo_alternate : Icons.image_not_supported, size: 60, color: Colors.grey[400]),
            Text(controller.isEditing.value ? 'Tap to add image' : 'No image'),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required ProviderProfileController controller,
    required String label,
    required String value,
    required TextEditingController textController,
    required bool isEditing,
    required String placeholder,
    required bool showLocationDropdown,
  }) {
    final displayValue = value.isEmpty ? placeholder : value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: isEditing ? AppColors.primaryColor : Colors.grey[300]!, width: isEditing ? 2 : 1),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: isEditing
              ? showLocationDropdown
              ? DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                value: ['north', 'south', 'east', 'west'].contains(textController.text) ? textController.text : null,
                onChanged: (newValue) => textController.text = newValue ?? '',
                hint: Text(placeholder, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'north', child: Text('North')),
                  DropdownMenuItem(value: 'south', child: Text('South')),
                  DropdownMenuItem(value: 'east', child: Text('East')),
                  DropdownMenuItem(value: 'west', child: Text('West')),
                ],
              ),
            ),
          )
              : TextField(
            controller: textController,
            decoration: InputDecoration(border: InputBorder.none, hintText: placeholder, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          )
              : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Text(displayValue, style: TextStyle(fontSize: 14, color: value.isEmpty ? Colors.grey[500] : Colors.black87, fontStyle: value.isEmpty ? FontStyle.italic : FontStyle.normal)),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField({
    required String label,
    required String value,
    required TextEditingController textController,
    required bool isEditing,
    required String placeholder,
  }) {
    final displayValue = value.isEmpty ? placeholder : value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: isEditing ? AppColors.primaryColor : Colors.grey[300]!, width: isEditing ? 2 : 1),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: isEditing
              ? TextField(
            controller: textController,
            maxLines: 4,
            decoration: InputDecoration(border: InputBorder.none, hintText: placeholder, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          )
              : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Text(displayValue, style: TextStyle(fontSize: 14, color: value.isEmpty ? Colors.grey[500] : Colors.black87, fontStyle: value.isEmpty ? FontStyle.italic : FontStyle.normal)),
          ),
        ),
      ],
    );
  }
}