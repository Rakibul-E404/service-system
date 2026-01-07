
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/features/home/model/categor_model.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../controllers/home_controller.dart';

class CategorySubCategoryPicker extends StatefulWidget {
  const CategorySubCategoryPicker({
    super.key,
    required this.onCategoryChanged,
    required this.onSubCategoryChanged,
  });

  final Function(String? name, String? id) onCategoryChanged;
  final Function(String? name, String? id) onSubCategoryChanged;

  @override
  State<CategorySubCategoryPicker> createState() => _CategorySubCategoryPickerState();
}

class _CategorySubCategoryPickerState extends State<CategorySubCategoryPicker> {
  final HomeController _homeCtrl = Get.find<HomeController>();

  List<String> catNames = <String>[];
  List<String> catIds   = <String>[];
  List<String> subNames = <String>[];
  List<String> subIds   = <String>[];

  String? selectedCatName;
  String? selectedCatId;
  String? selectedSubName;
  String? selectedSubId;

  bool loadingCats = false;
  bool loadingSubs = false;
  String catError = '';
  String subError = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  /// -------------------------------------------------------------
  /// Load categories (uses HomeController logic)
  /// -------------------------------------------------------------
  Future<void> _loadCategories() async {
    if (!mounted) {
      return;
    }

    setState(() {
      loadingCats = true;
      catError = '';
    });

    try {
      // Check if categories are already loaded
      if (_homeCtrl.categories.isNotEmpty) {
        debugPrint('✅ Using cached categories: ${_homeCtrl.categories.length}');
        _updateCategoryLists();
      } else {
        debugPrint('🔄 Fetching categories from API...');
        await _homeCtrl.fetchCategories();
        _updateCategoryLists();
      }
    } catch (e) {
      debugPrint('❌ Error loading categories: $e');
      if (mounted) {
        setState(() {
          catError = 'Failed to load categories: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() => loadingCats = false);
      }
    }
  }

  /// Extract category data from controller
  void _updateCategoryLists() {
    final RxList<CategoryModel> cats = _homeCtrl.categories;
    catNames = cats.map((CategoryModel e) => e.name).toList();
    catIds   = cats.map((CategoryModel e) => e.id).toList();

    debugPrint('📋 Categories loaded: ${catNames.length} items');
    if (catNames.isNotEmpty) {
      debugPrint('📝 Category names: ${catNames.join(', ')}');
    }
  }

  /// -------------------------------------------------------------
  /// Load sub-categories for selected category
  /// -------------------------------------------------------------
  Future<void> _loadSubCategories(String catId) async {
    if (catId.isEmpty || !mounted) return;

    debugPrint('📢 Loading subcategories for category ID: $catId');

    setState(() {
      loadingSubs = true;
      subError = '';
      subNames.clear();
      subIds.clear();
      selectedSubName = null;
      selectedSubId = null;
    });

    try {
      debugPrint('🔄 Fetching subcategories for category: $catId');
      await _homeCtrl.fetchSubcategories(catId);

      if (!mounted) {
        return;
      }

      // Add a small delay to ensure state is updated
      await Future.delayed(const Duration(milliseconds: 100));

      final RxList<dynamic> subs = _homeCtrl.subcategories;
      debugPrint('📦 Raw subcategories from controller: ${subs.length} items');

      if (subs.isNotEmpty) {
        for (int i = 0; i < subs.length; i++) {
          debugPrint('   ${i + 1}. ID: ${subs[i]['_id']}, Name: ${subs[i]['name']}');
        }
      }

      setState(() {
        subNames = subs.map((e) => e['name']?.toString() ?? 'Unnamed').toList();
        subIds   = subs.map((e) => e['_id']?.toString() ?? '').toList();

        // Show error if any
        if (_homeCtrl.subcategoryErrorMessage.isNotEmpty) {
          subError = _homeCtrl.subcategoryErrorMessage.value;
        }
      });

      debugPrint('📋 Subcategories processed: ${subNames.length} items');
      debugPrint('📝 Subcategory names: ${subNames.join(', ')}');

      // If no subcategories, show appropriate message
      if (subNames.isEmpty && _homeCtrl.subcategoryErrorMessage.isEmpty) {
        subError = 'No subcategories available for this category';
      }
    } catch (e) {
      debugPrint('❌ Error loading subcategories: $e');
      if (mounted) {
        setState(() {
          subError = 'Failed to load subcategories: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() => loadingSubs = false);
      }
    }
  }

  /// -------------------------------------------------------------
  /// UI – dropdown builder
  /// -------------------------------------------------------------
  Widget _buildDropdown({
    required String hint,
    required List<String> items,
    required String? value,
    required bool loading,
    bool enabled = true,
    String? error,
    VoidCallback? onRetry,
    ValueChanged<String?>? onChanged,
  }) {
    // Determine if we should show error or empty state
    final bool showError = error != null && error.isNotEmpty;
    final bool showEmptyState = !loading && items.isEmpty && enabled;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: showError ? Colors.red : AppColors.primaryColor,
            width: 2
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
      ),
      child: loading
          ? _buildLoadingState()
          : showError
          ? _buildErrorState(error, onRetry)
          : showEmptyState
          ? _buildEmptyState(hint)
          : _buildDropdownButton(hint, items, value, enabled, onChanged),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Loading...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback? onRetry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            error,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
          if (onRetry != null) ...<Widget>[
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Text(
        '$hint (No items available)',
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildDropdownButton(String hint, List<String> items, String? value,
      bool enabled, ValueChanged<String?>? onChanged) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: value,
        hint: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            hint,
            style: TextStyle(
              color: enabled ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
        ),
        disabledHint: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            hint,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        icon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(
            Icons.arrow_drop_down,
            color: enabled ? AppColors.primaryColor : Colors.grey[400],
          ),
        ),
        onChanged: enabled ? onChanged : null,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          );
        }).toList(),
        dropdownColor: Colors.white,
        style: TextStyle(
          color: enabled ? Colors.black : Colors.grey[600],
          fontSize: 14,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        elevation: 4,
        menuMaxHeight: 300,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        /// ---------- Category ----------
        Text(
          'Category',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        _buildDropdown(
          hint: 'Select Category',
          items: catNames,
          value: selectedCatName,
          loading: loadingCats,
          error: catError,
          onRetry: _loadCategories,
          onChanged: (String? v) {
            if (v == null) return;

            final int idx = catNames.indexOf(v);
            setState(() {
              selectedCatName = v;
              selectedCatId = idx != -1 ? catIds[idx] : null;
              // Reset subcategory selection
              selectedSubName = null;
              selectedSubId = null;
              subNames.clear();
              subIds.clear();
              subError = '';
            });

            widget.onCategoryChanged(v, selectedCatId);

            if (selectedCatId != null) {
              _loadSubCategories(selectedCatId!);
            }
          },
        ),
        const SizedBox(height: AppSizes.lg),

        /// ---------- Sub-Category ----------
        Text(
          'Sub-Category',
          style: TextStyle(
            color: selectedCatName != null ? AppColors.primaryColor : Colors.grey,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        _buildDropdown(
          hint: selectedCatName != null
              ? 'Select Sub-Category'
              : 'Select a category first',
          items: subNames,
          value: selectedSubName,
          loading: loadingSubs,
          enabled: selectedCatName != null,
          error: subError,
          onChanged: (String? v) {
            if (v == null) return;

            final int idx = subNames.indexOf(v);
            setState(() {
              selectedSubName = v;
              selectedSubId = idx != -1 ? subIds[idx] : null;
            });

            widget.onSubCategoryChanged(v, selectedSubId);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}