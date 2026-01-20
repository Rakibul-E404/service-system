import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/features/home/screens/search_input_section.dart';
import 'package:manx_mate/features/home/screens/search_results_grid.dart';
import 'package:manx_mate/features/home/screens/user_advertisement.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../provider/controllers/category_controller.dart';
import '../controllers/home_search_controller.dart';
import 'all_service_screen.dart';
import 'featured_providers_section.dart';
import 'filter_bottom_sheet.dart';

class HomeServiceSearchScreen extends StatefulWidget {
  const HomeServiceSearchScreen({super.key});

  @override
  State<HomeServiceSearchScreen> createState() => _HomeServiceSearchScreenState();
}

class _HomeServiceSearchScreenState extends State<HomeServiceSearchScreen> {
  final HomeSearchController controller = Get.find<HomeSearchController>();
  final TextEditingController _searchTEController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _selectedCategory = 'All Categories';
  String _selectedSubCategory = 'All Subcategories';
  String _selectedLocation = 'All Locations';

  // Store IDs separately
  String? _selectedCategoryId;
  String? _selectedSubCategoryId;

  bool _initialSearchPerformed = false;

  final Map<String, List<String>> _categoryToSubCategories = <String, List<String>>{
    'All Categories': <String>['All Subcategories'],
    'Electrical': <String>['Electrical Services', 'Wiring', 'Lighting', 'Installation'],
    'Plumbing': <String>['Plumbing Services', 'Pipe Repair', 'Installation', 'Maintenance'],
    'AC Repair': <String>['AC Installation', 'AC Maintenance', 'AC Repair', 'AC Service'],
    'Cleaning': <String>['Home Cleaning', 'Office Cleaning', 'Deep Cleaning', 'Regular Cleaning'],
    'Carpentry': <String>['Furniture Making', 'Furniture Repair', 'Custom Carpentry', 'Wood Work'],
    'Painting': <String>['Interior Painting', 'Exterior Painting', 'Wall Painting', 'Decorative'],
    'Home Appliance Repair': <String>['Refrigerator Repair', 'Washing Machine Repair', 'Microwave Repair', 'Other Repairs'],
    'Pest Control': <String>['Termite Control', 'Cockroach Control', 'Mosquito Control', 'General Pest Control'],
    'Internet & Network Setup': <String>['Router Setup', 'Network Installation', 'WiFi Setup', 'Cable Management'],
    'CCTV Installation': <String>['CCTV Installation', 'CCTV Maintenance', 'CCTV Repair', 'Security Setup'],
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

  @override
  void dispose() {
    _searchTEController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    _searchTEController.clear();
    setState(() {
      _selectedCategory = 'All Categories';
      _selectedSubCategory = 'All Subcategories';
      _selectedLocation = 'All Locations';
      _selectedCategoryId = null;
      _selectedSubCategoryId = null;
      _initialSearchPerformed = false;
    });

    await controller.fetchServices(refresh: true);
    controller.clearFilters();
  }

  void _handleInitialArguments() {
    final args = Get.arguments;

    if (args == null) {
      debugPrint('📥 No arguments received');
      return;
    }

    final String? initialCategory = args['initialCategory'] as String?;
    final String? initialCategoryId = args['initialCategoryId'] as String?;
    final bool fromBanner = args['fromBanner'] as bool? ?? false;

    debugPrint('📥 Received Arguments:');
    debugPrint('   - Category: $initialCategory');
    debugPrint('   - Category ID: $initialCategoryId');
    debugPrint('   - From Banner: $fromBanner');

    if (initialCategory != null && initialCategory.isNotEmpty) {
      // Validate if category exists in our map
      if (_categoryToSubCategories.containsKey(initialCategory)) {
        setState(() {
          _selectedCategory = initialCategory;
          _selectedCategoryId = initialCategoryId;
          _selectedSubCategory = 'All Subcategories';
          _selectedSubCategoryId = null;
        });

        // Set search text
        if (fromBanner) {
          _searchTEController.text = initialCategory;
        }

        debugPrint('✅ Filter State Updated:');
        debugPrint('   - Selected Category: $_selectedCategory');
        debugPrint('   - Selected Category ID: $_selectedCategoryId');
        debugPrint('   - Search Text: ${_searchTEController.text}');

        // Perform search after delay
        Future.delayed(const Duration(milliseconds: 300), () {
          _performSearch();
        });

        _initialSearchPerformed = true;
      } else {
        debugPrint('⚠️ Category "$initialCategory" not found in map');
        debugPrint('   Available: ${_categoryToSubCategories.keys.toList()}');

        Get.snackbar(
          'Category Not Available',
          'The category "$initialCategory" is not available',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } else {
      debugPrint('⚠️ Initial category is null or empty');
    }
  }

  void _performSearch() {
    final String keyword = _searchTEController.text.trim();

    // Get category ID - prefer stored ID, fallback to lookup
    String? categoryId = _selectedCategoryId;

    if (categoryId == null && _selectedCategory != 'All Categories') {
      final CategoryController catController = Get.find<CategoryController>();
      categoryId = catController.getCategoryIdByName(_selectedCategory);

      if (categoryId != null) {
        _selectedCategoryId = categoryId;
      }
    }

    debugPrint('🔍 Performing Search:');
    debugPrint('   - Keyword: "$keyword"');
    debugPrint('   - Category: $_selectedCategory');
    debugPrint('   - Category ID: $categoryId');
    debugPrint('   - SubCategory: $_selectedSubCategory');
    debugPrint('   - SubCategory ID: $_selectedSubCategoryId');

    setState(() {
      _initialSearchPerformed = true;
    });

    controller.searchServices(
      keyword: keyword,
      categoryId: categoryId,
      subCategoryId: _selectedSubCategoryId,
    );
  }

  List<dynamic> get _allServices {
    return controller.filteredServices;
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

    Get.to(
          () => AllServicesScreen(
        services: List<Map<String, dynamic>>.from(allServices),
      ),
      transition: Transition.rightToLeft,
    );
  }

  void _clearFilters() {
    _searchTEController.clear();
    setState(() {
      _selectedCategory = 'All Categories';
      _selectedSubCategory = 'All Subcategories';
      _selectedLocation = 'All Locations';
      _selectedCategoryId = null;
      _selectedSubCategoryId = null;
      _initialSearchPerformed = false;
    });
    controller.clearFilters();
    Get.rawSnackbar(
      message: 'Filters cleared',
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 1),
    );
  }

  void _showFilterBottomSheet() {
    debugPrint('🎛️ Opening Filter Bottom Sheet');
    debugPrint('   Current Category: $_selectedCategory');
    debugPrint('   Current SubCategory: $_selectedSubCategory');

    FilterBottomSheet.show(
      context: context,
      selectedCategory: _selectedCategory,
      selectedSubCategory: _selectedSubCategory,
      selectedLocation: _selectedLocation,
      categoryToSubCategories: _categoryToSubCategories,
      locationOptions: _locationOptions,
      onApply: (String category, String subCategory, String location) {
        debugPrint('🎯 Filter Apply Called:');
        debugPrint('   - Category: $category');
        debugPrint('   - SubCategory: $subCategory');
        debugPrint('   - Location: $location');

        // Get CategoryController to lookup IDs
        final CategoryController catController = Get.find<CategoryController>();

        setState(() {
          _selectedCategory = category;
          _selectedSubCategory = subCategory;
          _selectedLocation = location;

          // Update category ID
          if (category != 'All Categories') {
            _selectedCategoryId = catController.getCategoryIdByName(category);
            debugPrint('   - Category ID: $_selectedCategoryId');
          } else {
            _selectedCategoryId = null;
          }

          // Update search text
          if (category != 'All Categories') {
            if (subCategory != 'All Subcategories') {
              _searchTEController.text = subCategory;
            } else {
              _searchTEController.text = category;
            }
          } else {
            _searchTEController.text = '';
          }
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
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.primaryColor,
        backgroundColor: Colors.white,
        strokeWidth: 3.0,
        displacement: 40.0,
        edgeOffset: 0,
        child: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: SearchInputSection(
                  searchController: _searchTEController,
                  onSearch: _performSearch,
                ),
              ),
              const SliverToBoxAdapter(child: FeaturedProvidersSection()),
              SliverToBoxAdapter(
                child: SearchResultsHeader(
                  searchTEController: _searchTEController,
                  initialSearchPerformed: _initialSearchPerformed,
                  controller: controller,
                  onSeeAll: _navigateToAllServices,
                ),
              ),
              SearchResultsGrid(
                searchTEController: _searchTEController,
                initialSearchPerformed: _initialSearchPerformed,
                controller: controller,
                onSeeAll: _navigateToAllServices,
              ),
              const SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    AdvertisementsSection(),
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
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
        style: context.txtTheme.headlineLarge?.copyWith(fontSize: 25),
      ),
      centerTitle: true,
      leading: IconButton(
        onPressed: onBack,
        icon: const Icon(CupertinoIcons.back, size: 25),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: onFilter,
          icon: const Icon(
            Icons.filter_alt_rounded,
            color: AppColors.primaryColor,
            size: 25,
          ),
        ),
      ],
    );
  }
}
