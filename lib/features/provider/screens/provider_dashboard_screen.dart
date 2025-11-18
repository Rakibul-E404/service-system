/**

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../profile/widgets/profile_common_tile.dart';
import '../controllers/provider_controller.dart';
import '../widgets/provider_top_card.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/routes/app_routes.dart';

class ProviderDashboardScreen extends GetView<ProviderController> {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not already initialized
    if (!Get.isRegistered<ProviderController>()) {
      Get.put(ProviderController());
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.fetchBusinessProfile();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: <Widget>[
                const ProviderTopBar(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.screenHorizontal,
                  ),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: AppSizes.md),

                      // Availability Switch
                      const AvailabilitySwitch(label: 'Set Availability'),

                      const SizedBox(height: AppSizes.md),

                      // Business Information Tile
                      ProfileCommonTile(
                        onTap: () {
                          Get.toNamed(AppRoutes.providerProfileRoute);
                        },
                        leadingIcon: const Icon(
                          CupertinoIcons.profile_circled,
                          color: Colors.grey,
                        ),
                        title: 'Business Information',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AvailabilitySwitch extends StatelessWidget {
  final String label;

  const AvailabilitySwitch({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProviderController controller = Get.find<ProviderController>();

    return Obx(() {
      return Opacity(
        opacity: controller.isLoading.value ? 0.6 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: controller.isLoading.value ? Colors.grey : Colors.black,
                  ),
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Switch(
                    value: controller.isAvailable.value,
                    onChanged: controller.isLoading.value
                        ? null
                        : (value) => controller.updateAvailability(value),
                    activeColor: AppColors.primaryColor,
                    inactiveThumbColor: AppColors.greyColor,
                    inactiveTrackColor: AppColors.whiteColor,
                  ),
                  if (controller.isLoading.value)
                    Positioned(
                      child: Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(left: 30),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}








*/





import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../profile/widgets/profile_common_tile.dart';
import '../controllers/provider_controller.dart';
import '../widgets/provider_top_card.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/routes/app_routes.dart';

class ProviderDashboardScreen extends GetView<ProviderController> {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ProviderController>()) {
      Get.put(ProviderController());
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.fetchBusinessProfile();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: <Widget>[
                const ProviderTopBar(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.screenHorizontal,
                  ),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: AppSizes.md),

                      // Availability Switch
                      const AvailabilitySwitch(label: 'Set Availability'),

                      const SizedBox(height: AppSizes.md),

                      // Business Information Tile
                      ProfileCommonTile(
                        onTap: () {
                          Get.toNamed(AppRoutes.providerProfileRoute);
                        },
                        leadingIcon: const Icon(
                          CupertinoIcons.profile_circled,
                          color: Colors.grey,
                        ),
                        title: 'Business Information',
                      ),

                      const SizedBox(height: AppSizes.md),

                      // Advertisement Section Header
                      _buildSectionHeader('Advertisement'),

                      const SizedBox(height: AppSizes.sm),

                      // Create Advertisement Card
                      _buildAdvertisementCard(
                        icon: Icons.campaign_rounded,
                        title: 'Create New Ad',
                        description: 'Promote your services to reach more customers',
                        buttonText: 'Create Now',
                        onTap: () {
                          _showCreateAdDialog(context);
                        },
                        color: AppColors.primaryColor,
                      ),

                      const SizedBox(height: AppSizes.md),

                      // Active Advertisements
                      Obx(() => controller.activeAds.isNotEmpty
                          ? _buildActiveAdsSection()
                          : _buildNoAdsPlaceholder()),

                      const SizedBox(height: AppSizes.md),

                      // Quick Stats
                      // _buildAdvertisementStats(),

                      const SizedBox(height: AppSizes.md),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Icon(
          Icons.campaign_rounded,
          color: AppColors.primaryColor,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAdvertisementCard({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildNoAdsPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No Active Advertisements',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first advertisement to reach more customers',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveAdsSection() {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Advertisements (${controller.activeAdsCount.value})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...controller.activeAds.map((ad) => _buildAdItem(ad)),
      ],
    ));
  }

  Widget _buildAdItem(Map<String, dynamic> ad) {
    bool isActive = ad['isActive'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryColor : Colors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ad['title'] ?? 'Advertisement',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Views: ${ad['views'] ?? 0} • Clicks: ${ad['clicks'] ?? 0}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              controller.toggleAdStatus(ad['id']);
            },
            icon: Icon(
              isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
              color: isActive ? Colors.orange.shade600 : Colors.green.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildAdvertisementStats() {
  //   return Obx(() => Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: AppColors.primaryColor.withOpacity(0.05),
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       children: [
  //         _buildStatItem('Total Views', '${controller.totalAdViews}', Icons.visibility_outlined),
  //         _buildStatItem('Total Clicks', '${controller.totalAdClicks}', Icons.touch_app_outlined),
  //         _buildStatItem('Active Ads', '${controller.activeAdsCount}', Icons.campaign_outlined),
  //       ],
  //     ),
  //   ));
  // }

  // Widget _buildStatItem(String label, String value, IconData icon) {
  //   return Column(
  //     children: [
  //       Container(
  //         padding: const EdgeInsets.all(8),
  //         decoration: BoxDecoration(
  //           color: AppColors.primaryColor.withOpacity(0.1),
  //           shape: BoxShape.circle,
  //         ),
  //         child: Icon(icon, size: 20, color: AppColors.primaryColor),
  //       ),
  //       const SizedBox(height: 8),
  //       Text(
  //         value,
  //         style: const TextStyle(
  //           fontSize: 16,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       Text(
  //         label,
  //         style: TextStyle(
  //           fontSize: 12,
  //           color: Colors.grey.shade600,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  void _showCreateAdDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Advertisement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.local_offer, color: AppColors.primaryColor),
              title: const Text('Promotional Offer'),
              subtitle: const Text('Discounts and special offers'),
              onTap: () {
                Get.back();
                _showAdCreationForm('offer');
              },
            ),
            ListTile(
              leading: Icon(Icons.business, color: AppColors.primaryColor),
              title: const Text('Service Highlight'),
              subtitle: const Text('Showcase your best services'),
              onTap: () {
                Get.back();
                _showAdCreationForm('service');
              },
            ),
            ListTile(
              leading: Icon(Icons.event, color: AppColors.primaryColor),
              title: const Text('Event Promotion'),
              subtitle: const Text('Promote events and workshops'),
              onTap: () {
                Get.back();
                _showAdCreationForm('event');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAdCreationForm(String adType) {
    Get.snackbar(
      'Coming Soon',
      'Advertisement creation feature will be available soon!',
      backgroundColor: AppColors.primaryColor,
      colorText: Colors.white,
    );
  }
}

class AvailabilitySwitch extends StatelessWidget {
  final String label;

  const AvailabilitySwitch({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProviderController controller = Get.find<ProviderController>();

    return Obx(() {
      return Opacity(
        opacity: controller.isLoading.value ? 0.6 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: controller.isLoading.value ? Colors.grey : Colors.black,
                  ),
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Switch(
                    value: controller.isAvailable.value,
                    onChanged: controller.isLoading.value
                        ? null
                        : (value) => controller.updateAvailability(value),
                    activeColor: AppColors.primaryColor,
                    inactiveThumbColor: AppColors.greyColor,
                    inactiveTrackColor: AppColors.whiteColor,
                  ),
                  if (controller.isLoading.value)
                    Positioned(
                      child: Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(left: 30),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}