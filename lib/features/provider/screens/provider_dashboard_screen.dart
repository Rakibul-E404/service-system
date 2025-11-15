
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






///
///
///
///
/// TODO::::: addign the api
///
///
///




