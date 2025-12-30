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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Service", style: context.txtTheme.headlineLarge),
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
                    Text('What are you looking for?', style: context.txtTheme.labelLarge),
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
                      height: 180,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: List.generate(5, (int index) {
                          return Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {},
                              child: Card(
                                color: AppColors.whiteColor,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusMd)),
                                      child: Container(
                                        height: 100,
                                        width: double.infinity,
                                        color: Colors.white,
                                        child: const Icon(Icons.person, size: 40, color: Colors.grey),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            // "Provider ${index + 1}",
                                            "Platform Service Co.",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            "Residental Plambing",
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
                                              Icon(Icons.location_on, color: AppColors.greyColor, size: 12),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
                child: Text(
                  'Your Search Results',
                  style: context.txtTheme.headlineSmall,
                ),
              ),
            ),

            // Search results grid
            GetBuilder<HomeSearchController>(
              builder: (ctrl) {
                if (ctrl.isLoading) {
                  return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
                }
                if (ctrl.error.isNotEmpty) {
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
                if (ctrl.filteredServices.isEmpty) {
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

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  sliver: SliverGrid.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: ctrl.filteredServices.length,
                    itemBuilder: (context, index) {
                      final item = ctrl.filteredServices[index];
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
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusMd)),
                                child: completeImageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                  imageUrl: completeImageUrl,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => Container(
                                    height: 120,
                                    color: Colors.grey[200],
                                    child: const Center(child: CircularProgressIndicator()),
                                  ),
                                  errorWidget: (context, url, error) => Container(
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
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            serviceName,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[800],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            serviceDescription,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.location_on, color: Colors.grey, size: 12),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  serviceLocation,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey[600],
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(Icons.star, color: Colors.amber, size: 12),
                                              const SizedBox(width: 4),
                                              Text(
                                                serviceRating.toStringAsFixed(1),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                              const Spacer(),
                                              if (item['price'] != null)
                                                Text(
                                                  '\$${item['price']}',
                                                  style: TextStyle(
                                                    fontSize: 10,
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
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            List<String> getSubCategories(String category) {
              if (category == 'All Categories') return ['All Subcategories'];
              return ['All Subcategories', ...?categoryToSubCategories[category]];
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
                            Navigator.pop(context);
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
    });
    _initialSearchPerformed = false;
    controller.clearFilters();
    Get.rawSnackbar(message: 'Filters cleared', backgroundColor: Colors.green);
  }
}
