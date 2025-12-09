/**

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
}*/












///
///
///
///
///
/// todo::::: updating the forntend design
///
///
///
///
///





/*import 'package:cached_network_image/cached_network_image.dart';
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

class HomeSearchScreen extends StatefulWidget {
  HomeSearchScreen({super.key});

  @override
  State<HomeSearchScreen> createState() => _HomeSearchScreenState();
}

class _HomeSearchScreenState extends State<HomeSearchScreen> {
  final HomeSearchController controller = Get.find<HomeSearchController>();
  final TextEditingController _searchTEController = TextEditingController();
  final RxString _selectedLocation = 'All Locations'.obs;
  final List<String> _locationOptions = [
    'All Locations',
    'North',
    'South',
    'East',
    'West'
  ];

  bool _initialSearchPerformed = false;

  @override
  void initState() {
    super.initState();
    _handleInitialSearchText();
  }

  void _handleInitialSearchText() {
    final arguments = Get.arguments;
    final initialSearchText = arguments?['initialSearchText'] as String?;

    if (initialSearchText != null && initialSearchText.isNotEmpty) {
      _searchTEController.text = initialSearchText;

      Future.delayed(const Duration(milliseconds: 300), () {
        if (!_initialSearchPerformed) {
          _initialSearchPerformed = true;
          _performSearch();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialSearchPerformed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final arguments = Get.arguments;
        final initialSearchText = arguments?['initialSearchText'] as String?;

        if (initialSearchText != null &&
            initialSearchText.isNotEmpty &&
            _searchTEController.text.isEmpty) {
          _searchTEController.text = initialSearchText;
          if (!_initialSearchPerformed) {
            _initialSearchPerformed = true;
            _performSearch();
          }
        }
      });
    }

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
                          onPressed: () => Get.back(),
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
                      validator: (String? value) => null,
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
                    Obx(() {
                      if (_searchTEController.text.isNotEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Search Results for "${_searchTEController.text}"',
                              style: context.txtTheme.labelLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${controller.filteredServices.length} services found',
                              style: context.txtTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        );
                      }
                      return Text('Your Search Results', style: context.txtTheme.labelLarge);
                    }),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.error.value,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _performSearch,
                          child: const Text('Retry Search'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (controller.filteredServices.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No services found for "${_searchTEController.text}"',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try different keywords or location',
                          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
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
                    final serviceId = item['_id']?.toString() ?? '';
                    final serviceName = item['name']?.toString() ?? 'No Name';
                    final serviceDescription = item['description']?.toString() ?? '';
                    final serviceLocation = item['location']?.toString() ?? '';
                    final serviceImage = item['image']?.toString() ?? '';
                    final serviceRating = (item['rating']?.toDouble() ?? 0.0);
                    final author = item['author'];
                    final completeImageUrl = serviceImage.isNotEmpty
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
                                children: [
                                  Text(
                                    serviceName,
                                    style: context.txtTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    serviceDescription,
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
                                          serviceLocation,
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
                                        serviceRating.toStringAsFixed(1),
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

    if (searchKeyword.isEmpty) {
      controller.clearFilters();
      return;
    }

    controller.searchServices(
      keyword: searchKeyword,
      location: locationFilter,
    );
  }

  void _clearFilters() {
    _searchTEController.clear();
    _selectedLocation.value = 'All Locations';
    _initialSearchPerformed = false;
    controller.clearFilters();
    Get.rawSnackbar(
      message: 'Filters cleared',
      backgroundColor: Colors.green,
    );
  }
}*/



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
import 'package:manx_mate/core/utils/api/app_url.dart';
import '../../auth/widgets/custom_text_field.dart';
import '../controllers/search_controller.dart';

class HomeSearchScreen extends StatefulWidget {
  HomeSearchScreen({super.key});

  @override
  State<HomeSearchScreen> createState() => _HomeSearchScreenState();
}

class _HomeSearchScreenState extends State<HomeSearchScreen> {
  final HomeSearchController controller = Get.find<HomeSearchController>();
  final TextEditingController _searchTEController = TextEditingController();
  String _selectedLocation = 'All Locations';
  final List<String> _locationOptions = [
    'All Locations',
    'North',
    'South',
    'East',
    'West'
  ];

  bool _initialSearchPerformed = false;

  @override
  void initState() {
    super.initState();
    _handleInitialSearchText();
  }

  void _handleInitialSearchText() {
    final arguments = Get.arguments;
    final initialSearchText = arguments?['initialSearchText'] as String?;

    if (initialSearchText != null && initialSearchText.isNotEmpty) {
      _searchTEController.text = initialSearchText;

      Future.delayed(const Duration(milliseconds: 300), () {
        if (!_initialSearchPerformed) {
          _initialSearchPerformed = true;
          _performSearch();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialSearchPerformed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final arguments = Get.arguments;
        final initialSearchText = arguments?['initialSearchText'] as String?;

        if (initialSearchText != null &&
            initialSearchText.isNotEmpty &&
            _searchTEController.text.isEmpty) {
          _searchTEController.text = initialSearchText;
          if (!_initialSearchPerformed) {
            _initialSearchPerformed = true;
            _performSearch();
          }
        }
      });
    }

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
                          onPressed: () => Get.back(),
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
                      validator: (String? value) => null,
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text('Location', style: context.txtTheme.labelMedium),
                    const SizedBox(height: AppSizes.md),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedLocation,
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
                              setState(() {
                                _selectedLocation = newValue;
                              });
                              _performSearch();
                            }
                          },
                        ),
                      ),
                    ),
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
                    // FIXED: Using GetBuilder instead of Obx for static content
                    GetBuilder<HomeSearchController>(
                      builder: (controller) {
                        if (_searchTEController.text.isNotEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Search Results for "${_searchTEController.text}"',
                                style: context.txtTheme.labelLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${controller.filteredServices.length} services found',
                                style: context.txtTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          );
                        }
                        return Text('Your Search Results', style: context.txtTheme.labelLarge);
                      },
                    ),
                    const SizedBox(height: AppSizes.md),
                  ],
                ),
              ),
            ),

            // FIXED: Main content section - Using GetBuilder instead of Obx
            GetBuilder<HomeSearchController>(
              builder: (controller) {
                if (controller.isLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (controller.error.isNotEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.error,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _performSearch,
                            child: const Text('Retry Search'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (controller.filteredServices.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            _searchTEController.text.isNotEmpty
                                ? 'No services found for "${_searchTEController.text}"'
                                : 'Search for services using the field above',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try different keywords or location',
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
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
                      final serviceId = item['_id']?.toString() ?? '';
                      final serviceName = item['name']?.toString() ?? 'No Name';
                      final serviceDescription = item['description']?.toString() ?? '';
                      final serviceLocation = item['location']?.toString() ?? '';
                      final serviceImage = item['image']?.toString() ?? '';
                      final serviceRating = (item['rating']?.toDouble() ?? 0.0);
                      final author = item['author'];
                      final completeImageUrl = serviceImage.isNotEmpty
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
                                  children: [
                                    Text(
                                      serviceName,
                                      style: context.txtTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      serviceDescription,
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
                                            serviceLocation,
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
                                          serviceRating.toStringAsFixed(1),
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
              },
            ),
          ],
        ),
      ),
    );
  }

  void _performSearch() {
    final searchKeyword = _searchTEController.text.trim();
    final locationFilter = _selectedLocation == 'All Locations' ? '' : _selectedLocation;

    if (searchKeyword.isEmpty) {
      controller.clearFilters();
      return;
    }

    controller.searchServices(
      keyword: searchKeyword,
      location: locationFilter,
    );
  }

  void _clearFilters() {
    _searchTEController.clear();
    setState(() {
      _selectedLocation = 'All Locations';
    });
    _initialSearchPerformed = false;
    controller.clearFilters();
    Get.rawSnackbar(
      message: 'Filters cleared',
      backgroundColor: Colors.green,
    );
  }
}



