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
  final ScrollController _scrollController = ScrollController();

  String _selectedCategory = 'All Categories';
  String _selectedSubCategory = 'All Subcategories';
  String _selectedLocation = 'All Locations';

  bool _initialSearchPerformed = false;

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    // Reset search and filters
    _searchTEController.clear();
    setState(() {
      _selectedCategory = 'All Categories';
      _selectedSubCategory = 'All Subcategories';
      _selectedLocation = 'All Locations';
      _initialSearchPerformed = false;
    });

    // Refresh data from controller
    await controller.fetchServices(refresh: true);

    // Clear any existing search results
    controller.clearFilters();
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
            physics: const AlwaysScrollableScrollPhysics(), // Required for RefreshIndicator
            slivers: <Widget>[
              // Search input section
              SliverToBoxAdapter(
                child: SearchInputSection(
                  searchController: _searchTEController,
                  onSearch: _performSearch,
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

              // Search results grid
              SearchResultsGrid(
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