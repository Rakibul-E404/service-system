import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';

import '../../../core/common/components/custom_network_image.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../auth/widgets/service_card.dart';
import '../controllers/provider_details_controller.dart';

class ProviderDetailsScreen extends GetView<ProviderDetailsController> {
  const ProviderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(CupertinoIcons.back),
              ),

              ///====================> Main Body ================>
              const SizedBox(height: AppSizes.md),
              CustomCachedImage(
                imageUrl: 'imageUrl',
                width: context.screenWidth,
                height: context.screenHeight * 0.4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("James jayan", style: context.txtTheme.labelLarge),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                      color: AppColors.primaryColor,
                    ),
                    child: const Row(
                      children: <Widget>[Text("Message"), Icon(CupertinoIcons.chat_bubble_text)],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.sm),
              const Text(
                "I provide expert tutoring in Math and Science, tailored to your needs.From basics to advanced topics, I simplify complex concepts.",
              ),
              const Row(
                children: <Widget>[Icon(Icons.location_on_outlined), Text("Cork, Ireland")],
              ),
              const SizedBox(height: AppSizes.md),
              Text("Provided Services", style: context.txtTheme.titleLarge),
              const SizedBox(height: AppSizes.sm),
              Row(
                spacing: 8,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.md,
                      ),
                      child: const Column(
                        children: <Widget>[
                          CustomCachedImage(imageUrl: '', height: 100, fit: BoxFit.contain),
                          Text("Tutors"),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.md,
                      ),
                      child: const Column(
                        children: <Widget>[
                          CustomCachedImage(imageUrl: '', height: 100, fit: BoxFit.contain),
                          Text("Tutors"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              Text("Past Services", style: context.txtTheme.titleLarge),
              const SizedBox(height: AppSizes.sm),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 20,
                itemBuilder: (BuildContext context, int index) {
                  return ServiceCard(
                    height: context.screenHeight * 0.25,
                    width: double.infinity,

                    imageUrl:
                        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=300&fit=crop',
                    title: 'TutorPro Academy',
                    subtitle: 'Experts in Math & Science',
                    location: 'Cork, Ireland',
                    rating: 4.9,
                    isFavorited: false,
                    onTap: () {
                      Get.toNamed(AppRoutes.homeServiceDetailsRoute);
                    },
                    onFavorite: () {},
                  );
                },

                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: AppSizes.md);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
