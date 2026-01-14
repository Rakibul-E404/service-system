import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/features/home/screens/search_input_section.dart';
import 'package:manx_mate/features/home/screens/search_results_grid.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/home_search_controller.dart';
import 'ad_section.dart';
import 'all_service_screen.dart';
import 'featured_providers_section.dart';
import 'filter_bottom_sheet.dart';

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

  bool _initialSearchPerformed = false;

  final List<Map<String, dynamic>> _dummyServices = <Map<String, dynamic>>[
    <String, dynamic>{
      '_id': '1',
      'name': 'Premium Cleaning Service',
      'description': 'Professional home and office cleaning',
      'location': 'Downtown Manhattan',
      'image': 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400&h=300&fit=crop',
      'rating': 4.8,
      'price': 85,
      'author': <String, String>{'_id': 'author1', 'name': 'John Cleaners'}
    },
    <String, dynamic>{
      '_id': '2',
      'name': 'Green Garden Solutions',
      'description': 'Expert gardening and lawn care',
      'location': 'Brooklyn Heights',
      'image': 'https://images.unsplash.com/photo-1560493676-04071c5f467b?w=400&h=300&fit=crop',
      'rating': 4.6,
      'price': 65,
      'author': <String, String>{'_id': 'author2', 'name': 'Green Thumb Inc.'}
    },
    <String, dynamic>{
      '_id': '3',
      'name': 'Quick Fix Electrical',
      'description': '24/7 emergency electrical services',
      'location': 'Queens',
      'image': 'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=400&h=300&fit=crop',
      'rating': 4.9,
      'price': 120,
      'author': <String, String>{'_id': 'author3', 'name': 'ElectroFix'}
    },
    <String, dynamic>{
      '_id': '4',
      'name': 'PlumbPro Masters',
      'description': 'Leak repair and pipe installation',
      'location': 'Staten Island',
      'image': 'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=400&h=300&fit=crop',
      'rating': 4.7,
      'price': 95,
      'author': <String, String>{'_id': 'author4', 'name': 'PlumbPro'}
    },
    <String, dynamic>{
      '_id': '5',
      'name': 'Perfect Painters',
      'description': 'Interior and exterior painting',
      'location': 'Upper East Side',
      'image': 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?w=400&h=300&fit=crop',
      'rating': 4.5,
      'price': 150,
      'author': <String, String>{'_id': 'author5', 'name': 'ColorCraft'}
    },
    <String, dynamic>{
      '_id': '6',
      'name': 'Master Carpenters LLC',
      'description': 'Custom furniture and woodwork',
      'location': 'Chelsea',
      'image': 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop',
      'rating': 4.8,
      'price': 200,
      'author': <String, String>{'_id': 'author6', 'name': 'WoodWorks'}
    },
    <String, dynamic>{
      '_id': '7',
      'name': 'Swift Movers',
      'description': 'Local and long distance moving',
      'location': 'Harlem',
      'image': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&h=300&fit=crop',
      'rating': 4.4,
      'price': 180,
      'author': <String, String>{'_id': 'author7', 'name': 'SwiftMove'}
    },
    <String, dynamic>{
      '_id': '8',
      'name': 'Elite Cleaning Professionals',
      'description': 'Deep cleaning and sanitization',
      'location': 'Financial District',
      'image': 'https://images.unsplash.com/photo-1595078475328-1ab05d0a6a0e?w=400&h=300&fit=crop',
      'rating': 4.9,
      'price': 110,
      'author': <String, String>{'_id': 'author8', 'name': 'EliteClean'}
    },
  ];

  final Map<String, List<String>> _categoryToSubCategories = <String, List<String>>{
    'All Categories': <String>['All Subcategories'],
    'Cleaning': <String>['Home Cleaning', 'Office Cleaning', 'Deep Cleaning'],
    'Gardening': <String>['Garden Maintenance', 'Lawn Mowing', 'Landscaping'],
    'Electrical': <String>['Electrical Services', 'Wiring', 'Lighting'],
    'Plumbing': <String>['Plumbing Services', 'Pipe Repair', 'Installation'],
    'Painting': <String>['Painting Services', 'Interior', 'Exterior'],
    'Carpentry': <String>['Carpentry Services', 'Furniture', 'Repairs'],
    'Moving': <String>['Moving Services', 'Packing', 'Local Move'],
  };

  final List<String> _locationOptions = <String>[
    'All Locations',
    'North',
    'South',
    'East',
    'West'
  ];

  @override
  void initState() {
    super.initState();
    _handleInitialArguments();
  }

  void _handleInitialArguments() {
    final args = Get.arguments;
    final String? initialCategory = args?['initialCategory'] as String?;
    final String? initialSubCategory = args?['initialSubCategory'] as String?;

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


  List<dynamic> get _allServices {
    final bool showDummyData = !_initialSearchPerformed &&
        controller.filteredServices.isEmpty &&
        _searchTEController.text.isEmpty;

    return showDummyData ? _dummyServices : controller.filteredServices;
  }

  void _navigateToAllServices() {
    final List<dynamic> allServices = _allServices;

    if (allServices.isEmpty) {
      Get.snackbar(
        'No Services',
        'There are no services to show.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Use your existing AllServicesScreen
    Get.to(
          () => AllServicesScreen(services: List<Map<String, dynamic>>.from(allServices)),
      transition: Transition.rightToLeft,
    );
  }

  void _performSearch() {
    final String keyword = _searchTEController.text.trim();
    final String category = _selectedCategory == 'All Categories' ? '' : _selectedCategory;
    final String subcategory = _selectedSubCategory == 'All Subcategories' ? '' : _selectedSubCategory;
    final String location = _selectedLocation == 'All Locations' ? '' : _selectedLocation;

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

  void _showFilterBottomSheet() {
    FilterBottomSheet.show(
      context: context,
      selectedCategory: _selectedCategory,
      selectedSubCategory: _selectedSubCategory,
      selectedLocation: _selectedLocation,
      categoryToSubCategories: _categoryToSubCategories,
      locationOptions: _locationOptions,
      onApply: (String category, String subCategory, String location) {
        setState(() {
          _selectedCategory = category;
          _selectedSubCategory = subCategory;
          _selectedLocation = location;
        });
        _performSearch();
      },
      onClear: _clearFilters,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(
        onBack: () => Get.back(),
        onFilter: _showFilterBottomSheet,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            // Search input section
            SliverToBoxAdapter(
              child: SearchInputSection(
                searchController: _searchTEController,
              ),
            ),

            // Featured Providers section
            const SliverToBoxAdapter(
              child: FeaturedProvidersSection(),
            ),

            // Search results header
            SliverToBoxAdapter(
              child: SearchResultsHeader(
                searchTEController: _searchTEController,
                initialSearchPerformed: _initialSearchPerformed,
                controller: controller,
                onSeeAll: _navigateToAllServices,
              ),
            ),

            ///
            ///
            /// Search results grid
            ///
            ///
            ///
            SearchResultsGrid(
              dummyServices: _dummyServices,
              searchTEController: _searchTEController,
              initialSearchPerformed: _initialSearchPerformed,
              controller: controller,
              onSeeAll: _navigateToAllServices,
            ),

            // Ad section
            const SliverToBoxAdapter(
              child: AdSection(),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        ),
      ),
    );
  }
}




class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;
  final VoidCallback onFilter;

  const SearchAppBar({
    super.key,
    required this.onBack,
    required this.onFilter,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.whiteColor,
      title: Text(
        "Service",
        style: context.txtTheme.headlineLarge?.copyWith(
          fontSize: 25,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        onPressed: onBack,
        icon: const Icon(CupertinoIcons.back, size: 25),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: onFilter,
          icon: const Icon(Icons.filter_alt_rounded,
              color: AppColors.primaryColor, size: 25),
        ),
      ],
    );
  }
}