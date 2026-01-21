

import 'package:flutter/material.dart';
import 'package:manx_mate/core/config/app_colors.dart';

import 'package:get/get.dart';

import '../controllers/category_controller.dart';
import '../controllers/provider_profile_controller.dart';

class EditBusinessProfileScreen extends StatefulWidget {
  const EditBusinessProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditBusinessProfileScreen> createState() => _EditBusinessProfileScreenState();
}

class _EditBusinessProfileScreenState extends State<EditBusinessProfileScreen> {
  // Access the controller directly
  final profileCtrl = Get.find<ProviderProfileController>();
  final categoryCtrl = Get.find<CategoryController>();

  // Local Controllers
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController; // Exact Location
  late TextEditingController _locationController; // General Region
  late TextEditingController _categoryController;

  final List<String> _regions = ['North', 'South', 'East', 'West'];


  @override
  void initState() {
    super.initState();

    String rawRegion = profileCtrl.address.value.trim();

    // Initialize with current values from the Controller
    _nameController = TextEditingController(text: profileCtrl.businessName.value);
    _bioController = TextEditingController(text: profileCtrl.description.value);
    _phoneController = TextEditingController(text: profileCtrl.contactDetails.value);
    _addressController = TextEditingController(text: profileCtrl.location.value);
    String formattedRegion = "";
    if (rawRegion.isNotEmpty) {
      formattedRegion = rawRegion[0].toUpperCase() + rawRegion.substring(1).toLowerCase();
    }
    _locationController = TextEditingController(text: formattedRegion);
    _categoryController = TextEditingController(text: profileCtrl.category.value);

    if (profileCtrl.categoryId.value.isNotEmpty) {
      categoryCtrl.fetchSubCategories(profileCtrl.categoryId.value);
    }

    if (categoryCtrl.categories.isEmpty) {
      categoryCtrl.fetchCategories();
    }
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
        body: SingleChildScrollView(
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
                        onTap: () => profileCtrl.showImagePickerDialog(),
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
                    Obx(() {
                      // Logic: Only lock the field if the server already has a value saved.
                      final bool isSavedOnServer = profileCtrl.category.value.isNotEmpty;

                      if (isSavedOnServer) {
                        // Locked view after successful update
                        return _buildTextField(
                          'Category',
                          _categoryController,
                          Icons.category_outlined,
                          readOnly: true,
                        );
                      } else {
                        // Selectable view before update
                        return DropdownButtonFormField<String>(
                          value: profileCtrl.categoryId.value.isEmpty ? null : profileCtrl.categoryId.value,
                          hint: const Text("Select Category"),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.category_outlined, color: AppColors.primaryColor),
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                          ),
                          items: categoryCtrl.categories.map((cat) {
                            return DropdownMenuItem(value: cat.id, child: Text(cat.name));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              final selectedCat = categoryCtrl.categories.firstWhere((e) => e.id == val);

                              // --- WARNING DIALOG ---
                              Get.defaultDialog(
                                title: "Warning",
                                middleText: "Once you set '${selectedCat.name}' as your category and update your profile, you cannot change it again. Do you want to proceed?",
                                textConfirm: "Confirm",
                                textCancel: "Cancel",
                                confirmTextColor: Colors.white,
                                buttonColor: AppColors.primaryColor,
                                onConfirm: () {
                                  profileCtrl.categoryId.value = val;
                                  _categoryController.text = selectedCat.name;
                                  categoryCtrl.fetchSubCategories(val);


                                  profileCtrl.updateBusinessProfile(

                                    serviceCategoryId: val, // The newly selected ID
                                  );

                                  Get.back(); // Close dialog
                                },
                              );
                            }
                          },
                        );
                      }
                    }),
                    const SizedBox(height: 16),


                      Obx(() {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Sub-Categories", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () {
                                if (profileCtrl.isProfileComplete.value == false) {
                                  Get.defaultDialog(
                                    title: "Profile Incomplete",
                                    middleText: "Please complete your general business information (Name,Phone,Region,Image, Bio, and Location) and save your profile before managing sub-categories.",
                                    textConfirm: "OK",
                                    confirmTextColor: Colors.white,
                                    buttonColor: AppColors.primaryColor,
                                    onConfirm: () => Get.back(),
                                  );
                                } else {
                                  // ✅ PROCEED: Profile is complete, fetch and show picker
                                  profileCtrl.fetchSelfServices();
                                  _showSubCategoryPicker(context);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        profileCtrl.selectedSubCategoryNames,
                                        style: TextStyle(
                                          color: profileCtrl.selectedSubCategoryIds.isEmpty ? Colors.grey : Colors.black,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),

                    const SizedBox(height: 16),


                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _regions.contains(_locationController.text) ? _locationController.text : null,
                      hint: const Text("Select General Region"),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.map_outlined, color: AppColors.primaryColor),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[200]!)
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[200]!)
                        ),
                      ),
                      items: _regions.map((region) => DropdownMenuItem(value: region, child: Text(region))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          _locationController.text = val;
                        }
                      },
                    ),
                    ],
                  )
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
                child: Obx(() => ElevatedButton(
                  onPressed: profileCtrl.isLoading.value
                      ? null
                      : () {
                    // 1. Validation: Ensure category is selected if not already set on server
                    if (profileCtrl.category.value.isEmpty && profileCtrl.categoryId.value.isEmpty) {
                      Get.snackbar(
                          'Required',
                          'Please select a business category before updating.',
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white
                      );
                      return;
                    }

                    // 2. Logic: Only pass the ID if it's the first time setting it
                    String? newCategoryId;
                    if (profileCtrl.category.value.isEmpty && profileCtrl.categoryId.value.isNotEmpty) {
                      newCategoryId = profileCtrl.categoryId.value;
                    }

                    profileCtrl.updateBusinessProfile(
                      name: _nameController.text,
                      phone: _phoneController.text,
                      description: _bioController.text,
                      region: _locationController.text,
                      location: _addressController.text,
                      serviceCategoryId: newCategoryId,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: profileCtrl.isLoading.value
                      ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  )
                      : const Text(
                    'Update Profile',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                )),
              ),

              const SizedBox(height: 20),
            ],
          ),
        )
    );
  }

  // --- Helper Widgets ---

  void _showSubCategoryPicker(BuildContext context) {
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text("Select Sub-Categories",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close))
              ],
            ),
            const Divider(),
            Expanded(
              child: Obx(() {
                // Show loader if the main list OR the selection states are loading
                if (categoryCtrl.isSubLoading.value || profileCtrl.isSelfServiceLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
                }

                if (categoryCtrl.subCategories.isEmpty) {
                  return const Center(child: Text("No sub-categories available"));
                }

                return ListView.builder(
                  itemCount: categoryCtrl.subCategories.length,
                  itemBuilder: (context, index) {
                    final sub = categoryCtrl.subCategories[index];
                    return Obx(() {
                      final isSelected = profileCtrl.selectedSubCategoryIds.contains(sub.id);
                      final isProcessing = profileCtrl.processingId.value == sub.id;

                      return CheckboxListTile(
                        activeColor: AppColors.primaryColor,
                        title: Text(sub.name),
                        // Visual feedback for the POST request
                        secondary: isProcessing
                            ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                            : null,
                        value: isSelected,
                        onChanged: isProcessing
                            ? null
                            : (val) => profileCtrl.toggleSubCategoryService(sub.id),
                      );
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


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