import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/network/network_response.dart';
import '../../../core/utils/api/app_url.dart';

class PrivacyPolicyTemplateController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

  // Observables
  final RxString _appBarTitle = ''.obs;  // Title for AppBar (from arguments)
  final RxString _contentTitle = ''.obs;  // Title from API (for content body)
  final RxString _content = ''.obs;
  final RxString _updatedAt = ''.obs;
  final RxBool _isLoading = true.obs;
  final RxString _pageType = ''.obs;

  // Getters
  String get appBarTitle => _appBarTitle.value;
  String get contentTitle => _contentTitle.value;
  String get content => _content.value;
  String get updatedAt => _updatedAt.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _loadPageData();
  }

  /// Load page data from arguments
  void _loadPageData() {
    final Map<String, dynamic>? arguments = Get.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      _pageType.value = arguments['type'] ?? '';
      _appBarTitle.value = arguments['title'] ?? '';  // Keep original title for AppBar

      // Fetch content based on page type
      if (_pageType.value.isNotEmpty) {
        fetchContent(_pageType.value);
      }
    }
  }

  /// Get API endpoint based on page type
  String _getEndpoint(String type) {
    switch (type.toLowerCase()) {
      case 'privacy_policy':
        return AppUrl.privacyPolicy;
      case 'terms_and_conditions':
        return AppUrl.termsAndConditions;
      case 'about_us':
        return AppUrl.aboutUs;
      case 'host_policy':
        return AppUrl.hostPolicy;
      case 'contact_us':
        return AppUrl.contactUs;
      default:
        return AppUrl.privacyPolicy;
    }
  }

  /// Format date to Month-Day-Year
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';

    try {
      final DateTime date = DateTime.parse(dateString);
      final DateFormat formatter = DateFormat('MMMM dd, yyyy');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// Fetch content from API
  Future<void> fetchContent(String type) async {
    try {
      _isLoading.value = true;

      final String endpoint = _getEndpoint(type);
      final NetworkResponse response = await _networkCaller.getRequest(endpoint);

      if (response.isSuccess && response.jsonResponse != null) {
        final data = response.jsonResponse!['data'];

        if (data != null) {
          _contentTitle.value = data['title'] ?? '';  // API title for content body
          _content.value = data['content'] ?? '';
          _updatedAt.value = _formatDate(data['updatedAt']);
        } else {
          _showError('No data available');
        }
      } else {
        _showError(response.errorMessage ?? 'Failed to load content');
      }
    } catch (e) {
      _showError('Failed to load content: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Retry fetching content
  void retry() {
    if (_pageType.value.isNotEmpty) {
      fetchContent(_pageType.value);
    }
  }

  /// Show error message
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      colorText: Get.theme.colorScheme.error,
      duration: const Duration(seconds: 3),
    );
  }

  /// Navigate back
  void goBack() {
    Get.back();
  }
}


