
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../auth/widgets/service_card.dart';
import '../controllers/service_controller.dart';
import '../../favorite/controllers/favorite_controller.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  late final ServicesController servicesController;
  late final FavoriteController favoriteController;

  String subCategoryName = 'Services';
  String subCategoryId = '';
  String categoryId = '';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    servicesController = Get.put(ServicesController());
    favoriteController = Get.put(FavoriteController());

    // Get arguments
    final dynamic args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      subCategoryName = args['subCategoryName']?.toString() ?? 'Services';
      subCategoryId = args['subCategoryId']?.toString() ?? '';
      categoryId = args['categoryId']?.toString() ?? '';
    }

    debugPrint('🚀 ========== SERVICES PAGE INIT ==========');
    debugPrint('📥 subCategoryName: "$subCategoryName"');
    debugPrint('📥 subCategoryId: "$subCategoryId"');
    debugPrint('📥 categoryId: "$categoryId"');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Fetch services after the first frame if not already initialized
    if (!_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchServicesIfNeeded();
        _initialized = true;
      });
    }
  }

  void _fetchServicesIfNeeded() {
    debugPrint('🎯 PostFrameCallback executing...');
    debugPrint('   - subCategoryId.isNotEmpty: ${subCategoryId.isNotEmpty}');
    debugPrint('   - services.isEmpty: ${servicesController.services.isEmpty}');
    debugPrint('   - isLoadingServices: ${servicesController.isLoadingServices.value}');

    if (subCategoryId.isNotEmpty &&
        servicesController.services.isEmpty &&
        !servicesController.isLoadingServices.value) {
      debugPrint('✅ Conditions met - fetching services...');
      _fetchServices();
    } else {
      debugPrint('⏭️ Skipping fetch - conditions not met');
    }
  }

  void _fetchServices() {
    if (categoryId.isNotEmpty) {
      // Use both category and subcategory
      debugPrint('🔧 Using category + subcategory API');
      servicesController.fetchServicesByCategoryAndSubCategory(
        categoryId,
        subCategoryId,
        subCategoryName,
      );
    } else {
      // Use only subcategory (category might be optional or not available)
      debugPrint('🔧 Using subcategory-only API');
      servicesController.fetchServicesBySubCategoryOnly(
        subCategoryId,
        subCategoryName,
      );
    }
  }

  void _retryFetch() {
    debugPrint('🔄 Retry fetch called');
    if (categoryId.isNotEmpty) {
      debugPrint('🔧 Retrying with category + subcategory API');
      servicesController.retryServicesWithCategoryAndSubCategory(
        categoryId,
        subCategoryId,
        subCategoryName,
      );
    } else {
      debugPrint('🔧 Retrying with subcategory-only API');
      servicesController.retryServicesWithSubCategoryOnly(
        subCategoryId,
        subCategoryName,
      );
    }
  }

  void _loadMoreServices() {
    debugPrint('📥 Loading more services...');
    servicesController.loadMoreServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subCategoryName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final isLoading = servicesController.isLoadingServices.value;
        final isLoadingMore = servicesController.isLoadingMore.value;
        final errorMsg = servicesController.servicesErrorMessage.value;
        final servicesList = servicesController.services.toList();
        final hasMore = servicesController.hasMore.value;
        final totalServices = servicesController.totalServices.value;

        debugPrint('🔄 ========== OBX REBUILD ==========');
        debugPrint('   - isLoading: $isLoading');
        debugPrint('   - isLoadingMore: $isLoadingMore');
        debugPrint('   - errorMsg: "$errorMsg"');
        debugPrint('   - services.length: ${servicesList.length}');
        debugPrint('   - hasMore: $hasMore');
        debugPrint('   - totalServices: $totalServices');

        // Loading state (initial load)
        if (isLoading && servicesList.isEmpty) {
          debugPrint('📊 Showing loading indicator');
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading services...'),
                ],
              ),
            ),
          );
        }

        // Error state
        if (errorMsg.isNotEmpty && servicesList.isEmpty) {
          debugPrint('❌ Showing error: $errorMsg');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    errorMsg,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        }

        // Empty state
        if (servicesList.isEmpty) {
          debugPrint('📭 Showing empty state');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'No services available',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'for $subCategoryName',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    debugPrint('🔄 Retry button pressed from empty state');
                    _fetchServices();
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        // Services list with pagination
        debugPrint('📋 Showing ${servicesList.length} services (Total: $totalServices)');
        return Column(
          children: [
            // Total count indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${servicesList.length} of $totalServices services',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  if (isLoadingMore)
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: servicesList.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // Load more indicator
                  if (hasMore && index == servicesList.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: isLoadingMore
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                          onPressed: _loadMoreServices,
                          child: const Text('Load More Services'),
                        ),
                      ),
                    );
                  }

                  // Service card
                  try {
                    final service = servicesList[index];

                    debugPrint('🎯 Building card $index: ${service.name}');
                    debugPrint('   - Service ID: ${service.id}');
                    debugPrint('   - Image URL: ${service.fullImageUrl}');
                    debugPrint('   - Location: ${service.location}');
                    debugPrint('   - Rating: ${service.rating}');

                    return Obx(() {
                      final bool isFavorited = favoriteController.isFavorited(service.id);
                      final bool isLoadingFav = favoriteController.isFavoriteLoading(service.id);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Opacity(
                          opacity: isLoadingFav ? 0.6 : 1.0,
                          child: ServiceCard(
                            imageUrl: service.fullImageUrl.isNotEmpty
                                ? service.fullImageUrl
                                : 'https://via.placeholder.com/150',
                            title: service.name.isNotEmpty
                                ? service.name
                                : 'Unnamed Service',
                            subtitle: service.description.isNotEmpty
                                ? service.description
                                : 'No description available',
                            location: service.location.isNotEmpty
                                ? service.location
                                : 'Location not specified',
                            rating: service.rating,
                            showFavorite: true,
                            showLocationAndRating: true,
                            isFavorited: isFavorited,
                            onTap: () {
                              debugPrint('👆 Tapped: ${service.name}');
                              debugPrint('📦 Service author data:');
                              debugPrint('   - authorId: ${service.authorId}');
                              debugPrint('   - author map: ${service.author}');

                              Get.toNamed(
                                AppRoutes.homeServiceDetailsRoute,
                                arguments: {
                                  'serviceId': service.id,
                                  'serviceName': service.name,
                                  'serviceDescription': service.description,
                                  'serviceLocation': service.location,
                                  'serviceRating': service.rating,
                                  'serviceImage': service.fullImageUrl,
                                  'authorId': service.authorId ?? '',
                                  'author': service.author,
                                },
                              );
                            },
                            onFavorite: isLoadingFav
                                ? null
                                : () {
                              debugPrint('❤️ Favorite tapped for: ${service.name}');
                              debugPrint('   - Service ID: ${service.id}');
                              favoriteController.toggleFavorite(service.id);
                            },
                          ),
                        ),
                      );
                    });
                  } catch (e, stackTrace) {
                    debugPrint('❌ Error building card at index $index: $e');
                    debugPrint('📚 StackTrace: $stackTrace');
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.orange[300]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Error loading service',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  @override
  void dispose() {
    // Don't dispose controllers here - let GetX handle them
    super.dispose();
  }
}












