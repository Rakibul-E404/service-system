/**
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/common/components/custom_network_image.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import '../controllers/provider_details_controller.dart';

class ProviderDetailsScreen extends StatelessWidget {
  const ProviderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final ProviderDetailsController controller = Get.put(ProviderDetailsController());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Obx(() {
          // Show loading state
          if (controller.isLoadingProvider.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: AppSizes.md),
                  Text('Loading provider details...'),
                ],
              ),
            );
          }

          // Show error state
          if (controller.providerErrorMessage.value.isNotEmpty &&
              controller.providerData.value == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      controller.providerErrorMessage.value,
                      textAlign: TextAlign.center,
                      style: context.txtTheme.bodyLarge?.copyWith(
                        color: AppColors.errorColor,
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    ElevatedButton.icon(
                      onPressed: () => controller.retryFetchProvider(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Show provider details
          final provider = controller.providerData.value;
          if (provider == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey),
                  SizedBox(height: AppSizes.md),
                  Text('No provider data available'),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // App Bar with back button
              SliverAppBar(
                backgroundColor: AppColors.backgroundColor,
                leading: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(CupertinoIcons.back,
                      color: AppColors.primaryColor),
                ),
                expandedHeight: context.screenHeight * 0.35,
                flexibleSpace: FlexibleSpaceBar(
                  background: provider.fullImageUrl.isNotEmpty
                      ? CustomCachedImage(
                    imageUrl: provider.fullImageUrl,
                    width: context.screenWidth,
                    height: context.screenHeight * 0.35,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              // Provider Details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.screenHorizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: AppSizes.lg),

                      // Provider Name and Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.name,
                                  style: context.txtTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textBlackColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppSizes.xs),
                                // Rating (if available)
                                if (provider.rating > 0)
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${provider.rating.toStringAsFixed(1)} (${provider.ratingCount} reviews)',
                                        style: context.txtTheme.bodyMedium?.copyWith(
                                          color: AppColors.textBlackColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                // Show "No reviews yet" if rating is 0
                                if (provider.rating == 0)
                                  Text(
                                    'No reviews yet',
                                    style: context.txtTheme.bodyMedium?.copyWith(
                                      color: AppColors.textBlackColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Message Button
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(AppSizes.borderRadiusMd),
                              color: AppColors.primaryColor,
                            ),
                            child: const Row(
                              children: <Widget>[
                                Text(
                                  "Message",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  CupertinoIcons.chat_bubble_text,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSizes.md),

                      // Availability Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: provider.isAvailable
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius:
                          BorderRadius.circular(AppSizes.borderRadiusMd),
                          border: Border.all(
                              color: provider.isAvailable
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.orange.withOpacity(0.3)
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              provider.isAvailable
                                  ? Icons.check_circle_outline
                                  : Icons.info_outline,
                              size: 18,
                              color: provider.isAvailable ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              provider.isAvailable
                                  ? 'Currently Available'
                                  : 'Currently Unavailable',
                              style: TextStyle(
                                color: provider.isAvailable ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSizes.lg),

                      // Description Section
                      if (provider.description.isNotEmpty) ...[
                        Text(
                          'About',
                          style: context.txtTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBlackColor,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSizes.md),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundColor,
                            borderRadius:
                            BorderRadius.circular(AppSizes.borderRadiusMd),
                          ),
                          child: Text(
                            provider.description,
                            style: context.txtTheme.bodyMedium?.copyWith(
                              color: AppColors.textBlackColor,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.lg),
                      ],

                      // Contact Information Section
                      Text(
                        'Contact Information',
                        style: context.txtTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlackColor,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),

                      Container(
                        padding: const EdgeInsets.all(AppSizes.md),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor,
                          borderRadius:
                          BorderRadius.circular(AppSizes.borderRadiusMd),
                        ),
                        child: Column(
                          children: [
                            // Location
                            _buildInfoRow(
                              icon: Icons.location_on_outlined,
                              title: 'Location',
                              value: provider.location,
                            ),
                            const SizedBox(height: AppSizes.md),

                            // Phone
                            if (provider.phone.isNotEmpty)
                              _buildInfoRow(
                                icon: Icons.phone_outlined,
                                title: 'Phone',
                                value: provider.phone,
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSizes.lg),

                      // Profile Status
                      if (!provider.isProfileComplete)
                        Container(
                          padding: const EdgeInsets.all(AppSizes.md),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius:
                            BorderRadius.circular(AppSizes.borderRadiusMd),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.blue[700], size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'This provider is still completing their profile. More information will be available soon.',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: AppSizes.xl),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.primaryColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: AppColors.textBlackColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textBlackColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}





*/








///
///
///
///
/// todo::: addign hte mesage create and the navigaiton
///
///
///
///




import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/common/components/custom_network_image.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import '../../../provider_model.dart';
import '../controllers/provider_details_controller.dart';
import '../../message/controllers/message_controller.dart';

class ProviderDetailsScreen extends StatelessWidget {
  const ProviderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final ProviderDetailsController controller = Get.put(ProviderDetailsController());
    final MessageController messageController = Get.find<MessageController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Obx(() {
          // Show loading state
          if (controller.isLoadingProvider.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: AppSizes.md),
                  Text('Loading provider details...'),
                ],
              ),
            );
          }

          // Show error state
          if (controller.providerErrorMessage.value.isNotEmpty &&
              controller.providerData.value == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      controller.providerErrorMessage.value,
                      textAlign: TextAlign.center,
                      style: context.txtTheme.bodyLarge?.copyWith(
                        color: AppColors.errorColor,
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    ElevatedButton.icon(
                      onPressed: () => controller.retryFetchProvider(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Show provider details
          final provider = controller.providerData.value;
          if (provider == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey),
                  SizedBox(height: AppSizes.md),
                  Text('No provider data available'),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // App Bar with back button
              SliverAppBar(
                backgroundColor: AppColors.backgroundColor,
                leading: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(CupertinoIcons.back,
                      color: AppColors.primaryColor),
                ),
                expandedHeight: context.screenHeight * 0.35,
                flexibleSpace: FlexibleSpaceBar(
                  background: provider.fullImageUrl.isNotEmpty
                      ? CustomCachedImage(
                    imageUrl: provider.fullImageUrl,
                    width: context.screenWidth,
                    height: context.screenHeight * 0.35,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              // Provider Details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.screenHorizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: AppSizes.lg),

                      // Provider Name and Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.name,
                                  style: context.txtTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textBlackColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppSizes.xs),
                                // Rating (if available)
                                if (provider.rating > 0)
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${provider.rating.toStringAsFixed(1)} (${provider.ratingCount} reviews)',
                                        style: context.txtTheme.bodyMedium?.copyWith(
                                          color: AppColors.textBlackColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                // Show "No reviews yet" if rating is 0
                                if (provider.rating == 0)
                                  Text(
                                    'No reviews yet',
                                    style: context.txtTheme.bodyMedium?.copyWith(
                                      color: AppColors.textBlackColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Message Button
                          GestureDetector(
                            onTap: provider.isAvailable
                                ? () => _handleMessageButton(provider, messageController)
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(AppSizes.borderRadiusMd),
                                color: provider.isAvailable
                                    ? AppColors.primaryColor
                                    : AppColors.primaryColor.withOpacity(0.5),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    "Message",
                                    style: TextStyle(
                                      color: provider.isAvailable ? Colors.white : Colors.white.withOpacity(0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    CupertinoIcons.chat_bubble_text,
                                    color: provider.isAvailable ? Colors.white : Colors.white.withOpacity(0.7),
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSizes.md),

                      // Availability Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: provider.isAvailable
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius:
                          BorderRadius.circular(AppSizes.borderRadiusMd),
                          border: Border.all(
                              color: provider.isAvailable
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.orange.withOpacity(0.3)
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              provider.isAvailable
                                  ? Icons.check_circle_outline
                                  : Icons.info_outline,
                              size: 18,
                              color: provider.isAvailable ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              provider.isAvailable
                                  ? 'Currently Available'
                                  : 'Currently Unavailable',
                              style: TextStyle(
                                color: provider.isAvailable ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSizes.lg),

                      // Description Section
                      if (provider.description.isNotEmpty) ...[
                        Text(
                          'About',
                          style: context.txtTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBlackColor,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSizes.md),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundColor,
                            borderRadius:
                            BorderRadius.circular(AppSizes.borderRadiusMd),
                          ),
                          child: Text(
                            provider.description,
                            style: context.txtTheme.bodyMedium?.copyWith(
                              color: AppColors.textBlackColor,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.lg),
                      ],

                      // Contact Information Section
                      Text(
                        'Contact Information',
                        style: context.txtTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlackColor,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),

                      Container(
                        padding: const EdgeInsets.all(AppSizes.md),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor,
                          borderRadius:
                          BorderRadius.circular(AppSizes.borderRadiusMd),
                        ),
                        child: Column(
                          children: [
                            // Location
                            _buildInfoRow(
                              icon: Icons.location_on_outlined,
                              title: 'Location',
                              value: provider.location,
                            ),
                            const SizedBox(height: AppSizes.md),

                            // Phone
                            if (provider.phone.isNotEmpty)
                              _buildInfoRow(
                                icon: Icons.phone_outlined,
                                title: 'Phone',
                                value: provider.phone,
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSizes.lg),

                      // Profile Status
                      if (!provider.isProfileComplete)
                        Container(
                          padding: const EdgeInsets.all(AppSizes.md),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius:
                            BorderRadius.circular(AppSizes.borderRadiusMd),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.blue[700], size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'This provider is still completing their profile. More information will be available soon.',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: AppSizes.xl),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _handleMessageButton(ProviderModel provider, MessageController messageController) {
    messageController.createConversationAndNavigate(
      receiverId: provider.id,
      receiverName: provider.name,
      receiverAvatar: provider.fullImageUrl,
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.primaryColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: AppColors.textBlackColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textBlackColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}