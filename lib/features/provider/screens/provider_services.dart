/**
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/common/widgets/reusable_button.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/features/provider/widgets/provider_service_main_card.dart';
import 'package:manx_mate/features/provider/widgets/provider_top_card.dart';
import '../../../core/common/widgets/time_picker_widget.dart';
import '../../home/widget/add_service_bottomsheet.dart';

/// ===================================================================
/// CONTROLLER: Provider Services (Listing)
/// ===================================================================
class ProviderServicesController extends GetxController {
  var isLoading = false.obs;
  var services = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  final String baseUrl = 'https://d7001.sobhoy.com/api/v1';

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('accessToken');
    } catch (e) {
      print('❌ Error retrieving token: $e');
      return null;
    }
  }

  Future<void> fetchServices() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      services.clear();

      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'Please login again.';
        isLoading.value = false;
        return;
      }

      final url = Uri.parse('$baseUrl/service/provider/self');
      print('🌐 Fetching provider services from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['data']['data'] ?? [];
          services.value = list.cast<Map<String, dynamic>>();
          print('✅ Loaded ${services.length} provider services');
        } else {
          errorMessage.value = data['message'] ?? 'Failed to fetch services';
        }
      } else {
        errorMessage.value = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }
}

/// ===================================================================
/// CONTROLLER: Provider Pending (Ongoing) Bookings
/// ===================================================================
class ProviderPendingController extends GetxController {
  var isLoading = false.obs;
  var bookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  final String baseUrl = 'https://d7001.sobhoy.com/api/v1';

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('accessToken');
    } catch (e) {
      print('❌ Error retrieving token: $e');
      return null;
    }
  }

  Future<void> fetchBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      bookings.clear();

      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'Please login again.';
        isLoading.value = false;
        return;
      }

      final url = Uri.parse('$baseUrl/booking/provider?status=accepted');
      print('🌐 Fetching provider pending bookings from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['data']['data'] ?? [];
          bookings.value = list.cast<Map<String, dynamic>>();
          print('✅ Loaded ${bookings.length} pending bookings');
        } else {
          errorMessage.value = data['message'] ?? 'Failed to fetch data';
        }
      } else {
        errorMessage.value = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }
}

/// ===================================================================
/// CONTROLLER: Provider Completed Bookings
/// ===================================================================
class ProviderCompletedController extends GetxController {
  var isLoading = false.obs;
  var bookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  final String baseUrl = 'https://d7001.sobhoy.com/api/v1';

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('accessToken');
    } catch (e) {
      print('❌ Error retrieving token: $e');
      return null;
    }
  }

  Future<void> fetchBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      bookings.clear();

      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'Please login again.';
        isLoading.value = false;
        return;
      }

      final url = Uri.parse('$baseUrl/booking/provider?status=completed');
      print('🌐 Fetching provider completed bookings from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['data']['data'] ?? [];
          bookings.value = list.cast<Map<String, dynamic>>();
          print('✅ Loaded ${bookings.length} completed bookings');
        } else {
          errorMessage.value = data['message'] ?? 'Failed to fetch data';
        }
      } else {
        errorMessage.value = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }
}

/// ===================================================================
/// CONTROLLER: Provider Cancelled Bookings
/// ===================================================================
class ProviderCancelledController extends GetxController {
  var isLoading = false.obs;
  var bookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  final String baseUrl = 'https://d7001.sobhoy.com/api/v1';

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('accessToken');
    } catch (e) {
      print('❌ Error retrieving token: $e');
      return null;
    }
  }

  Future<void> fetchBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      bookings.clear();

      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'Please login again.';
        isLoading.value = false;
        return;
      }

      final url = Uri.parse('$baseUrl/booking/provider?status=cancelled');
      print('🌐 Fetching provider cancelled bookings from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['data']['data'] ?? [];
          bookings.value = list.cast<Map<String, dynamic>>();
          print('✅ Loaded ${bookings.length} cancelled bookings');
        } else {
          errorMessage.value = data['message'] ?? 'Failed to fetch data';
        }
      } else {
        errorMessage.value = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }
}

/// ===================================================================
/// SCREEN: Provider Services Screen
/// ===================================================================
class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({super.key});

  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final servicesController = Get.put(ProviderServicesController());
  final pendingController = Get.put(ProviderPendingController());
  final completedController = Get.put(ProviderCompletedController());
  final cancelledController = Get.put(ProviderCancelledController());

  // Controllers for Add Service Form
  final timeController = Get.put(TimeController());
  final serviceNameTEController = TextEditingController();
  final locationTEController = TextEditingController();
  final additionalNoteTEController = TextEditingController();
  final dateTEController = TextEditingController();
  final typeTEController = TextEditingController();
  final addServiceFormKey = GlobalKey<FormState>();

  // 🔑 KEY: Store reference to the bottom sheet state
  final GlobalKey<AddServiceBottomSheetState> _bottomSheetKey = GlobalKey<AddServiceBottomSheetState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      servicesController.fetchServices();
      pendingController.fetchBookings();
      completedController.fetchBookings();
      cancelledController.fetchBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    serviceNameTEController.dispose();
    locationTEController.dispose();
    additionalNoteTEController.dispose();
    dateTEController.dispose();
    typeTEController.dispose();
    super.dispose();
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final subCategory = service['subCategory'] ?? {};
    final name = service['name'] ?? 'No Name';
    final description = service['description'] ?? 'No Description';
    final status = service['status'] ?? 'N/A';
    final imagePath = service['image'];

    final imageUrl = (imagePath != null && imagePath.toString().isNotEmpty)
        ? 'https://d7001.sobhoy.com/${imagePath.toString().replaceFirst(RegExp(r"^/"), "")}'
        : 'https://via.placeholder.com/150';

    return ProviderServiceMainCard(
      serviceImageUrl: imageUrl,
      serviceStatus: status,
      serviceTitle: name,
      serviceDetails: description,
      serviceLocation: subCategory['name'] ?? 'No Category',
      providerImageUrl: imageUrl,
      providerName: 'Your Service',
      showBottomPart: true,
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final author = booking['author'] ?? {};
    final category = booking['category'] ?? {};
    final location = booking['location'] ?? 'Unknown';
    final bookingDate = booking['bookingDate'] ?? '';
    final status = booking['status'] ?? 'N/A';

    String formattedDate = '';
    try {
      final date = DateTime.parse(bookingDate);
      formattedDate = '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      formattedDate = 'Invalid date';
    }

    final imagePath = author['image'];
    final imageUrl = (imagePath != null && imagePath.toString().isNotEmpty)
        ? 'https://d7001.sobhoy.com/${imagePath.toString().replaceFirst(RegExp(r"^/"), "")}'
        : 'https://via.placeholder.com/150';

    return ProviderServiceMainCard(
      serviceImageUrl: imageUrl,
      serviceStatus: status,
      serviceTitle: category['name'] ?? 'No Category',
      serviceDetails: location,
      serviceLocation: formattedDate,
      providerImageUrl: imageUrl,
      providerName: author['name'] ?? 'Unknown',
      showBottomPart: true,
    );
  }

  Widget _buildEmptyState(String message, VoidCallback onRefresh) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.lg),
          SizedBox(
            width: 150,
            child: ReusableButton(
              onTap: onRefresh,
              label: "Refresh",
            ),
          ),
          const SizedBox(height: AppSizes.md),
          TextButton(
            onPressed: onRefresh,
            child: const Text(
              "Pull down to refresh",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            error,
            style: TextStyle(
              color: Colors.red[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.lg),
          SizedBox(
            width: 150,
            child: ReusableButton(
              onTap: onRetry,
              label: "Try Again",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesListView() {
    if (servicesController.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    if (servicesController.errorMessage.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: () async => servicesController.fetchServices(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: _buildErrorState(
              servicesController.errorMessage.value,
              servicesController.fetchServices,
            ),
          ),
        ),
      );
    }

    if (servicesController.services.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => servicesController.fetchServices(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: _buildEmptyState(
              'No services listed yet',
              servicesController.fetchServices,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => servicesController.fetchServices(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.md),
        itemCount: servicesController.services.length,
        itemBuilder: (context, i) => _buildServiceCard(servicesController.services[i]),
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.md),
      ),
    );
  }

  Widget _buildBookingsListView(
      RxList<Map<String, dynamic>> list,
      RxBool isLoading,
      RxString error,
      String emptyMessage,
      VoidCallback onRetry,
      ) {
    if (isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    if (error.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: () async => onRetry(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: _buildErrorState(error.value, onRetry),
          ),
        ),
      );
    }

    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => onRetry(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: _buildEmptyState(emptyMessage, onRetry),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.md),
        itemCount: list.length,
        itemBuilder: (context, i) => _buildBookingCard(list[i]),
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.md),
      ),
    );
  }

  void _clearFormFields() {
    serviceNameTEController.clear();
    dateTEController.clear();
    additionalNoteTEController.clear();
    locationTEController.clear();
    typeTEController.clear();
  }

  void _handleAddService() async {
    print('✅ Service submission completed - callback triggered');

    // Clear form fields
    _clearFormFields();

    // Refresh the services list
    await servicesController.fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _tabController.index == 0
          ? SizedBox(
        width: context.screenWidth * 0.9,
        height: 50,
        child: ReusableButton(
          onTap: () {
            // Show the bottom sheet
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => Container(
                height: context.screenHeight * 0.75,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Add a new service',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    // Form
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: AddServiceBottomSheet(
                          key: _bottomSheetKey,
                          serviceNameTEController: serviceNameTEController,
                          dateTEController: dateTEController,
                          timeController: timeController,
                          locationTEController: locationTEController,
                          additionalNoteTEController: additionalNoteTEController,
                          typeTEController: typeTEController,
                          formKey: addServiceFormKey,
                          onSubmit: _handleAddService,
                        ),
                      ),
                    ),
                    // 🚀 SUBMIT BUTTON - THIS TRIGGERS THE POST API
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ReusableButton(
                          onTap: () {
                            print('🔥🔥🔥 Add Service Button Clicked! 🔥🔥🔥');
                            // Call the submit function from the bottom sheet
                            _bottomSheetKey.currentState?.submitForm();
                          },
                          label: "Add Service",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          label: "Add Service",
        ),
      )
          : const SizedBox.shrink(),
      body: SafeArea(
        child: Column(
          children: [
            const ProviderTopBar(),
            const SizedBox(height: AppSizes.md),
            PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  isScrollable: true,
                  indicatorColor: AppColors.primaryColor,
                  indicatorWeight: 5,
                  labelColor: Colors.black87,
                  labelStyle:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                  tabs: const [
                    Tab(text: "Listing"),
                    Tab(text: "Quote"),
                    Tab(text: "Cancel"),
                    Tab(text: "Ongoing"),
                    Tab(text: "Complete"),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 🔹 Listing Tab - Provider Services
                  Obx(() => _buildServicesListView()),

                  // 🔹 Quote Tab - Static for now
                  _staticPlaceholder("Quotes"),

                  // 🔹 Cancelled Tab
                  Obx(() => _buildBookingsListView(
                    cancelledController.bookings,
                    cancelledController.isLoading,
                    cancelledController.errorMessage,
                    'No cancelled bookings',
                    cancelledController.fetchBookings,
                  )),

                  // 🔹 Ongoing (Pending) Tab
                  Obx(() => _buildBookingsListView(
                    pendingController.bookings,
                    pendingController.isLoading,
                    pendingController.errorMessage,
                    'No ongoing bookings',
                    pendingController.fetchBookings,
                  )),

                  // 🔹 Completed Tab
                  Obx(() => _buildBookingsListView(
                    completedController.bookings,
                    completedController.isLoading,
                    completedController.errorMessage,
                    'No completed bookings yet',
                    completedController.fetchBookings,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _staticPlaceholder(String title) {
    return RefreshIndicator(
      onRefresh: () async {
        return;
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.construction_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  Text(
                    "This section is coming soon",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}*/








import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/common/widgets/reusable_button.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/features/provider/widgets/provider_service_main_card.dart';
import 'package:manx_mate/features/provider/widgets/provider_top_card.dart';
import '../../../core/common/widgets/time_picker_widget.dart';
import '../../home/widget/add_service_bottomsheet.dart';

/// ===================================================================
/// CONTROLLER: Provider Services (Listing)
/// ===================================================================
class ProviderServicesController extends GetxController {
  var isLoading = false.obs;
  var services = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  final String baseUrl = 'https://d7001.sobhoy.com/api/v1';

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('accessToken');
    } catch (e) {
      print('❌ Error retrieving token: $e');
      return null;
    }
  }

  Future<void> fetchServices() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      services.clear();

      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'Please login again.';
        isLoading.value = false;
        return;
      }

      final url = Uri.parse('$baseUrl/service/provider/self');
      print('🌐 Fetching provider services from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['data']['data'] ?? [];
          services.value = list.cast<Map<String, dynamic>>();
          print('✅ Loaded ${services.length} provider services');
        } else {
          errorMessage.value = data['message'] ?? 'Failed to fetch services';
        }
      } else {
        errorMessage.value = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }
}

/// ===================================================================
/// CONTROLLER: Provider Pending (Ongoing) Bookings
/// ===================================================================
class ProviderPendingController extends GetxController {
  var isLoading = false.obs;
  var bookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  final String baseUrl = 'https://d7001.sobhoy.com/api/v1';

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('accessToken');
    } catch (e) {
      print('❌ Error retrieving token: $e');
      return null;
    }
  }

  Future<void> fetchBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      bookings.clear();

      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'Please login again.';
        isLoading.value = false;
        return;
      }

      final url = Uri.parse('$baseUrl/booking/provider?status=accepted');
      print('🌐 Fetching provider pending bookings from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['data']['data'] ?? [];
          bookings.value = list.cast<Map<String, dynamic>>();
          print('✅ Loaded ${bookings.length} pending bookings');
        } else {
          errorMessage.value = data['message'] ?? 'Failed to fetch data';
        }
      } else {
        errorMessage.value = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }
}

/// ===================================================================
/// CONTROLLER: Provider Completed Bookings
/// ===================================================================
class ProviderCompletedController extends GetxController {
  var isLoading = false.obs;
  var bookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  final String baseUrl = 'https://d7001.sobhoy.com/api/v1';

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('accessToken');
    } catch (e) {
      print('❌ Error retrieving token: $e');
      return null;
    }
  }

  Future<void> fetchBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      bookings.clear();

      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'Please login again.';
        isLoading.value = false;
        return;
      }

      final url = Uri.parse('$baseUrl/booking/provider?status=completed');
      print('🌐 Fetching provider completed bookings from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['data']['data'] ?? [];
          bookings.value = list.cast<Map<String, dynamic>>();
          print('✅ Loaded ${bookings.length} completed bookings');
        } else {
          errorMessage.value = data['message'] ?? 'Failed to fetch data';
        }
      } else {
        errorMessage.value = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }
}

/// ===================================================================
/// CONTROLLER: Provider Cancelled Bookings
/// ===================================================================
class ProviderCancelledController extends GetxController {
  var isLoading = false.obs;
  var bookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  final String baseUrl = 'https://d7001.sobhoy.com/api/v1';

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('accessToken');
    } catch (e) {
      print('❌ Error retrieving token: $e');
      return null;
    }
  }

  Future<void> fetchBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      bookings.clear();

      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'Please login again.';
        isLoading.value = false;
        return;
      }

      final url = Uri.parse('$baseUrl/booking/provider?status=cancelled');
      print('🌐 Fetching provider cancelled bookings from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['data']['data'] ?? [];
          bookings.value = list.cast<Map<String, dynamic>>();
          print('✅ Loaded ${bookings.length} cancelled bookings');
        } else {
          errorMessage.value = data['message'] ?? 'Failed to fetch data';
        }
      } else {
        errorMessage.value = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }
}

/// ===================================================================
/// CONTROLLER: Provider Quote (Pending) Bookings
/// ===================================================================
class ProviderQuoteController extends GetxController {
  var isLoading = false.obs;
  var bookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  final String baseUrl = 'https://d7001.sobhoy.com/api/v1';

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('accessToken');
    } catch (e) {
      print('❌ Error retrieving token: $e');
      return null;
    }
  }

  Future<void> fetchBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      bookings.clear();

      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'Please login again.';
        isLoading.value = false;
        return;
      }

      final url = Uri.parse('$baseUrl/booking/provider?status=pending');
      print('🌐 Fetching provider quote (pending) bookings from: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['data']['data'] ?? [];
          bookings.value = list.cast<Map<String, dynamic>>();
          print('✅ Loaded ${bookings.length} quote (pending) bookings');
        } else {
          errorMessage.value = data['message'] ?? 'Failed to fetch data';
        }
      } else {
        errorMessage.value = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }
}

/// ===================================================================
/// SCREEN: Provider Services Screen
/// ===================================================================
class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({super.key});

  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final servicesController = Get.put(ProviderServicesController());
  final pendingController = Get.put(ProviderPendingController());
  final completedController = Get.put(ProviderCompletedController());
  final cancelledController = Get.put(ProviderCancelledController());
  final quoteController = Get.put(ProviderQuoteController());

  // Controllers for Add Service Form
  final timeController = Get.put(TimeController());
  final serviceNameTEController = TextEditingController();
  final locationTEController = TextEditingController();
  final additionalNoteTEController = TextEditingController();
  final dateTEController = TextEditingController();
  final typeTEController = TextEditingController();
  final addServiceFormKey = GlobalKey<FormState>();

  // 🔑 KEY: Store reference to the bottom sheet state
  final GlobalKey<AddServiceBottomSheetState> _bottomSheetKey = GlobalKey<AddServiceBottomSheetState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      servicesController.fetchServices();
      pendingController.fetchBookings();
      completedController.fetchBookings();
      cancelledController.fetchBookings();
      quoteController.fetchBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    serviceNameTEController.dispose();
    locationTEController.dispose();
    additionalNoteTEController.dispose();
    dateTEController.dispose();
    typeTEController.dispose();
    super.dispose();
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final subCategory = service['subCategory'] ?? {};
    final name = service['name'] ?? 'No Name';
    final description = service['description'] ?? 'No Description';
    final status = service['status'] ?? 'N/A';
    final imagePath = service['image'];

    final imageUrl = (imagePath != null && imagePath.toString().isNotEmpty)
        ? 'https://d7001.sobhoy.com/${imagePath.toString().replaceFirst(RegExp(r"^/"), "")}'
        : 'https://via.placeholder.com/150';

    return ProviderServiceMainCard(
      serviceImageUrl: imageUrl,
      serviceStatus: status,
      serviceTitle: name,
      serviceDetails: description,
      serviceLocation: subCategory['name'] ?? 'No Category',
      providerImageUrl: imageUrl,
      providerName: 'Your Service',
      showBottomPart: true,
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final author = booking['author'] ?? {};
    final category = booking['category'] ?? {};
    final location = booking['location'] ?? 'Unknown';
    final description = booking['description'] ?? 'No description';
    final bookingDate = booking['bookingDate'] ?? '';
    final status = booking['status'] ?? 'N/A';

    String formattedDate = '';
    try {
      final date = DateTime.parse(bookingDate);
      formattedDate = '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      formattedDate = 'Invalid date';
    }

    final imagePath = author['image'];
    final imageUrl = (imagePath != null && imagePath.toString().isNotEmpty)
        ? 'https://d7001.sobhoy.com/${imagePath.toString().replaceFirst(RegExp(r"^/"), "")}'
        : 'https://via.placeholder.com/150';

    return ProviderServiceMainCard(
      serviceImageUrl: imageUrl,
      serviceStatus: status,
      serviceTitle: category['name'] ?? 'No Category',
      serviceDetails: description, // Use description instead of location for more context
      serviceLocation: location, // Use location here
      providerImageUrl: imageUrl,
      providerName: author['name'] ?? 'Unknown',
      showBottomPart: true,
    );
  }

  Widget _buildEmptyState(String message, VoidCallback onRefresh) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.lg),
          SizedBox(
            width: 150,
            child: ReusableButton(
              onTap: onRefresh,
              label: "Refresh",
            ),
          ),
          const SizedBox(height: AppSizes.md),
          TextButton(
            onPressed: onRefresh,
            child: const Text(
              "Pull down to refresh",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            error,
            style: TextStyle(
              color: Colors.red[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.lg),
          SizedBox(
            width: 150,
            child: ReusableButton(
              onTap: onRetry,
              label: "Try Again",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesListView() {
    if (servicesController.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    if (servicesController.errorMessage.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: () async => servicesController.fetchServices(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: _buildErrorState(
              servicesController.errorMessage.value,
              servicesController.fetchServices,
            ),
          ),
        ),
      );
    }

    if (servicesController.services.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => servicesController.fetchServices(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: _buildEmptyState(
              'No services listed yet',
              servicesController.fetchServices,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => servicesController.fetchServices(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.md),
        itemCount: servicesController.services.length,
        itemBuilder: (context, i) => _buildServiceCard(servicesController.services[i]),
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.md),
      ),
    );
  }

  Widget _buildBookingsListView(
      RxList<Map<String, dynamic>> list,
      RxBool isLoading,
      RxString error,
      String emptyMessage,
      VoidCallback onRetry,
      ) {
    if (isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    if (error.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: () async => onRetry(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: _buildErrorState(error.value, onRetry),
          ),
        ),
      );
    }

    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => onRetry(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: _buildEmptyState(emptyMessage, onRetry),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.md),
        itemCount: list.length,
        itemBuilder: (context, i) => _buildBookingCard(list[i]),
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.md),
      ),
    );
  }

  void _clearFormFields() {
    serviceNameTEController.clear();
    dateTEController.clear();
    additionalNoteTEController.clear();
    locationTEController.clear();
    typeTEController.clear();
  }

  void _handleAddService() async {
    print('✅ Service submission completed - callback triggered');

    // Clear form fields
    _clearFormFields();

    // Refresh the services list
    await servicesController.fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _tabController.index == 0
          ? SizedBox(
        width: context.screenWidth * 0.9,
        height: 50,
        child: ReusableButton(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => Container(
                height: context.screenHeight * 0.75,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Add a new service',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: AddServiceBottomSheet(
                          key: _bottomSheetKey,
                          serviceNameTEController: serviceNameTEController,
                          dateTEController: dateTEController,
                          timeController: timeController,
                          locationTEController: locationTEController,
                          additionalNoteTEController: additionalNoteTEController,
                          typeTEController: typeTEController,
                          formKey: addServiceFormKey,
                          onSubmit: _handleAddService,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ReusableButton(
                          onTap: () {
                            print('🔥🔥🔥 Add Service Button Clicked! 🔥🔥🔥');
                            _bottomSheetKey.currentState?.submitForm();
                          },
                          label: "Add Service",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          label: "Add Service",
        ),
      )
          : const SizedBox.shrink(),
      body: SafeArea(
        child: Column(
          children: [
            const ProviderTopBar(),
            const SizedBox(height: AppSizes.md),
            PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  isScrollable: true,
                  indicatorColor: AppColors.primaryColor,
                  indicatorWeight: 5,
                  labelColor: Colors.black87,
                  labelStyle:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                  tabs: const [
                    Tab(text: "Listing"),
                    Tab(text: "Quote"),
                    Tab(text: "Cancel"),
                    Tab(text: "Ongoing"),
                    Tab(text: "Complete"),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 🔹 Listing Tab - Provider Services
                  Obx(() => _buildServicesListView()),

                  // 🔹 Quote Tab - Now with real data from API
                  Obx(() => _buildBookingsListView(
                    quoteController.bookings,
                    quoteController.isLoading,
                    quoteController.errorMessage,
                    'No pending quotes',
                    quoteController.fetchBookings,
                  )),

                  // 🔹 Cancelled Tab
                  Obx(() => _buildBookingsListView(
                    cancelledController.bookings,
                    cancelledController.isLoading,
                    cancelledController.errorMessage,
                    'No cancelled bookings',
                    cancelledController.fetchBookings,
                  )),

                  // 🔹 Ongoing (Pending) Tab
                  Obx(() => _buildBookingsListView(
                    pendingController.bookings,
                    pendingController.isLoading,
                    pendingController.errorMessage,
                    'No ongoing bookings',
                    pendingController.fetchBookings,
                  )),

                  // 🔹 Completed Tab
                  Obx(() => _buildBookingsListView(
                    completedController.bookings,
                    completedController.isLoading,
                    completedController.errorMessage,
                    'No completed bookings yet',
                    completedController.fetchBookings,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

