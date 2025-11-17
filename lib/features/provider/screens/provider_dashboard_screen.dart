/**

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import '../../profile/widgets/profile_common_tile.dart';
import '../controllers/provider_controller.dart';
import '../widgets/provider_top_card.dart';
import '../widgets/switch.dart';

class ProviderDashboardScreen extends GetView<ProviderController> {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ReminderController());
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const ProviderTopBar(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: AppSizes.md),
                    ReminderSwitch(label: 'Set Availability', onChange: () {}),
                    const SizedBox(height: AppSizes.md),
                    ProfileCommonTile(
                      onTap: () {
                        Get.toNamed(AppRoutes.providerProfileRoute);
                      },
                      leadingIcon: const Icon(CupertinoIcons.profile_circled, color: Colors.grey),
                      title: 'Business Information',
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
}

*/




///
///
///
///
/// TODO::::: addign the api
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
                      AvailabilitySwitch(label: 'Set Availability'),

                      const SizedBox(height: AppSizes.md),

                      // Business Information Tile
                      ProfileCommonTile(
                        onTap: () {
                          Get.toNamed(AppRoutes.providerProfileRoute);
                        },
                        leadingIcon: Icon(
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








