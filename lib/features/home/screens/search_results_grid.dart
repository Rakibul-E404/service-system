import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import '../controllers/search_controller.dart';

class SearchResultsGrid extends StatelessWidget {
  final List<Map<String, dynamic>> dummyServices;
  final TextEditingController searchTEController;
  final bool initialSearchPerformed;
  final HomeSearchController controller;
  final VoidCallback onSeeAll;

  const SearchResultsGrid({
    super.key,
    required this.dummyServices,
    required this.searchTEController,
    required this.initialSearchPerformed,
    required this.controller,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeSearchController>(
      builder: (HomeSearchController ctrl) {
        final bool showDummyData = !initialSearchPerformed &&
            ctrl.filteredServices.isEmpty &&
            searchTEController.text.isEmpty;

        final List<dynamic> displayServices = showDummyData
            ? dummyServices
            : ctrl.filteredServices;

        if (ctrl.isLoading && !showDummyData) {
          return const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()));
        }

        if (ctrl.error.isNotEmpty && !showDummyData) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(ctrl.error, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: () {}, child: const Text('Retry Search')),
                ],
              ),
            ),
          );
        }

        if (displayServices.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    searchTEController.text.isNotEmpty
                        ? 'No services found for "${searchTEController.text}"'
                        : 'Search for services using the filters above',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text('Try different keywords or filters',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                ],
              ),
            ),
          );
        }

        final visibleServices = displayServices.take(4).toList();

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              crossAxisSpacing: 18,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
              mainAxisExtent: 270,
            ),
            itemCount: visibleServices.length,
            itemBuilder: (BuildContext context, int index) {
              final item = visibleServices[index];
              return _buildServiceCard(item, showDummyData);
            },
          ),
        );
      },
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> item, bool showDummyData) {
    final serviceId = item['_id']?.toString() ?? '';
    final serviceName = item['name']?.toString() ?? 'No Name';
    final serviceDescription = item['description']?.toString() ?? '';
    final serviceLocation = item['location']?.toString() ?? '';
    final serviceImage = item['image']?.toString() ?? '';
    final serviceRating = (item['rating']?.toDouble() ?? 0.0);
    final author = item['author'];
    final completeImageUrl = serviceImage.isNotEmpty &&
        serviceImage.startsWith('http')
        ? serviceImage
        : serviceImage.isNotEmpty
        ? '${AppUrl.imageBaseUrl}/$serviceImage'
        : '';

    return GestureDetector(
      onTap: () {
        if (!showDummyData) {
          Get.toNamed(
            AppRoutes.homeServiceDetailsRoute,
            arguments: {
              '_id': serviceId,
              'serviceId': serviceId,
              'serviceName': serviceName,
              'serviceDescription': serviceDescription,
              'serviceLocation': serviceLocation,
              'serviceImage': completeImageUrl,
              'serviceRating': serviceRating,
              'author': author,
              'authorId': author is String
                  ? author
                  : (author is Map ? author['_id'] : null),
            },
          );
        } else {
          Get.snackbar(
            'Demo Mode',
            'This is sample data. Perform a real search to see actual services.',
            backgroundColor: Colors.blue,
            colorText: Colors.white,
          );
        }
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSizes.borderRadiusMd)),
              child: completeImageUrl.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: completeImageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (BuildContext context, String url) =>
                    Container(
                      height: 120,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                errorWidget: (BuildContext context, String url,
                    Object error) =>
                    Container(
                      height: 120,
                      color: Colors.grey[200],
                      child:
                      const Icon(Icons.error, size: 40, color: Colors.grey),
                    ),
              )
                  : Container(
                height: 120,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 40, color: Colors.grey),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          serviceDescription,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.grey, size: 12),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                serviceLocation,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              serviceRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            if (item['price'] != null)
                              Text(
                                '\$${item['price']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}