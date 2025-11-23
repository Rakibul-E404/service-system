
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
import 'package:manx_mate/core/utils/api/app_url.dart';

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
  var processingIds = <String>[].obs;

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

  Future<void> respondToBooking(String bookingId, String status) async {
    try {
      processingIds.add(bookingId);

      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'Please login again.';
        processingIds.remove(bookingId);
        return;
      }

      final url = Uri.parse('$baseUrl/booking/respond/$bookingId');
      print('🌐 Updating booking status: $url');
      print('📦 Request data: {"status": "$status"}');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ Booking $bookingId $status successfully');
          bookings.removeWhere((booking) => booking['_id'] == bookingId);
          Get.snackbar(
            'Success',
            'Booking ${status == 'completed' ? 'completed' : 'cancelled'} successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          errorMessage.value = data['message'] ?? 'Failed to update booking';
          Get.snackbar(
            'Error',
            data['message'] ?? 'Failed to update booking',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        errorMessage.value = 'Server Error: ${response.statusCode}';
        Get.snackbar(
          'Error',
          'Server Error: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      Get.snackbar(
        'Error',
        'Error: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      processingIds.remove(bookingId);
    }
  }

  bool isProcessing(String bookingId) {
    return processingIds.contains(bookingId);
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
  var processingIds = <String>[].obs;

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

  Future<void> respondToBooking(String bookingId, String status) async {
    try {
      processingIds.add(bookingId);

      final token = await _getAuthToken();
      if (token == null) {
        errorMessage.value = 'Please login again.';
        processingIds.remove(bookingId);
        return;
      }

      final url = Uri.parse('$baseUrl/booking/respond/$bookingId');
      print('🌐 Updating booking status: $url');
      print('📦 Request data: {"status": "$status"}');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ Booking $bookingId $status successfully');
          bookings.removeWhere((booking) => booking['_id'] == bookingId);
          Get.snackbar(
            'Success',
            'Booking ${status == 'accepted' ? 'approved' : 'cancelled'} successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          errorMessage.value = data['message'] ?? 'Failed to update booking';
          Get.snackbar(
            'Error',
            data['message'] ?? 'Failed to update booking',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        errorMessage.value = 'Server Error: ${response.statusCode}';
        Get.snackbar(
          'Error',
          'Server Error: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      Get.snackbar(
        'Error',
        'Error: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      processingIds.remove(bookingId);
    }
  }

  bool isProcessing(String bookingId) {
    return processingIds.contains(bookingId);
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

  final timeController = Get.put(TimeController());
  final serviceNameTEController = TextEditingController();
  final locationTEController = TextEditingController();
  final additionalNoteTEController = TextEditingController();
  final dateTEController = TextEditingController();
  final typeTEController = TextEditingController();
  final addServiceFormKey = GlobalKey<FormState>();

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

  /// Show Booking Details Modal
  void _showBookingDetails(Map<String, dynamic> booking) {
    final author = booking['author'] ?? {};
    final category = booking['category'] ?? {};
    final location = booking['location'] ?? 'Unknown';
    final description = booking['description'] ?? 'No description';
    final bookingDate = booking['bookingDate'] ?? '';
    final status = booking['status'] ?? 'N/A';

    String formattedDate = '';
    String formattedTime = '';
    try {
      final date = DateTime.parse(bookingDate);
      formattedDate = '${date.day}/${date.month}/${date.year}';
      formattedTime = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      formattedDate = 'Invalid date';
      formattedTime = 'N/A';
    }

    final authorImagePath = author['image'];
    final authorImageUrl = (authorImagePath != null && authorImagePath.toString().isNotEmpty)
        ? '${AppUrl.imageBaseUrl}/$authorImagePath'
        : 'https://via.placeholder.com/150';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
                    'Booking Details',
                    style: TextStyle(
                      fontSize: 20,
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
            const Divider(height: 1),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author Information
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey[300]!, width: 2),
                            image: DecorationImage(
                              image: NetworkImage(authorImageUrl),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {
                                print('❌ Failed to load author image: $authorImageUrl');
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                author['name'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Category
                    _buildDetailRow(
                      icon: Icons.category,
                      label: 'Category',
                      value: category['name'] ?? 'N/A',
                    ),

                    const SizedBox(height: 16),

                    // Description
                    _buildDetailRow(
                      icon: Icons.description,
                      label: 'Description',
                      value: description,
                    ),

                    const SizedBox(height: 16),

                    // Location
                    _buildDetailRow(
                      icon: Icons.location_on,
                      label: 'Location',
                      value: location,
                    ),

                    const SizedBox(height: 16),

                    // Date
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      label: 'Date',
                      value: formattedDate,
                    ),

                    const SizedBox(height: 16),

                    // Time
                    _buildDetailRow(
                      icon: Icons.access_time,
                      label: 'Time',
                      value: formattedTime,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: AppColors.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
        ? '${AppUrl.imageBaseUrl}/$imagePath'
        : 'https://via.placeholder.com/150';

    return GestureDetector(
      onTap: () => _showBookingDetails(booking),
      child: ProviderServiceMainCard(
        serviceImageUrl: imageUrl,
        serviceStatus: status,
        serviceTitle: category['name'] ?? 'No Category',
        serviceDetails: description,
        serviceLocation: location,
        providerImageUrl: imageUrl,
        providerName: author['name'] ?? 'Unknown',
        showBottomPart: true,
      ),
    );
  }

  Widget _buildOngoingCard(Map<String, dynamic> booking) {
    final author = booking['author'] ?? {};
    final category = booking['category'] ?? {};
    final location = booking['location'] ?? 'Unknown';
    final description = booking['description'] ?? 'No description';
    final bookingDate = booking['bookingDate'] ?? '';
    final status = booking['status'] ?? 'N/A';
    final bookingId = booking['_id'] ?? '';

    String formattedDate = '';
    try {
      final date = DateTime.parse(bookingDate);
      formattedDate = '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      formattedDate = 'Invalid date';
    }

    final authorImagePath = author['image'];
    final serviceImagePath = booking['image'] ?? authorImagePath;

    final serviceImageUrl = (serviceImagePath != null && serviceImagePath.toString().isNotEmpty)
        ? '${AppUrl.imageBaseUrl}/$serviceImagePath'
        : 'https://via.placeholder.com/150';

    final providerImageUrl = (authorImagePath != null && authorImagePath.toString().isNotEmpty)
        ? '${AppUrl.imageBaseUrl}/$authorImagePath'
        : 'https://via.placeholder.com/150';

    final isProcessing = pendingController.isProcessing(bookingId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
      elevation: 2,
      child: InkWell(
        onTap: () => _showBookingDetails(booking),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(serviceImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category['name'] ?? 'No Category',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              const Divider(height: 1),
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(providerImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      author['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (!isProcessing) ...[
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {
                          _showConfirmationDialog(
                            'Complete Booking',
                            'Are you sure you want to mark this booking as completed?',
                                () => pendingController.respondToBooking(bookingId, 'completed'),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text('Complete'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {
                          _showConfirmationDialog(
                            'Cancel Booking',
                            'Are you sure you want to cancel this ongoing booking?',
                                () => pendingController.respondToBooking(bookingId, 'cancelled'),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ] else
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteCard(Map<String, dynamic> booking) {
    final author = booking['author'] ?? {};
    final category = booking['category'] ?? {};
    final location = booking['location'] ?? 'Unknown';
    final description = booking['description'] ?? 'No description';
    final bookingDate = booking['bookingDate'] ?? '';
    final status = booking['status'] ?? 'N/A';
    final bookingId = booking['_id'] ?? '';

    String formattedDate = '';
    try {
      final date = DateTime.parse(bookingDate);
      formattedDate = '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      formattedDate = 'Invalid date';
    }

    final authorImagePath = author['image'];
    final serviceImagePath = booking['image'] ?? authorImagePath;

    final serviceImageUrl = (serviceImagePath != null && serviceImagePath.toString().isNotEmpty)
        ? '${AppUrl.imageBaseUrl}/$serviceImagePath'
        : 'https://via.placeholder.com/150';

    final providerImageUrl = (authorImagePath != null && authorImagePath.toString().isNotEmpty)
        ? '${AppUrl.imageBaseUrl}/$authorImagePath'
        : 'https://via.placeholder.com/150';

    final isProcessing = quoteController.isProcessing(bookingId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
      elevation: 2,
      child: InkWell(
        onTap: () => _showBookingDetails(booking),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(serviceImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category['name'] ?? 'No Category',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              const Divider(height: 1),
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(providerImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      author['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (!isProcessing) ...[
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {
                          _showConfirmationDialog(
                            'Approve Booking',
                            'Are you sure you want to approve this booking?',
                                () => quoteController.respondToBooking(bookingId, 'accepted'),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text('Approve'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {
                          _showConfirmationDialog(
                            'Cancel Booking',
                            'Are you sure you want to cancel this booking?',
                                () => quoteController.respondToBooking(bookingId, 'cancelled'),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ] else
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showConfirmationDialog(String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
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

  Widget _buildQuoteListView() {
    if (quoteController.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    if (quoteController.errorMessage.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: () async => quoteController.fetchBookings(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: _buildErrorState(
              quoteController.errorMessage.value,
              quoteController.fetchBookings,
            ),
          ),
        ),
      );
    }

    if (quoteController.bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => quoteController.fetchBookings(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: _buildEmptyState(
              'No pending quotes',
              quoteController.fetchBookings,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => quoteController.fetchBookings(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.md),
        itemCount: quoteController.bookings.length,
        itemBuilder: (context, i) => _buildQuoteCard(quoteController.bookings[i]),
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.md),
      ),
    );
  }

  Widget _buildOngoingListView() {
    if (pendingController.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    if (pendingController.errorMessage.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: () async => pendingController.fetchBookings(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: _buildErrorState(
              pendingController.errorMessage.value,
              pendingController.fetchBookings,
            ),
          ),
        ),
      );
    }

    if (pendingController.bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => pendingController.fetchBookings(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: _buildEmptyState(
              'No ongoing bookings',
              pendingController.fetchBookings,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => pendingController.fetchBookings(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.md),
        itemCount: pendingController.bookings.length,
        itemBuilder: (context, i) => _buildOngoingCard(pendingController.bookings[i]),
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
    _clearFormFields();
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
                            print('🔥 Add Service Button Clicked!');
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
                  Obx(() => _buildServicesListView()),
                  Obx(() => _buildQuoteListView()),
                  Obx(() => _buildBookingsListView(
                    cancelledController.bookings,
                    cancelledController.isLoading,
                    cancelledController.errorMessage,
                    'No cancelled bookings',
                    cancelledController.fetchBookings,
                  )),
                  Obx(() => _buildOngoingListView()),
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