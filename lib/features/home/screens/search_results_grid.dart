
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/home_search_controller.dart';

class SearchResultsHeader extends StatelessWidget {
  final TextEditingController searchTEController;
  final bool initialSearchPerformed;
  final HomeSearchController controller;
  final VoidCallback onSeeAll;

  const SearchResultsHeader({
    super.key,
    required this.searchTEController,
    required this.initialSearchPerformed,
    required this.controller,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeSearchController>(
      builder: (HomeSearchController ctrl) {
        final bool hasSearchQuery = searchTEController.text.isNotEmpty;
        final bool showInitialState = !initialSearchPerformed && !hasSearchQuery;

        // Don't show header when loading initially
        if (ctrl.isLoading && ctrl.filteredServices.isEmpty) {
          return const SizedBox.shrink();
        }

        // Don't show header when there's no search query and no initial search
        if (showInitialState && ctrl.filteredServices.isEmpty) {
          return const SizedBox.shrink();
        }

        final bool hasResults = ctrl.filteredServices.isNotEmpty;
        final bool shouldShowSeeAll = hasResults && ctrl.filteredServices.length > 4;

        return Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md, vertical: AppSizes.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hasSearchQuery
                    ? 'Search Results (${ctrl.filteredServices.length})'
                    : 'All Services (${ctrl.totalServices})',
                style: context.txtTheme.headlineSmall,
              ),
              if (shouldShowSeeAll)
                TextButton(
                  onPressed: onSeeAll,
                  child: Text(
                    "See All",
                    style: context.txtTheme.bodySmall?.copyWith(
                      color: AppColors.primaryColor,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primaryColor,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class SearchResultsGrid extends StatelessWidget {
  final TextEditingController searchTEController;
  final bool initialSearchPerformed;
  final HomeSearchController controller;
  final VoidCallback onSeeAll;

  const SearchResultsGrid({
    super.key,
    required this.searchTEController,
    required this.initialSearchPerformed,
    required this.controller,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeSearchController>(
      builder: (HomeSearchController ctrl) {
        final bool hasSearchQuery = searchTEController.text.isNotEmpty;
        final bool showInitialState = !initialSearchPerformed && !hasSearchQuery;

        // Initial loading state
        if (ctrl.isLoading && ctrl.filteredServices.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // Loading more state
        if (ctrl.isLoadingMore) {
          return SliverList(
            delegate: SliverChildListDelegate([
              _buildServicesGrid(ctrl),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              ),
            ]),
          );
        }

        // Error state
        if (ctrl.error.isNotEmpty && ctrl.filteredServices.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      ctrl.error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ctrl.fetchServices(refresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty state
        if (ctrl.filteredServices.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasSearchQuery ? Icons.search_off : Icons.inbox_outlined,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    hasSearchQuery
                        ? 'No results for "${searchTEController.text}"'
                        : 'No services available yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (!hasSearchQuery)
                    ElevatedButton(
                      onPressed: () => ctrl.fetchServices(refresh: true),
                      child: const Text('Refresh'),
                    ),
                ],
              ),
            ),
          );
        }

        // Show services grid
        return _buildServicesGrid(ctrl);
      },
    );
  }

  Widget _buildServicesGrid(HomeSearchController ctrl) {
    final visibleServices = ctrl.filteredServices.length > 4
        ? ctrl.filteredServices.take(4).toList()
        : ctrl.filteredServices;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          crossAxisSpacing: 18,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
          mainAxisExtent: 270,
        ),
        delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
            final item = visibleServices[index] as Map<String, dynamic>;
            return _buildServiceCard(item);
          },
          childCount: visibleServices.length,
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> item) {
    final serviceId = item['_id']?.toString() ?? '';
    final serviceName = item['name']?.toString() ?? 'No Name';
    final serviceDescription = item['description']?.toString() ?? '';
    final serviceLocation = item['location']?.toString() ?? '';
    final serviceImage = item['image']?.toString() ?? '';
    final serviceRating = (item['rating']?.toDouble() ?? 0.0);
    final servicePrice = item['price']?.toString() ?? '99.99';
    final author = item['author'];

    final completeImageUrl = serviceImage.isNotEmpty && serviceImage.startsWith('http')
        ? serviceImage
        : serviceImage.isNotEmpty
        ? '${AppUrl.imageBaseUrl}/$serviceImage'
        : '';

    return GestureDetector(
      onTap: () {
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
            'servicePrice': servicePrice,
            'author': author,
            'authorId': author is String
                ? author
                : (author is Map ? author['_id'] : null),
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
                      child: const Icon(Icons.error, size: 40, color: Colors.grey),
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
                        const SizedBox(height: 6),
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
                      ],
                    ),
                    const SizedBox(height: 8),
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
                        Text(
                          '\$$servicePrice',
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}









