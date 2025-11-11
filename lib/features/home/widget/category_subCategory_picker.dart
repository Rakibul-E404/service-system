import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  List<String> catNames = [];
  List<String> catIds   = [];
  List<String> subNames = [];
  List<String> subIds   = [];

  String? selectedCatName;
  String? selectedCatId;
  String? selectedSubName;
  String? selectedSubId;

  bool loadingCats = false;
  bool loadingSubs = false;
  String catError = '';

  @override
  void initState() {
    super.initState();
    // Use post frame callback to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  /// -------------------------------------------------------------
  /// Load categories (uses HomeController logic)
  /// -------------------------------------------------------------
  Future<void> _loadCategories() async {
    if (!mounted) return;

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
          catError = e.toString();
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
    final cats = _homeCtrl.categories;
    catNames = cats.map((e) => e.name).toList();
    catIds   = cats.map((e) => e.id).toList();

    debugPrint('📋 Categories loaded: ${catNames.length} items');
  }

  /// -------------------------------------------------------------
  /// Load sub-categories for selected category
  /// -------------------------------------------------------------

  Future<void> _loadSubCategories(String catId) async {
    if (catId.isEmpty || !mounted) return;

    setState(() {
      loadingSubs = true;
      subNames.clear();
      subIds.clear();
      selectedSubName = null;
      selectedSubId = null;
    });

    try {
      debugPrint('🔄 Fetching subcategories for category: $catId');
      await _homeCtrl.fetchSubcategories(catId);

      if (mounted) {
        final subs = _homeCtrl.subcategories;
        setState(() {
          subNames = subs.map((e) => e['name']?.toString() ?? 'Unnamed').toList();
          subIds   = subs.map((e) => e['_id']?.toString() ?? '').toList();
        });

        debugPrint('📋 Subcategories loaded: ${subNames.length} items');
      }
    } catch (e) {
      debugPrint('❌ Error loading subcategories: $e');
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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryColor, width: 2),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: loading
          ? const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Loading...'),
          ],
        ),
      )
          : error != null && error.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
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
        ),
      )
          : DropdownButton<String>(
        isExpanded: true,
        value: value,
        hint: Text(hint, style: TextStyle(color: Colors.grey[600])),
        underline: const SizedBox(),
        disabledHint: Text(
          hint,
          style: TextStyle(color: Colors.grey[400]),
        ),
        onChanged: enabled ? onChanged : null,
        items: items
            .map((e) => DropdownMenuItem(
          value: e,
          child: Text(e),
        ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// ---------- Category ----------
        _buildDropdown(
          hint: 'Select Category',
          items: catNames,
          value: selectedCatName,
          loading: loadingCats,
          error: catError,
          onRetry: _loadCategories,
          onChanged: (v) {
            if (v == null) return;

            final idx = catNames.indexOf(v);
            setState(() {
              selectedCatName = v;
              selectedCatId = idx != -1 ? catIds[idx] : null;
              // Reset subcategory selection
              selectedSubName = null;
              selectedSubId = null;
              subNames.clear();
              subIds.clear();
            });

            widget.onCategoryChanged(v, selectedCatId);

            if (selectedCatId != null) {
              _loadSubCategories(selectedCatId!);
            }
          },
        ),
        const SizedBox(height: AppSizes.md),

        /// ---------- Sub-Category ----------
        _buildDropdown(
          hint: 'Select Sub-Category',
          items: subNames,
          value: selectedSubName,
          loading: loadingSubs,
          enabled: selectedCatName != null && subNames.isNotEmpty,
          onChanged: (v) {
            if (v == null) return;

            final idx = subNames.indexOf(v);
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
    // Clean up if needed
    super.dispose();
  }
}
