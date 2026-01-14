/**
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';

class FeaturedProvidersSection extends StatelessWidget {
  const FeaturedProvidersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Featured Providers",
            style: context.txtTheme.headlineSmall,
          ),
          const SizedBox(height: AppSizes.sm),
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(5, (int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 150,
                    child: Material(
                      color: Colors.white,
                      elevation: 3,
                      borderRadius:
                      BorderRadius.circular(AppSizes.borderRadiusMd),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {},
                        borderRadius:
                        BorderRadius.circular(AppSizes.borderRadiusMd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(AppSizes.borderRadiusMd)),
                              child: Ink(
                                height: 100,
                                width: double.infinity,
                                color: Colors.white,
                                child: Stack(
                                  children: [
                                    const Center(
                                      child: Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: SvgPicture.asset(
                                        'assets/icons/sponsor_icon.svg',
                                        width: 25,
                                        height: 25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Platform Service Co.",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "Residential Plumbing",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          color: Colors.grey, size: 12),
                                      SizedBox(width: 4),
                                      Text(
                                        "Crock Ireland",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
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
              }),
            ),
          ),
        ],
      ),
    );
  }
}*/














///
///
///
///
///todo:: updatingwiht
///
///
///
///














import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/features/home/controllers/featured_provider_controller.dart';
import 'package:manx_mate/core/common/components/custom_network_image.dart';

import '../../../model/featured_provider_model.dart';

class FeaturedProvidersSection extends StatelessWidget {
  const FeaturedProvidersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final FeaturedProviderController controller = Get.put(FeaturedProviderController());

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Featured Providers",
            style: context.txtTheme.headlineSmall,
          ),
          const SizedBox(height: AppSizes.sm),

          Obx(() {
            if (controller.isLoading.value) {
              return _buildLoadingState();
            }

            if (controller.errorMessage.isNotEmpty) {
              return _buildErrorState(controller, context);
            }

            if (controller.featuredProviders.isEmpty) {
              return _buildEmptyState();
            }

            return _buildProvidersList(controller);
          }),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Loading featured providers...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(FeaturedProviderController controller, BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red[300],
            ),
            const SizedBox(height: AppSizes.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              child: Text(
                controller.errorMessage.value,
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            ElevatedButton(
              onPressed: () => controller.retry(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'No featured providers available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Check back later',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProvidersList(FeaturedProviderController controller) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.featuredProviders.length,
        itemBuilder: (context, index) {
          final provider = controller.featuredProviders[index];
          return _buildProviderCard(controller, provider);
        },
      ),
    );
  }

  Widget _buildProviderCard(FeaturedProviderController controller, FeaturedProviderModel provider) {
    // Get the full image URL using controller method
    final String fullImageUrl = controller.getProviderImageUrl(provider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 150,
        child: Material(
          color: Colors.white,
          elevation: 3,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              // Handle provider tap - navigate to provider details
              debugPrint('Tapped on provider: ${provider.name}');
              debugPrint('Provider image URL: $fullImageUrl');
              // Get.toNamed(AppRoutes.providerDetails, arguments: {'providerId': provider.id});
            },
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Provider Image - KEEP THIS SECTION AS IS
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSizes.borderRadiusMd),
                  ),
                  child: SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        // Provider Image - using the full URL from controller
                        fullImageUrl.isNotEmpty
                            ?
                        // CustomCachedImage(
                        //   imageUrl: fullImageUrl,
                        //   fit: BoxFit.cover,
                        //   width: double.infinity,
                        //   height: double.infinity,
                        // )
                        //     : Container(
                        //   color: Colors.grey[100],
                        //   child: const Center(
                        //     child: Icon(
                        //       Icons.person,
                        //       size: 40,
                        //       color: Colors.grey,
                        //     ),
                        //   ),
                        // ),




                        // Inside the _buildProviderCard method, replace the image section with:
                        Container(
                          height: 100,
                          width: double.infinity,
                          color: Colors.grey[100],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (fullImageUrl.isNotEmpty)
                                Expanded(
                                  child: CustomCachedImage(
                                    imageUrl: fullImageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                )
                              else
                                const Icon(Icons.person, size: 40, color: Colors.grey),

                            ],
                          ),
                        )
                            : Container(
                          color: Colors.grey[100],
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),



                        // Rating Badge
                        if (provider.averageRating != null && provider.totalRatings > 0)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    provider.averageRating!.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '(${provider.totalRatings})',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Featured Badge
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: SvgPicture.asset(
                            'assets/icons/sponsor_icon.svg',
                            width: 25,
                            height: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Provider Info
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Provider Name
                      Text(
                        provider.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Provider Description
                      Text(
                        provider.description.isNotEmpty
                            ? provider.description
                            : 'Professional Service Provider',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Location
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.grey, size: 12),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              provider.region.isNotEmpty
                                  ? '${provider.region[0].toUpperCase()}${provider.region.substring(1)} Region'
                                  : 'Multiple Regions',
                              style: const TextStyle(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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