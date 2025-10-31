/**
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:manx_mate/core/common/widgets/reusable_button.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/features/provider/widgets/provider_top_card.dart';

import '../../../core/common/widgets/app_bottom_sheet.dart';
import '../../../core/common/widgets/time_picker_widget.dart';
import '../../home/widget/inquiry_bottom_sheet.dart';
import '../widgets/provider_service_main_card.dart';
import '../widgets/provider_service_secondary_card.dart';

class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({super.key});

  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 5, vsync: this); // Initialize TabController with 3 tabs
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose the TabController when done
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _serviceNameTEController = TextEditingController();
    final TextEditingController _locationTEController = TextEditingController();
    final TextEditingController _additionalNoteTEController = TextEditingController();
    final TextEditingController _dateTEController = TextEditingController();
    final TextEditingController _typeTEController = TextEditingController();
    final TimeController timeController = Get.put(TimeController());

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _tabController.index == 0
          ? SizedBox(
              width: context.screenWidth * 0.9,
              height: 50,
              child: ReusableButton(
                onTap: () {
                  CustomModalBottomSheet.show(
                    title: 'Add a new service',
                    height: context.screenHeight * 0.6,
                    context: context,
                    buttonText: 'Add',
                    onButtonPressed: () {
                      // Your action here
                      Navigator.pop(context);
                    },
                    child: AddServiceBottomSheet(
                      serviceNameTEController: _serviceNameTEController,
                      dateTEController: _dateTEController,
                      timeController: timeController,
                      locationTEController: _locationTEController,
                      additionalNoteTEController: _additionalNoteTEController,
                      typeTEController: _typeTEController,
                    ),
                  );
                },
                label: "Add Service",
              ),
            )
          : const SizedBox.shrink(),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const ProviderTopBar(),
            const SizedBox(height: AppSizes.md),

            ///==================> Provider Listing Card ==============>
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
                  tabAlignment: TabAlignment.center,
                  labelColor: Colors.black87,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                  tabs: const <Widget>[
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
                children: <Widget>[
                  /// ========= Listings ========>
                  ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.lg,
                    ),

                    shrinkWrap: true,
                    itemCount: 5,
                    // Increased count for testing
                    itemBuilder: (BuildContext context, int index) {
                      return const ProviderServiceMainCard(
                        serviceImageUrl: "serviceImageUrl",
                        serviceStatus: null,
                        serviceTitle: "Tutor Pro Academy",
                        serviceDetails: "Experts in Math & Science...",
                        serviceLocation: "Cork ,IreLand",
                        providerImageUrl:
                            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=300&fit=crop',
                        providerName: "Afsana Hamid",
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: AppSizes.md);
                    },
                  ),


                  /// ============= Secondary Card =========>
                  ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.lg,
                    ),

                    itemCount: 3,
                    itemBuilder: (BuildContext context, int index) {
                      return const ProviderServiceSecondaryCard(
                        serviceImageUrl: "serviceImageUrl",
                        serviceTitle: "serviceTitle",
                        serviceDetails: "serviceDetails",
                        providerName: "providerName",
                        showBottomPart: true,
                        time: "time",
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: AppSizes.md);
                    },
                  ),

                  ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.lg,
                    ),

                    itemCount: 8,
                    itemBuilder: (BuildContext context, int index) {
                      return const ProviderServiceMainCard(
                        serviceImageUrl: "serviceImageUrl",
                        serviceStatus: "cancelled",
                        serviceTitle: "Tutor Pro Academy",
                        serviceDetails: "Experts in Math & Science...",
                        serviceLocation: "Cork ,IreLand",
                        providerImageUrl:
                            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=300&fit=crop',
                        providerName: "Afsana Hamid",
                        showBottomPart: true,
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: AppSizes.md);
                    },
                  ),
                  ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.lg,
                    ),

                    itemCount: 8,
                    itemBuilder: (BuildContext context, int index) {
                      return const ProviderServiceMainCard(
                        serviceImageUrl: "serviceImageUrl",
                        serviceStatus: "requested",
                        serviceTitle: "Tutor Pro Academy",
                        serviceDetails: "Experts in Math & Science...",
                        serviceLocation: "Cork ,IreLand",
                        providerImageUrl:
                            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=300&fit=crop',
                        providerName: "Afsana Hamid",
                        showBottomPart: true,
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: AppSizes.md);
                    },
                  ),
                  ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.lg,
                    ),

                    itemCount: 8,
                    itemBuilder: (BuildContext context, int index) {
                      return const ProviderServiceMainCard(
                        serviceImageUrl: "serviceImageUrl",
                        serviceStatus: "completed",
                        serviceTitle: "Tutor Pro Academy",
                        serviceDetails: "Experts in Math & Science...",
                        serviceLocation: "Cork ,IreLand",
                        providerImageUrl:
                            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=300&fit=crop',
                        providerName: "Afsana Hamid",
                        showBottomPart: true,
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: AppSizes.md);
                    },
                  ),
                ],
              ),
            ),
           const SizedBox(
              height: AppSizes.xxxL,
            ),
          ],
        ),
      ),
    );
  }
}
*/

















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
import 'package:manx_mate/features/provider/widgets/provider_service_secondary_card.dart';
import 'package:manx_mate/features/provider/widgets/provider_top_card.dart';
import '../../../core/common/widgets/app_bottom_sheet.dart';
import '../../../core/common/widgets/time_picker_widget.dart';
import '../../home/widget/inquiry_bottom_sheet.dart';

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

      final url = Uri.parse('$baseUrl/booking/provider?status=pending');
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
  final pendingController = Get.put(ProviderPendingController());
  final completedController = Get.put(ProviderCompletedController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pendingController.fetchBookings();
      completedController.fetchBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildProviderCard(Map<String, dynamic> booking) {
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

  Widget _buildListView(
      RxList<Map<String, dynamic>> list,
      RxBool isLoading,
      RxString error,
      String emptyMessage,
      VoidCallback onRetry,
      ) {
    if (isLoading.value) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
    }
    if (error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(error.value, style: const TextStyle(color: Colors.red)),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (list.isEmpty) {
      return Center(child: Text(emptyMessage, style: const TextStyle(color: Colors.grey)));
    }

    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.md),
        itemCount: list.length,
        itemBuilder: (context, i) => _buildProviderCard(list[i]),
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.md),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeController = Get.put(TimeController());
    final serviceNameTEController = TextEditingController();
    final locationTEController = TextEditingController();
    final additionalNoteTEController = TextEditingController();
    final dateTEController = TextEditingController();
    final typeTEController = TextEditingController();

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _tabController.index == 0
          ? SizedBox(
        width: context.screenWidth * 0.9,
        height: 50,
        child: ReusableButton(
          onTap: () {
            CustomModalBottomSheet.show(
              title: 'Add a new service',
              height: context.screenHeight * 0.6,
              context: context,
              buttonText: 'Add',
              onButtonPressed: () => Navigator.pop(context),
              child: AddServiceBottomSheet(
                serviceNameTEController: serviceNameTEController,
                dateTEController: dateTEController,
                timeController: timeController,
                locationTEController: locationTEController,
                additionalNoteTEController: additionalNoteTEController,
                typeTEController: typeTEController,
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
                  _staticPlaceholder("Listing Services"),
                  _staticPlaceholder("Quotes"),
                  _staticPlaceholder("Cancelled Services"),
                  // 🔹 Pending (Ongoing)
                  Obx(() => _buildListView(
                    pendingController.bookings,
                    pendingController.isLoading,
                    pendingController.errorMessage,
                    'No ongoing (pending) bookings',
                    pendingController.fetchBookings,
                  )),
                  // 🔹 Completed
                  Obx(() => _buildListView(
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
    return Center(
      child: Text(title, style: const TextStyle(color: Colors.grey, fontSize: 18)),
    );
  }
}
