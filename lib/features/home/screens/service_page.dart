/**

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../auth/widgets/service_card.dart';
import '../controllers/service_controller.dart';
import '../../favorite/controllers/favorite_controller.dart';

class ServicesPage extends GetView<ServicesController> {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize FavoriteController
    final favoriteController = Get.put(FavoriteController());

    // Get arguments safely
    final dynamic args = Get.arguments;
    final String subCategoryName = (args is Map<String, dynamic>)
        ? (args['subCategoryName']?.toString() ?? 'Services')
        : 'Services';
    final String subCategoryId = (args is Map<String, dynamic>)
        ? (args['subCategoryId']?.toString() ?? '')
        : '';

    debugPrint('🚀 ========== SERVICES PAGE BUILD ==========');
    debugPrint('📥 subCategoryName: "$subCategoryName"');
    debugPrint('📥 subCategoryId: "$subCategoryId"');

    // Fetch services only once after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🎯 PostFrameCallback executing...');
      debugPrint('   - subCategoryId.isNotEmpty: ${subCategoryId.isNotEmpty}');
      debugPrint('   - services.isEmpty: ${controller.services.isEmpty}');
      debugPrint('   - isLoadingServices: ${controller.isLoadingServices.value}');

      if (subCategoryId.isNotEmpty &&
          controller.services.isEmpty &&
          !controller.isLoadingServices.value) {
        debugPrint('✅ Conditions met - fetching services...');
        controller.fetchServicesBySubCategory(subCategoryId, subCategoryName);
      } else {
        debugPrint('⏭️ Skipping fetch - conditions not met');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(subCategoryName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final isLoading = controller.isLoadingServices.value;
        final errorMsg = controller.servicesErrorMessage.value;
        final servicesList = controller.services.toList();

        debugPrint('🔄 ========== OBX REBUILD ==========');
        debugPrint('   - isLoading: $isLoading');
        debugPrint('   - errorMsg: "$errorMsg"');
        debugPrint('   - services.length: ${servicesList.length}');

        // Loading state
        if (isLoading) {
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
        if (errorMsg.isNotEmpty) {
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
                  ElevatedButton(
                    onPressed: () {
                      debugPrint('🔄 Retry button pressed');
                      controller.retryServicesWithParams(subCategoryId, subCategoryName);
                    },
                    child: const Text('Retry'),
                  ),
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
                    controller.fetchServicesBySubCategory(subCategoryId, subCategoryName);
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        // Services list
        debugPrint('📋 Showing ${servicesList.length} services');
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: servicesList.length,
          itemBuilder: (context, index) {
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
                      ///----perfect
                      // onTap: () {
                      //   debugPrint('👆 Tapped: ${service.name}');
                      //   Get.toNamed(
                      //     AppRoutes.homeServiceDetailsRoute,
                      //     arguments: {
                      //       'serviceId': service.id,
                      //       'serviceName': service.name,
                      //       'serviceDescription': service.description,
                      //       'serviceLocation': service.location,
                      //       'serviceRating': service.rating,
                      //       'serviceImage': service.fullImageUrl,
                      //     },
                      //   );
                      // },

                      // Replace your onTap in services_page.dart with this:

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
                            'authorId': service.authorId ?? '', // Pass the author ID directly
                            'author': service.author, // Also pass as map for backward compatibility
                          },
                        );
                      },


                      onFavorite: isLoadingFav
                          ? null // Disable while loading
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
              return const SizedBox.shrink();
            }
          },
        );
      }),
    );
  }
}





*/














///
///
///
///
/// todo::: fixing the issue
///
///
///
///
///








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
    }

    debugPrint('🚀 ========== SERVICES PAGE INIT ==========');
    debugPrint('📥 subCategoryName: "$subCategoryName"');
    debugPrint('📥 subCategoryId: "$subCategoryId"');
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
      servicesController.fetchServicesBySubCategory(subCategoryId, subCategoryName);
    } else {
      debugPrint('⏭️ Skipping fetch - conditions not met');
    }
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
        final errorMsg = servicesController.servicesErrorMessage.value;
        final servicesList = servicesController.services.toList();

        debugPrint('🔄 ========== OBX REBUILD ==========');
        debugPrint('   - isLoading: $isLoading');
        debugPrint('   - errorMsg: "$errorMsg"');
        debugPrint('   - services.length: ${servicesList.length}');

        // Loading state
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
                  ElevatedButton(
                    onPressed: () {
                      debugPrint('🔄 Retry button pressed');
                      servicesController.retryServicesWithParams(subCategoryId, subCategoryName);
                    },
                    child: const Text('Retry'),
                  ),
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
                    servicesController.fetchServicesBySubCategory(subCategoryId, subCategoryName);
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        // Services list
        debugPrint('📋 Showing ${servicesList.length} services');
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: servicesList.length,
          itemBuilder: (context, index) {
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

