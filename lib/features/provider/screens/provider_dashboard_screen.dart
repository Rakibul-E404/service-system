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
    if (!Get.isRegistered<ProviderController>()) {
      Get.put(ProviderController());
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.refreshData();
          },
          child: Obx(() => Stack(
            children: [
              SingleChildScrollView(
                physics: controller.showAdCreationScreen.value
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(),
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
                              controller.showAdCreationScreen.value = true;
                            },
                            color: AppColors.primaryColor,
                          ),

                          const SizedBox(height: AppSizes.md),

                          // Active Advertisements Section
                          _buildAdsSection(),

                          const SizedBox(height: AppSizes.md),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Ad Creation Screen Overlay
              if (controller.showAdCreationScreen.value)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AdCreationScreen(),
                ),
            ],
          )),
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

  Widget _buildAdsSection() {
    return Obx(() {
      if (controller.isLoadingAds.value) {
        return _buildAdsLoadingState();
      }

      if (controller.activeAds.isEmpty) {
        return _buildNoAdsPlaceholder();
      }

      return _buildActiveAdsSection();
    });
  }

  Widget _buildAdsLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Column(
        children: [
          SizedBox(height: 16),
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading advertisements...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
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
    return Column(
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
    );
  }

  Widget _buildAdItem(Map<String, dynamic> ad) {
    bool isActive = ad['isActive'] ?? false;
    String? imageUrl = ad['image'];
    String description = ad['description'] ?? 'No description available';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator
          Container(
            width: 4,
            height: 80,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryColor : Colors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),

          // Ad Image
          if (imageUrl != null && imageUrl.isNotEmpty)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          else
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: const Center(
                child: Icon(
                  Icons.campaign,
                  color: Colors.grey,
                  size: 30,
                ),
              ),
            ),

          const SizedBox(width: 12),

          // Ad Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ad['title'] ?? 'Advertisement',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              ],
            ),
          ),



        ],
      ),
    );
  }

}

class AdCreationScreen extends StatelessWidget {
  AdCreationScreen({super.key});

  final ProviderController controller = Get.find<ProviderController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: controller.closeAdCreationScreen,
        ),
        title: const Text(
          'Create Advertisement',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isCreatingAd.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Creating your advertisement...'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload Section
              _buildUploadSection(),

              const SizedBox(height: 24),

              // Ads Title
              _buildTextField(
                controller: controller.adTitleController,
                label: 'Ads Title',
                hintText: 'Enter your advertisement title',
              ),

              const SizedBox(height: 16),

              // Ads Description
              _buildTextField(
                controller: controller.adDescController,
                label: 'Ads Desc',
                hintText: 'Enter your advertisement description',
                maxLines: 4,
              ),

              const SizedBox(height: 32),

              // Publish Button
              _buildPublishButton(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildUploadSection() {
    return Obx(() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          const Text(
            'Drop your files here.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildUploadButton(
                icon: Icons.image,
                label: 'Upload image',
                onTap: controller.pickAdImage,
                isSelected: controller.selectedAdImage.value != null,
              ),
              _buildUploadButton(
                icon: Icons.videocam,
                label: 'Upload video',
                onTap: controller.pickAdVideo,
                isSelected: controller.selectedAdVideo.value != null,
              ),
            ],
          ),

          // Selected files preview
          if (controller.selectedAdImage.value != null || controller.selectedAdVideo.value != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _buildSelectedFilesPreview(),
            ),
        ],
      ),
    ));
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
            ),
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: isSelected ? AppColors.primaryColor : Colors.grey.shade600,
              size: 28,
            ),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedFilesPreview() {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selected files:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        if (controller.selectedAdImage.value != null)
          _buildFileItem(
            controller.selectedAdImage.value!.name,
            Icons.image,
            Colors.blue,
            onDelete: () => controller.selectedAdImage.value = null,
          ),
      ],
    ));
  }

  Widget _buildFileItem(String fileName, IconData icon, Color color, {VoidCallback? onDelete}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              fileName,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPublishButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (controller.validateAdForm()) {
            controller.createNewAd(controller.prepareAdData());
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Publish',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
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
                        child: const CircularProgressIndicator(
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
}*/






///
///
///
///
/// todo::: removing the loadign the availablity button
///
///
///



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
            await controller.refreshData();
          },
          child: Obx(() => Stack(
            children: [
              SingleChildScrollView(
                physics: controller.showAdCreationScreen.value
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(),
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
                              controller.showAdCreationScreen.value = true;
                            },
                            color: AppColors.primaryColor,
                          ),

                          const SizedBox(height: AppSizes.md),

                          // Active Advertisements Section
                          _buildAdsSection(),

                          const SizedBox(height: AppSizes.md),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Ad Creation Screen Overlay
              if (controller.showAdCreationScreen.value)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AdCreationScreen(),
                ),
            ],
          )),
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

  Widget _buildAdsSection() {
    return Obx(() {
      if (controller.isLoadingAds.value) {
        return _buildAdsLoadingState();
      }

      if (controller.activeAds.isEmpty) {
        return _buildNoAdsPlaceholder();
      }

      return _buildActiveAdsSection();
    });
  }

  Widget _buildAdsLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Column(
        children: [
          SizedBox(height: 16),
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading advertisements...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
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
    return Column(
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
    );
  }

  Widget _buildAdItem(Map<String, dynamic> ad) {
    bool isActive = ad['isActive'] ?? false;
    String? imageUrl = ad['image'];
    String description = ad['description'] ?? 'No description available';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator
          Container(
            width: 4,
            height: 80,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryColor : Colors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),

          // Ad Image
          if (imageUrl != null && imageUrl.isNotEmpty)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          else
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: const Center(
                child: Icon(
                  Icons.campaign,
                  color: Colors.grey,
                  size: 30,
                ),
              ),
            ),

          const SizedBox(width: 12),

          // Ad Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ad['title'] ?? 'Advertisement',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              ],
            ),
          ),



        ],
      ),
    );
  }

}

class AdCreationScreen extends StatelessWidget {
  AdCreationScreen({super.key});

  final ProviderController controller = Get.find<ProviderController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: controller.closeAdCreationScreen,
        ),
        title: const Text(
          'Create Advertisement',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isCreatingAd.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Creating your advertisement...'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload Section
              _buildUploadSection(),

              const SizedBox(height: 24),

              // Ads Title
              _buildTextField(
                controller: controller.adTitleController,
                label: 'Ads Title',
                hintText: 'Enter your advertisement title',
              ),

              const SizedBox(height: 16),

              // Ads Description
              _buildTextField(
                controller: controller.adDescController,
                label: 'Ads Desc',
                hintText: 'Enter your advertisement description',
                maxLines: 4,
              ),

              const SizedBox(height: 32),

              // Publish Button
              _buildPublishButton(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildUploadSection() {
    return Obx(() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          const Text(
            'Drop your files here.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildUploadButton(
                icon: Icons.image,
                label: 'Upload image',
                onTap: controller.pickAdImage,
                isSelected: controller.selectedAdImage.value != null,
              ),
              _buildUploadButton(
                icon: Icons.videocam,
                label: 'Upload video',
                onTap: controller.pickAdVideo,
                isSelected: controller.selectedAdVideo.value != null,
              ),
            ],
          ),

          // Selected files preview
          if (controller.selectedAdImage.value != null || controller.selectedAdVideo.value != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _buildSelectedFilesPreview(),
            ),
        ],
      ),
    ));
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
            ),
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: isSelected ? AppColors.primaryColor : Colors.grey.shade600,
              size: 28,
            ),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedFilesPreview() {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selected files:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        if (controller.selectedAdImage.value != null)
          _buildFileItem(
            controller.selectedAdImage.value!.name,
            Icons.image,
            Colors.blue,
            onDelete: () => controller.selectedAdImage.value = null,
          ),
      ],
    ));
  }

  Widget _buildFileItem(String fileName, IconData icon, Color color, {VoidCallback? onDelete}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              fileName,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPublishButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (controller.validateAdForm()) {
            controller.createNewAd(controller.prepareAdData());
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Publish',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
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
      return Container(
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
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            Switch(
              value: controller.isAvailable.value,
              onChanged: (value) => controller.updateAvailability(value),
              activeColor: AppColors.primaryColor,
              inactiveThumbColor: AppColors.greyColor,
              inactiveTrackColor: AppColors.whiteColor,
            ),
          ],
        ),
      );
    });
  }
}