
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../controllers/search_controller.dart';
import '../../auth/widgets/custom_text_field.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';

import 'all_service_screen.dart';

class HomeSearchScreen extends StatefulWidget {
  const HomeSearchScreen({super.key});

  @override
  State<HomeSearchScreen> createState() => _HomeSearchScreenState();
}

class _HomeSearchScreenState extends State<HomeSearchScreen> {
  final HomeSearchController controller = Get.find<HomeSearchController>();
  final TextEditingController _searchTEController = TextEditingController();

  String _selectedCategory = 'All Categories';
  String _selectedSubCategory = 'All Subcategories';
  String _selectedLocation = 'All Locations';

  final List<Map<String, dynamic>> _dummyServices = [
    {
      '_id': '1',
      'name': 'Premium Cleaning Service',
      'description': 'Professional home and office cleaning',
      'location': 'Downtown Manhattan',
      'image': 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400&h=300&fit=crop',
      'rating': 4.8,
      'price': 85,
      'author': {'_id': 'author1', 'name': 'John Cleaners'}
    },
    {
      '_id': '2',
      'name': 'Green Garden Solutions',
      'description': 'Expert gardening and lawn care',
      'location': 'Brooklyn Heights',
      'image': 'https://images.unsplash.com/photo-1560493676-04071c5f467b?w=400&h=300&fit=crop',
      'rating': 4.6,
      'price': 65,
      'author': {'_id': 'author2', 'name': 'Green Thumb Inc.'}
    },
    {
      '_id': '3',
      'name': 'Quick Fix Electrical',
      'description': '24/7 emergency electrical services',
      'location': 'Queens',
      'image': 'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=400&h=300&fit=crop',
      'rating': 4.9,
      'price': 120,
      'author': {'_id': 'author3', 'name': 'ElectroFix'}
    },
    {
      '_id': '4',
      'name': 'PlumbPro Masters',
      'description': 'Leak repair and pipe installation',
      'location': 'Staten Island',
      'image': 'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=400&h=300&fit=crop',
      'rating': 4.7,
      'price': 95,
      'author': {'_id': 'author4', 'name': 'PlumbPro'}
    },
    {
      '_id': '5',
      'name': 'Perfect Painters',
      'description': 'Interior and exterior painting',
      'location': 'Upper East Side',
      'image': 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?w=400&h=300&fit=crop',
      'rating': 4.5,
      'price': 150,
      'author': {'_id': 'author5', 'name': 'ColorCraft'}
    },
    {
      '_id': '6',
      'name': 'Master Carpenters LLC',
      'description': 'Custom furniture and woodwork',
      'location': 'Chelsea',
      'image': 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
      'rating': 4.8,
      'price': 200,
      'author': {'_id': 'author6', 'name': 'WoodWorks'}
    },
    {
      '_id': '7',
      'name': 'Swift Movers',
      'description': 'Local and long distance moving',
      'location': 'Harlem',
      'image': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&h=300&fit=crop',
      'rating': 4.4,
      'price': 180,
      'author': {'_id': 'author7', 'name': 'SwiftMove'}
    },
    {
      '_id': '8',
      'name': 'Elite Cleaning Professionals',
      'description': 'Deep cleaning and sanitization',
      'location': 'Financial District',
      'image': 'https://images.unsplash.com/photo-1595078475328-1ab05d0a6a0e?w=400&h=300&fit=crop',
      'rating': 4.9,
      'price': 110,
      'author': {'_id': 'author8', 'name': 'EliteClean'}
    },
  ];

  final Map<String, List<String>> _categoryToSubCategories = {
    'All Categories': ['All Subcategories'],
    'Cleaning': ['Home Cleaning', 'Office Cleaning', 'Deep Cleaning'],
    'Gardening': ['Garden Maintenance', 'Lawn Mowing', 'Landscaping'],
    'Electrical': ['Electrical Services', 'Wiring', 'Lighting'],
    'Plumbing': ['Plumbing Services', 'Pipe Repair', 'Installation'],
    'Painting': ['Painting Services', 'Interior', 'Exterior'],
    'Carpentry': ['Carpentry Services', 'Furniture', 'Repairs'],
    'Moving': ['Moving Services', 'Packing', 'Local Move'],
  };

  final List<String> _locationOptions = [
    'All Locations',
    'North',
    'South',
    'East',
    'West'
  ];

  bool _initialSearchPerformed = false;

  // Ad data
  final List<Map<String, dynamic>> _ads = [
    {
      'id': 'ad1',
      'title': 'Need Professional Help?',
      'description': 'Find the best service providers in your area',
      'image': 'https://images.unsplash.com/photo-1551434678-e076c223a692?w=800&h-400&fit=crop',
      'cta': 'Explore Now',
      'bgColor': Colors.blue.shade50,
    },
    {
      'id': 'ad2',
      'title': 'Special Discount!',
      'description': 'Get 20% off on your first service booking',
      'image': 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800&h=400&fit=crop',
      'cta': 'Book Now',
      'bgColor': Colors.green.shade50,
    },
    {
      'id': 'ad3',
      'title': 'Trusted by Thousands',
      'description': 'Join our community of satisfied customers',
      'image': 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&h=400&fit=crop',
      'cta': 'Learn More',
      'bgColor': Colors.orange.shade50,
    },
  ];

  @override
  void initState() {
    super.initState();
    _handleInitialArguments();
  }

  void _handleInitialArguments() {
    final args = Get.arguments;
    final initialCategory = args?['initialCategory'] as String?;
    final initialSubCategory = args?['initialSubCategory'] as String?;

    if (initialCategory != null) {
      setState(() {
        _selectedCategory = initialCategory;
        _selectedSubCategory = initialSubCategory ?? 'All Subcategories';
      });
      _searchTEController.text = initialSubCategory ?? '';
      Future.delayed(const Duration(milliseconds: 300), _performSearch);
      _initialSearchPerformed = true;
    }
  }

  List<String> get _subCategoryOptions {
    if (_selectedCategory == 'All Categories') {
      return ['All Subcategories'];
    }
    return ['All Subcategories', ...?_categoryToSubCategories[_selectedCategory]];
  }

  // Method to get all services (dummy or real)
  List<dynamic> get _allServices {
    final bool showDummyData = !_initialSearchPerformed &&
        controller.filteredServices.isEmpty &&
        _searchTEController.text.isEmpty;

    return showDummyData ? _dummyServices : controller.filteredServices;
  }

  // Method to navigate to all services screen
  void _navigateToAllServices() {
    final allServices = _allServices;

    if (allServices.isEmpty) {
      Get.snackbar(
        'No Services',
        'There are no services to show.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Navigate to the AllServicesScreen
    Get.to(
          () => AllServicesScreen(services: List<Map<String, dynamic>>.from(allServices)),
      transition: Transition.rightToLeft,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        title: Text("Service", style: context.txtTheme.headlineLarge?.copyWith(
          fontSize: 25,
        )),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(CupertinoIcons.back,size: 25,),
        ),
        actions: [
          IconButton(
            onPressed: () => _showFilterBottomSheet(context),
            icon: const Icon(Icons.filter_alt_rounded, color: AppColors.primaryColor,size: 25,),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            // Search input & filters
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: AppSizes.sm),
                    Text('What are you looking for?', style: context.txtTheme.labelSmall?.copyWith(
                        fontSize: 24
                    )),
                    const SizedBox(height: AppSizes.sm),
                    MyTextFormFieldWithIcon(
                      formHintText: "Search by keyword...",
                      prefixIcon: const Icon(CupertinoIcons.search, color: AppColors.primaryColor),
                      controller: _searchTEController,
                      validator: (String? value) => null,
                    ),
                    const SizedBox(height: AppSizes.sm),
                  ],
                ),
              ),
            ),

            // Featured Providers Horizontal Scroll
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.md),
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
                                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    onTap: () {},
                                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusMd)),
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
                                                  Icon(Icons.location_on, color: Colors.grey, size: 12),
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
                                )
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // "Your Search Results" header
            SliverToBoxAdapter(
              child: GetBuilder<HomeSearchController>(
                builder: (HomeSearchController ctrl) {
                  final bool showDummyData = !_initialSearchPerformed &&
                      ctrl.filteredServices.isEmpty &&
                      _searchTEController.text.isEmpty;

                  final List<dynamic> displayServices = showDummyData
                      ? _dummyServices
                      : ctrl.filteredServices;

                  // Only show "See All" if there are more than 4 items
                  final shouldShowSeeAll = displayServices.length > 4;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Search Results',
                          style: context.txtTheme.headlineSmall,
                        ),
                        if (shouldShowSeeAll)
                          TextButton(
                            onPressed: _navigateToAllServices,
                            child: Text(
                              "See All (${displayServices.length})",
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
              ),
            ),

            /// Search results grid (Limited to 4 items)
            GetBuilder<HomeSearchController>(
              builder: (HomeSearchController ctrl) {
                // Determine which data to show
                final bool showDummyData = !_initialSearchPerformed &&
                    ctrl.filteredServices.isEmpty &&
                    _searchTEController.text.isEmpty;

                final List<dynamic> displayServices = showDummyData
                    ? _dummyServices
                    : ctrl.filteredServices;

                if (ctrl.isLoading && !showDummyData) {
                  return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
                }

                if (ctrl.error.isNotEmpty && !showDummyData) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(ctrl.error, style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 16),
                          ElevatedButton(onPressed: _performSearch, child: const Text('Retry Search')),
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
                            _searchTEController.text.isNotEmpty
                                ? 'No services found for "${_searchTEController.text}"'
                                : 'Search for services using the filters above',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text('Try different keywords or filters', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                  );
                }

                // Show only 4 items on the first screen
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
                      final serviceId = item['_id']?.toString() ?? '';
                      final serviceName = item['name']?.toString() ?? 'No Name';
                      final serviceDescription = item['description']?.toString() ?? '';
                      final serviceLocation = item['location']?.toString() ?? '';
                      final serviceImage = item['image']?.toString() ?? '';
                      final serviceRating = (item['rating']?.toDouble() ?? 0.0);
                      final author = item['author'];
                      final completeImageUrl = serviceImage.isNotEmpty && serviceImage.startsWith('http')
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
                                'authorId': author is String ? author : (author is Map ? author['_id'] : null),
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
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusMd)),
                                child: completeImageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                  imageUrl: completeImageUrl,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (BuildContext context, String url) => Container(
                                    height: 120,
                                    color: Colors.grey[200],
                                    child: const Center(child: CircularProgressIndicator()),
                                  ),
                                  errorWidget: (BuildContext context, String url, Object error) => Container(
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
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on, color: Colors.grey, size: 12),
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
                    },
                  ),
                );
              },
            ),

            /// Ad Section (Added after search results)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Sponsored",
                          style: context.txtTheme.headlineSmall?.copyWith(
                            color: AppColors.blackColor,
                            fontSize: 18
                          ),
                        ),
                        Text(
                          " Providers",
                          style: context.txtTheme.headlineSmall?.copyWith(
                            color: AppColors.blackColor,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),
                    Container(
                      height: 180,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                        color: _ads[0]['bgColor'] as Color,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                              child: CachedNetworkImage(
                                imageUrl: _ads[0]['image'] as String,
                                fit: BoxFit.cover,
                                colorBlendMode: BlendMode.overlay,
                                color: Colors.black.withValues(alpha: 0.1),
                                placeholder: (BuildContext context, String url) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(child: CircularProgressIndicator()),
                                ),
                                errorWidget: (BuildContext context, String url, Object error) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.error),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(AppSizes.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _ads[0]['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: AppSizes.sm),
                                Text(
                                  _ads[0]['description'] as String,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppSizes.md),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),

                  ],
                ),
              ),
            ),

            // Add some bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
          items: items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _performSearch() {
    final keyword = _searchTEController.text.trim();
    final category = _selectedCategory == 'All Categories' ? '' : _selectedCategory;
    final subcategory = _selectedSubCategory == 'All Subcategories' ? '' : _selectedSubCategory;
    final location = _selectedLocation == 'All Locations' ? '' : _selectedLocation;

    setState(() {
      _initialSearchPerformed = true;
    });

    controller.searchServices(
      keyword: keyword,
      category: category,
      subcategory: subcategory,
      location: location,
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    String selectedCategory = _selectedCategory;
    String selectedSubCategory = _selectedSubCategory;
    String selectedLocation = _selectedLocation;

    final Map<String, List<String>> categoryToSubCategories = _categoryToSubCategories;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusMd)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            List<String> getSubCategories(String category) {
              if (category == 'All Categories') {
                return <String>['All Subcategories'];
              }
              return <String>['All Subcategories', ...?categoryToSubCategories[category]];
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.sm,
                AppSizes.md,
                MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filters', style: context.txtTheme.headlineSmall),
                  const SizedBox(height: AppSizes.md),
                  Text('Category', style: context.txtTheme.labelMedium),
                  const SizedBox(height: AppSizes.sm),
                  _buildFilterDropdown(
                    value: selectedCategory,
                    items: ['All Categories', ...categoryToSubCategories.keys.where((k) => k != 'All Categories')],
                    onChanged: (val) {
                      if (val != null) {
                        selectedCategory = val;
                        selectedSubCategory = 'All Subcategories';
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text('Subcategory', style: context.txtTheme.labelMedium),
                  const SizedBox(height: AppSizes.sm),
                  _buildFilterDropdown(
                    value: selectedSubCategory,
                    items: getSubCategories(selectedCategory),
                    onChanged: (val) {
                      if (val != null) {
                        selectedSubCategory = val;
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text('Location', style: context.txtTheme.labelMedium),
                  const SizedBox(height: AppSizes.sm),
                  _buildFilterDropdown(
                    value: selectedLocation,
                    items: _locationOptions,
                    onChanged: (String? val) {
                      if (val != null) {
                        selectedLocation = val;
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: AppSizes.xl),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _clearFilters();
                            Get.back();
                          },
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategory = selectedCategory;
                              _selectedSubCategory = selectedSubCategory;
                              _selectedLocation = selectedLocation;
                            });
                            _performSearch();
                            Get.back();
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),

                ],
              ),
            );
          },
        );
      },
    );
  }

  void _clearFilters() {
    _searchTEController.clear();
    setState(() {
      _selectedCategory = 'All Categories';
      _selectedSubCategory = 'All Subcategories';
      _selectedLocation = 'All Locations';
      _initialSearchPerformed = false;
    });
    controller.clearFilters();
    Get.rawSnackbar(message: 'Filters cleared', backgroundColor: Colors.green);
  }
}