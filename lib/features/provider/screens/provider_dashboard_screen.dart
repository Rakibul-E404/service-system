

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/features/provider/screens/publish_advertisement_screen.dart';
import '../../auth/screens/profile_service.dart';
import '../../profile/widgets/profile_common_tile.dart';
import '../controllers/add_list_controller.dart';
import '../controllers/create_add_controller.dart';
import '../controllers/provider_controller.dart';
import '../controllers/provider_profile_controller.dart';
import '../widgets/provider_top_card.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/routes/app_routes.dart';


class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  // Local state for the overlay
  bool isOverlayOpen = false;
  final AdsListController adsController = Get.put(AdsListController());

  @override
  void initState() {
    super.initState();
    // Fetch ads immediately when dashboard opens
    adsController.fetchSelfAds();
  }

  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(ProviderProfileController());
    final profileService = Get.find<ProfileService>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await profileController.fetchBusinessProfile();
            await adsController.fetchSelfAds();
          },
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const ProviderTopBar(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 20),
                          ProfileCommonTile(
                            onTap: () {
                              profileService.setProviderProfileMode(true);
                              Get.toNamed(AppRoutes.providerProfileRoute);
                            },
                            leadingIcon: const Icon(CupertinoIcons.profile_circled, color: Colors.grey),
                            title: 'Business Information',
                          ),
                          const SizedBox(height: 20),
                          _buildSectionHeader('Advertisement'),
                          const SizedBox(height: 10),

                          // --- CREATE NOW BUTTON LOGIC ---
                          Obx(() {
                            final bool hasAdAccess = profileController.subscriptionAccess.contains('Adds');
                            // Check if there is already an advertisement in the list
                            final bool hasExistingAd = adsController.adsList.isNotEmpty;

                            return _buildAdvertisementCard(
                              icon: Icons.campaign_rounded,
                              // Change title based on existence of an ad
                              title: hasExistingAd ? 'Current Advertisement' : 'Create New Ad',
                              description: hasAdAccess
                                  ? (hasExistingAd
                                  ? 'You have an active ad. You can view or update it here.'
                                  : 'Promote your services to reach more customers')
                                  : 'Upgrade your plan to create advertisements',

                              // Change button text based on existence of an ad
                              buttonText: hasExistingAd ? 'View Ad' : 'Create Now',

                              onTap: hasAdAccess
                                  ? () => Get.to(() => const PublishAdvertisementScreen())
                                  : () => Get.snackbar(
                                'Access Denied',
                                'Your current plan does not support Ads.',
                                backgroundColor: Colors.orange,
                                colorText: Colors.white,
                              ),
                              color: hasAdAccess ? AppColors.primaryColor : Colors.grey,
                            );
                          }),
                          const SizedBox(height: 20),

                        ],
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  // --- UI Helpers (Headers and Cards) ---
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Icon(Icons.campaign_rounded, color: AppColors.primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}





