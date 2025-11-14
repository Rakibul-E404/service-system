import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/common/components/custom_network_image.dart';
import 'package:manx_mate/core/common/widgets/reusable_button.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/extensions/date_time_extensions.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/features/auth/widgets/primary_button.dart';
import 'package:manx_mate/features/home/controllers/search_controller.dart';

import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/config/app_strings.dart';
import '../../auth/widgets/custom_text_field.dart';
import '../../auth/widgets/service_card.dart';
import '../widget/reusable_small_card.dart';

class HomeSearchScreen extends GetView<HomeSearchController> {
  HomeSearchScreen({super.key});

  final TextEditingController _searchTEController = TextEditingController();
  final TextEditingController _locationTEController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isFavorited = false;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(CupertinoIcons.back),
                  ),
                  Expanded(child: Text("Search", style: context.txtTheme.headlineMedium).centered),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              Text('What are you Looking for?', style: context.txtTheme.labelMedium),
              const SizedBox(height: AppSizes.md),
              MyTextFormFieldWithIcon(
                formHintText: "Search",
                prefixIcon: const Icon(CupertinoIcons.search, color: AppColors.primaryColor),
                controller: _searchTEController,
                validator: (String? value) {
                  if (value?.isEmpty ?? true) {
                    return '${AppStrings.pleaseEnterYour} ${AppStrings.email}!!';
                  }
                  return null;
                },
                onChanged: (String value) {
                  // print("Email Input: $value");
                },
              ),
              const SizedBox(height: AppSizes.md),
              Text('Location', style: context.txtTheme.labelMedium),
              const SizedBox(height: AppSizes.md),
              MyTextFormFieldWithIcon(
                formHintText: "Enter Your Location",
                prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primaryColor),
                controller: _locationTEController,
                validator: (String? value) {
                  if (value?.isEmpty ?? true) {
                    return '${AppStrings.pleaseEnterYour} ${AppStrings.email}!!';
                  }
                  return null;
                },
                onChanged: (String value) {
                  // print("Email Input: $value");
                },
              ),
              const SizedBox(height: AppSizes.md),
              ReusableButton(onTap: () {}, label: "Search"),
              const SizedBox(height: AppSizes.md),
              Text('Your Search Result', style: context.txtTheme.labelLarge),
              const SizedBox(height: AppSizes.md),

              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.error.isNotEmpty) {
                  return Center(child: Text(controller.error.value, style: const TextStyle(color: Colors.red)));
                }
                if (controller.services.isEmpty) {
                  return const Center(child: Text('No services found.'));
                }
                return MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 18,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.services.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = controller.services[index];
                    return SizedBox(
                      height: 250,
                      child: ServiceCard(
                        imageUrl: 'https://your.domain/${item['image']}', // adapt as per your image URI needs
                        title: item['name'] ?? '',
                        subtitle: item['description'] ?? '',
                        location: item['location'] ?? '',
                        rating: item['rating']?.toDouble() ?? 0.0,
                        isFavorited: false,
                        onTap: () {
                          Get.toNamed(AppRoutes.homeServiceDetailsRoute);
                        },
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}