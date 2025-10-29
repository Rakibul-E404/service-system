/*

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/config/app_strings.dart';
import '../../auth/widgets/custom_text_field.dart';
import '../../auth/widgets/service_card.dart';
import '../controllers/sub_categories_controller.dart';

class SubCategoriesPage extends GetView<SubCategoriesController> {
  SubCategoriesPage({super.key});

  final TextEditingController _searchTEController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final String appbarHeading = Get.arguments;
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
                  Expanded(child: Text(appbarHeading, style: context.txtTheme.headlineMedium).centered),
                  const SizedBox(width: 40),
                ],
              ),

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

              // ReusableButton(onTap: () {}, label: "Search"),
              MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 18,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 10,
                itemBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    height: 250,
                    child: ServiceCard(
                      imageUrl:
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=300&fit=crop',
                      title: 'TutorPro Academy',
                      subtitle: 'Experts in Math & Science',
                      location: 'Cork, Ireland',
                      rating: 4.9,
                      isFavorited: isFavorited,
                      onTap: () {
                        Get.toNamed(AppRoutes.homeServiceDetailsRoute);
                      },
                      onFavorite: () {
                        isFavorited = false;
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

*/





import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../auth/widgets/service_card.dart';
import '../controllers/sub_categories_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_strings.dart';
import '../../auth/widgets/custom_text_field.dart';


class SubCategoriesPage extends GetView<SubCategoriesController> {
  SubCategoriesPage({super.key});

  final TextEditingController _searchTEController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Expect arguments as Map
    final Map<String, dynamic> args = Get.arguments as Map<String, dynamic>;
    final String appbarHeading = args['categoryName'] ?? '';
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
                  Expanded(child: Text(appbarHeading, style: context.txtTheme.headlineMedium).centered),
                  const SizedBox(width: 40),
                ],
              ),
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
                onChanged: (String value) {},
              ),
              const SizedBox(height: AppSizes.md),
              MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 18,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 10,
                itemBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    height: 250,
                    child: ServiceCard(
                      imageUrl:
                      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=300&fit=crop',
                      title: 'TutorPro Academy',
                      subtitle: 'Experts in Math & Science',
                      location: 'Cork, Ireland',
                      rating: 4.9,
                      isFavorited: isFavorited,
                      onTap: () {
                        Get.toNamed(AppRoutes.homeServiceDetailsRoute);
                      },
                      onFavorite: () {
                        isFavorited = false;
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
