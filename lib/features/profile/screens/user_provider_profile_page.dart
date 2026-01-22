/**
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/features/profile/screens/provider_booking_bottom_sheet.dart';
import '../../../core/common/components/custom_network_image.dart';
import '../../../core/common/widgets/reusable_button.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/user_provider_profile_controller.dart';
import '../model/user_provider_profile_response_model.dart';

class UserProviderProfilePage extends StatefulWidget {
  const UserProviderProfilePage({super.key});

  @override
  State<UserProviderProfilePage> createState() => _UserProviderProfilePageState();
}

class _UserProviderProfilePageState extends State<UserProviderProfilePage> {
  final UserProviderProfileController controller = Get.put(UserProviderProfileController());

  // Local state for the dropdown selection
  UserProviderService? _selectedService;

  @override
  void initState() {
    super.initState();
    // Assuming profileId is passed as an argument
    final String profileId = Get.arguments['profileId'] ?? '';
    if (profileId.isNotEmpty) {
      controller.fetchProviderProfile(profileId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.isNotEmpty) {
            return Center(child: Text(controller.errorMessage.value));
          }

          final profile = controller.profile;
          if (profile == null) {
            return const Center(child: Text("Provider profile not found."));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header Navigation
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(CupertinoIcons.back),
                    ),
                    Text("Provider Profile", style: context.txtTheme.titleMedium),
                  ],
                ),

                const SizedBox(height: AppSizes.md),

                // Profile Image
                CustomCachedImage(
                  imageUrl: profile.fullImageUrl,
                  width: double.infinity,
                  height: context.screenHeight * 0.35,
                ),

                const SizedBox(height: AppSizes.md),

                // Name and Access Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(profile.name, style: context.txtTheme.headlineSmall),
                    ),
                    _buildContactIcons(controller.providerData.value?.accessibleBySubscription ?? []),
                  ],
                ),

                const SizedBox(height: AppSizes.sm),
                _buildDetailRow(Icons.location_on_outlined, profile.location),
                _buildDetailRow(Icons.phone_outlined, profile.phone),

                const SizedBox(height: AppSizes.xl),

                // Dynamic Service Dropdown
                Text("Available Services", style: context.txtTheme.titleMedium),
                const SizedBox(height: AppSizes.sm),
                _buildServiceDropdown(controller.services),

                const SizedBox(height: AppSizes.xl),

                // Description Section
                Text(
                  "About Business",
                  style: context.txtTheme.headlineSmall?.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
                const Divider(color: AppColors.primaryColor, thickness: 2),
                const SizedBox(height: AppSizes.sm),
                Text(profile.region.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("This provider offers professional services in your region. View their availability above."),

                const SizedBox(height: 40),

                // Book Button (Always at bottom of scroll or floating)
                ReusableButton(
                  onTap: () {
                    if (_selectedService == null) {
                      Get.snackbar("Select Service", "Please select a service from the dropdown first.",
                          backgroundColor: Colors.orange, colorText: Colors.white);
                      return;
                    }

                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => FractionallySizedBox(
                        heightFactor: 0.9,
                        child: ProviderBookingBottomSheet(
                          providerProfile: controller.profile!,
                          selectedService: _selectedService!,
                          onSubmitSuccess: () {
                            Get.back();
                            Get.snackbar("Success", "Booking request sent!");

                            // Store flags to indicate we should navigate to booking tab and then active jobs tab
                            GetStorage storage = GetStorage();
                            storage.write('should_navigate_to_booking_after_home', true);
                            storage.write('should_navigate_to_active_jobs', true);

                            // Navigate to main bottom nav first
                            Get.toNamed(AppRoutes.mainBottomNavPage);
                          },
                        ),
                      ),
                    );
                  },
                  label: "Book Selected Service",
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildServiceDropdown(List<UserProviderService> services) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<UserProviderService>(
          isExpanded: true,
          hint: const Text("Select a service"),
          value: _selectedService,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryColor),
          items: services.map((UserProviderService service) {
            return DropdownMenuItem<UserProviderService>(
              value: service,
              child: Text(service.name),
            );
          }).toList(),
          onChanged: (UserProviderService? value) {
            setState(() {
              _selectedService = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildContactIcons(List<String> access) {
    return Row(
      children: [
        if (access.contains('Call')) const Icon(Icons.call, size: 24, color: AppColors.primaryColor),
        const SizedBox(width: 12),
        if (access.contains('Email')) const Icon(Icons.email, size: 24, color: AppColors.primaryColor),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}*/








///
///
///
/// todo::: navigating functionality for dialer and email
///
///
///




import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/features/profile/screens/provider_booking_bottom_sheet.dart';
import '../../../core/common/components/custom_network_image.dart';
import '../../../core/common/widgets/reusable_button.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/user_provider_profile_controller.dart';
import '../model/user_provider_profile_response_model.dart';

class UserProviderProfilePage extends StatefulWidget {
  const UserProviderProfilePage({super.key});

  @override
  State<UserProviderProfilePage> createState() => _UserProviderProfilePageState();
}

class _UserProviderProfilePageState extends State<UserProviderProfilePage> {
  final UserProviderProfileController controller = Get.put(UserProviderProfileController());

  // Local state for the dropdown selection
  UserProviderService? _selectedService;

  @override
  void initState() {
    super.initState();
    // Assuming profileId is passed as an argument
    final String profileId = Get.arguments['profileId'] ?? '';
    if (profileId.isNotEmpty) {
      controller.fetchProviderProfile(profileId);
    }
  }

  // Function to launch phone dialer
  Future<void> _launchPhoneDialer(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      Get.snackbar(
        "Error",
        "Could not launch dialer",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Function to launch email client with improved error handling
  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri(scheme: 'mailto', path: email);
    try {
      final bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        Get.snackbar(
          'No Email App',
          'No email app found.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to open email.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.isNotEmpty) {
            return Center(child: Text(controller.errorMessage.value));
          }

          final profile = controller.profile;
          if (profile == null) {
            return const Center(child: Text("Provider profile not found."));
          }

          // Get accessible contact methods from controller
          final accessibleContacts = controller.accessibleContacts;
          final phoneNumber = controller.phoneNumber;
          final email = controller.email;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header Navigation
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(CupertinoIcons.back),
                    ),
                    Text("Provider Profile", style: context.txtTheme.titleMedium),
                  ],
                ),

                const SizedBox(height: AppSizes.md),

                // Profile Image
                CustomCachedImage(
                  imageUrl: profile.fullImageUrl,
                  width: double.infinity,
                  height: context.screenHeight * 0.35,
                ),

                const SizedBox(height: AppSizes.md),

                // Name and Access Icons (conditionally shown based on accessibleBySubscription)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(profile.name, style: context.txtTheme.headlineSmall),
                    ),
                    if (accessibleContacts.isNotEmpty) // Only show if there are accessible contacts
                      _buildContactIcons(
                        accessibleContacts,
                        phoneNumber: phoneNumber,
                        email: email,
                      ),
                  ],
                ),

                const SizedBox(height: AppSizes.sm),
                // Show location always
                _buildDetailRow(Icons.location_on_outlined, profile.location),

                // Conditionally show phone number based on accessibleBySubscription
                if (accessibleContacts.contains('Call') && phoneNumber.isNotEmpty)
                  _buildDetailRow(Icons.phone_outlined, phoneNumber),

                // Conditionally show email based on accessibleBySubscription
                if (accessibleContacts.contains('Email') && email.isNotEmpty)
                  _buildDetailRow(Icons.email_outlined, email),

                const SizedBox(height: AppSizes.xl),

                // Dynamic Service Dropdown
                Text("Available Services", style: context.txtTheme.titleMedium),
                const SizedBox(height: AppSizes.sm),
                _buildServiceDropdown(controller.services),

                const SizedBox(height: AppSizes.xl),

                // Description Section
                Text(
                  "About Business",
                  style: context.txtTheme.headlineSmall?.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
                const Divider(color: AppColors.primaryColor, thickness: 2),
                const SizedBox(height: AppSizes.sm),
                Text(profile.region.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("This provider offers professional services in your region. View their availability above."),

                const SizedBox(height: 40),

                // Book Button (Always at bottom of scroll or floating)
                ReusableButton(
                  onTap: () {
                    if (_selectedService == null) {
                      Get.snackbar("Select Service", "Please select a service from the dropdown first.",
                          backgroundColor: Colors.orange, colorText: Colors.white);
                      return;
                    }
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => FractionallySizedBox(
                        heightFactor: 0.9,
                        child: ProviderBookingBottomSheet(
                          providerProfile: controller.profile!,
                          selectedService: _selectedService!,
                          onSubmitSuccess: () {
                            // First show snackbar
                            // Get.snackbar(
                            //   "Success",
                            //   "Booking request sent!",
                            //   backgroundColor: Colors.green,
                            //   colorText: Colors.white,
                            // );

                            // Then close after a delay
                            Future.delayed(const Duration(seconds: 1), () {
                              Navigator.pop(context); // Close bottom sheet

                              // Clear selection after closing
                              setState(() {
                                _selectedService = null;
                              });
                            });
                          },
                        ),
                      ),
                    );
                    // showModalBottomSheet(
                    //   context: context,
                    //   isScrollControlled: true,
                    //   backgroundColor: Colors.white,
                    //   shape: const RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    //   ),
                    //   builder: (context) => FractionallySizedBox(
                    //     heightFactor: 0.9,
                    //     child: ProviderBookingBottomSheet(
                    //       providerProfile: controller.profile!,
                    //       selectedService: _selectedService!,
                    //       onSubmitSuccess: () {
                    //         Get.back();
                    //         Get.snackbar("Success", "Booking request sent!");
                    //
                    //         // Store flags to indicate we should navigate to booking tab and then active jobs tab
                    //         GetStorage storage = GetStorage();
                    //         storage.write('should_navigate_to_booking_after_home', true);
                    //         storage.write('should_navigate_to_active_jobs', true);
                    //
                    //         // Navigate to main bottom nav first
                    //         /// Get.toNamed(AppRoutes.mainBottomNavPage);
                    //       },
                    //     ),
                    //   ),
                    // );
                  },
                  label: "Book Selected Service",
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildServiceDropdown(List<UserProviderService> services) {
    if (services.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: Center(
          child: Text(
            "No services available",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<UserProviderService>(
          isExpanded: true,
          hint: const Text("Select a service"),
          value: _selectedService,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryColor),
          items: services.map((UserProviderService service) {
            return DropdownMenuItem<UserProviderService>(
              value: service,
              child: Text(service.name),
            );
          }).toList(),
          onChanged: (UserProviderService? value) {
            setState(() {
              _selectedService = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildContactIcons(List<String> access, {required String phoneNumber, required String email}) {
    return Row(
      children: [
        if (access.contains('Call'))
          GestureDetector(
            onTap: () {
              if (phoneNumber.isNotEmpty) {
                _launchPhoneDialer(phoneNumber);
              } else {
                Get.snackbar(
                  "No Phone Number",
                  "Phone number not available",
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.call,
                size: 24,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        if (access.contains('Call') && access.contains('Email'))
          const SizedBox(width: 12),
        if (access.contains('Email'))
          GestureDetector(
            onTap: () {
              if (email.isNotEmpty) {
                _launchEmail(email);
              } else {
                Get.snackbar(
                  "No Email",
                  "Email address not available",
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.email,
                size: 24,
                color: AppColors.primaryColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}