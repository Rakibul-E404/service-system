
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';
import 'package:manx_mate/core/routes/app_routes.dart';

import '../../../core/utils/api/app_url.dart';
import '../../auth/widgets/custom_text_field.dart';
import '../controllers/search_controller.dart';

class HomeSearchScreen extends GetView<HomeSearchController> {
  HomeSearchScreen({super.key});

  final TextEditingController _searchTEController = TextEditingController();
  final RxString _selectedLocation = 'All Locations'.obs;
  final List<String> _locationOptions = [
    'All Locations',
    'North',
    'South',
    'East',
    'West'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
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
                        Expanded(
                          child: Text("Search", style: context.txtTheme.headlineMedium).centered,
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text('What are you Looking for?', style: context.txtTheme.labelMedium),
                    const SizedBox(height: AppSizes.md),
                    MyTextFormFieldWithIcon(
                      formHintText: "Search by keyword...",
                      prefixIcon: const Icon(CupertinoIcons.search, color: AppColors.primaryColor),
                      controller: _searchTEController,
                      onChanged: (value) {
                        _performSearch();
                      },
                      validator: (String? value) {
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text('Location', style: context.txtTheme.labelMedium),
                    const SizedBox(height: AppSizes.md),
                    Obx(() => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedLocation.value,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
                          items: _locationOptions.map((String location) {
                            return DropdownMenuItem<String>(
                              value: location,
                              child: Text(location),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              _selectedLocation.value = newValue;
                              _performSearch();
                            }
                          },
                        ),
                      ),
                    )),
                    const SizedBox(height: AppSizes.md),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _performSearch,
                            child: const Text("Search"),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        ElevatedButton(
                          onPressed: _clearFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Clear"),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text('Your Search Result', style: context.txtTheme.labelLarge),
                    const SizedBox(height: AppSizes.md),
                  ],
                ),
              ),
            ),

            Obx(() {
              if (controller.isLoading.value) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (controller.error.isNotEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      controller.error.value,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }
              if (controller.filteredServices.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No services found. Try different search terms.')),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 18,
                  childCount: controller.filteredServices.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = controller.filteredServices[index];

                    final String serviceId = item['_id']?.toString() ?? '';
                    final String serviceName = item['name']?.toString() ?? 'No Name';
                    final String serviceDescription = item['description']?.toString() ?? 'No Description';
                    final String serviceLocation = item['location']?.toString() ?? 'No Location';
                    final String serviceImage = item['image']?.toString() ?? '';
                    final double serviceRating = (item['rating']?.toDouble() ?? 0.0);
                    final dynamic author = item['author'];

                    // Build complete image URL
                    final String completeImageUrl = serviceImage.isNotEmpty
                        ? '${AppUrl.imageBaseUrl}/$serviceImage'
                        : '';

                    return GestureDetector(
                      onTap: () {
                        debugPrint('🎯 Navigating to service details');
                        debugPrint('   - Service ID: $serviceId');
                        debugPrint('   - Service Name: $serviceName');
                        debugPrint('   - Image URL: $completeImageUrl');

                        Get.toNamed(
                          AppRoutes.homeServiceDetailsRoute,
                          arguments: {
                            '_id': serviceId,
                            'serviceId': serviceId,
                            'serviceName': serviceName,
                            'serviceDescription': serviceDescription,
                            'serviceLocation': serviceLocation,
                            'serviceImage': completeImageUrl, // Pass complete URL
                            'serviceRating': serviceRating,
                            'author': author,
                            'authorId': author is String ? author : (author is Map ? author['_id'] : null),
                          },
                        );
                      },
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(AppSizes.borderRadiusMd)),
                              child: completeImageUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                imageUrl: completeImageUrl,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                const Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                              )
                                  : Container(
                                height: 150,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, size: 50, color: Colors.grey),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(AppSizes.sm),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item['name'] ?? '',
                                    style: context.txtTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['description'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.txtTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, color: Colors.grey, size: 14),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          item['location'] ?? '',
                                          style: context.txtTheme.labelSmall?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        (item['rating']?.toDouble() ?? 0.0)
                                            .toStringAsFixed(1),
                                        style: context.txtTheme.labelSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (item['price'] != null)
                                        Text(
                                          '\$${item['price']}',
                                          style: context.txtTheme.titleSmall?.copyWith(
                                            color: AppColors.primaryColor,
                                            fontWeight: FontWeight.bold,
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
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _performSearch() {
    final searchKeyword = _searchTEController.text.trim();
    final locationFilter = _selectedLocation.value == 'All Locations' ? '' : _selectedLocation.value;

    controller.searchServices(
      keyword: searchKeyword,
      location: locationFilter,
    );
  }

  void _clearFilters() {
    _searchTEController.clear();
    _selectedLocation.value = 'All Locations';
    controller.clearFilters();
  }
}