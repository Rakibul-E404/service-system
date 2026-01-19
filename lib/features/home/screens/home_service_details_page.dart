/**
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:manx_mate/core/common/components/custom_network_image.dart';
import 'package:manx_mate/core/common/widgets/reusable_button.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import '../../../core/common/widgets/time_picker_widget.dart';
import '../../../core/utils/api/app_url.dart';
import '../../favorite/controllers/favorite_controller.dart';
import '../../profile/controllers/review_controller.dart';
import '../controllers/service_controller.dart';
import '../model/single_service_model.dart';
import '../widget/booking_bottom_sheet.dart';

class HomeServiceDetailsPage extends StatefulWidget {
  const HomeServiceDetailsPage({super.key});

  @override
  State<HomeServiceDetailsPage> createState() => _HomeServiceDetailsPageState();
}

class _HomeServiceDetailsPageState extends State<HomeServiceDetailsPage>
    with SingleTickerProviderStateMixin {
   final FavoriteController favoriteController = Get.find<FavoriteController>();
  final TimeController timeController = Get.put(TimeController());
  final ServicesController servicesController = Get.put(ServicesController());

  // Register or Find Review Controller
  final MyReviewController reviewController = Get.isRegistered<MyReviewController>()
      ? Get.find<MyReviewController>()
      : Get.put(MyReviewController());

  late TabController _tabController;
  final TextEditingController _additionalNoteTEController = TextEditingController();
  final TextEditingController _dateTEController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final String serviceId = Get.arguments['serviceId'] ?? '';

    // Initial fetch for service details
    if (serviceId.isNotEmpty) {
      servicesController.fetchSingleService(serviceId);
    }

    // 🔹 Trigger review fetch ONLY when switching to the Review Tab
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_tabController.indexIsChanging) {
        if (serviceId.isNotEmpty) {
          reviewController.fetchReviewsForService(serviceId, null);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _additionalNoteTEController.dispose();
    _dateTEController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Obx(() {
        final service = servicesController.singleServiceDetails.value;
        return _buildBookingButton(context, service);
      }),
      body: SafeArea(
        child: Obx(() {
          if (servicesController.isLoadingSingleService.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final service = servicesController.singleServiceDetails.value;
          if (service == null) {
            return const Center(child: Text("Service details not found."));
          }

          final profile = service.profileDetails;
          final isFav = servicesController.isServiceFavorited(service.id);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderActions(isFav, service.id),
                      _buildServiceImage(profile.image),
                      const SizedBox(height: AppSizes.md),
                      _buildTitleAndContacts(profile.name, service.accessibleBySubscription),
                      const SizedBox(height: AppSizes.sm),
                      Text(service.subCategory.name),
                      _buildDetailRow(Icons.location_on_outlined, profile.location),
                      _buildDetailRow(Icons.phone_outlined, profile.phone),
                      _buildDetailRow(Icons.star_outline,
                          "${profile.averageRating} (${profile.totalReviews} Ratings)"),
                      const SizedBox(height: AppSizes.md),
                      _buildStaticServiceDropdown(service.subCategory.name),
                      const SizedBox(height: AppSizes.md),
                      Text('Service Provider', style: context.txtTheme.titleLarge),
                      const SizedBox(height: AppSizes.sm),
                      _buildProviderCard(context, service),
                      const SizedBox(height: AppSizes.md),

                      // --- Tab Bar ---
                      TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primaryColor,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: AppColors.primaryColor,
                        indicatorWeight: 3,
                        tabs: const [
                          Tab(text: "Description"),
                          Tab(text: "Reviews"),
                        ],
                      ),

                      // --- Tab View Content ---
                      // We use Obx here so the Review List reacts to the fetch state
                      Obx(() => SizedBox(
                        height: _calculateTabHeight(),
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Tab 1: Description
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(profile.description,
                                  style: const TextStyle(height: 1.5)),
                            ),
                            // Tab 2: Reviews
                            _buildReviewList(service.id),
                          ],
                        ),
                      )),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // Dynamic height calculation for the TabBarView area
  double _calculateTabHeight() {
    // If reviews are loading or present, give it more space
    if (reviewController.isLoading.value) return 200.0;
    if (reviewController.reviews.isNotEmpty && _tabController.index == 1) {
      return (reviewController.reviews.length * 120.0).clamp(300.0, 800.0);
    }
    return 400.0;
  }

  Widget _buildReviewList(String serviceId) {
    if (reviewController.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    // Note: Adjusting filter logic to check if current list matches this service
    if (reviewController.reviews.isEmpty) {
      return const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text("No reviews for this service yet."),
          ));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviewController.reviews.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final review = reviewController.reviews[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(review.author.image.startsWith('http')
                      ? review.author.image
                      : "${AppUrl.imageBaseUrl}/${review.author.image}"),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.author.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(review.formattedDate,
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(
                      5,
                          (i) => Icon(
                        Icons.star,
                        size: 16,
                        color: i < review.rating ? Colors.amber : Colors.grey[300],
                      )),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.description),
          ],
        );
      },
    );
  }

  // --- Utility Component Builders ---

  Widget _buildHeaderActions(bool isFav, String serviceId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(onPressed: () => Get.back(), icon: const Icon(CupertinoIcons.back)),
        // IconButton(
        //   onPressed: () => favoriteController.toggleFavorite(serviceId),
        //   icon: Icon(isFav ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
        //       color: isFav ? Colors.red : null),
        // ),
      ],
    );
  }

  Widget _buildServiceImage(String imageUrl) {
    return CustomCachedImage(
      imageUrl: imageUrl.startsWith('http') ? imageUrl : "${AppUrl.imageBaseUrl}/$imageUrl",
      width: double.infinity,
      height: 250,
    );
  }

  Widget _buildTitleAndContacts(String name, List<String> access) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(name, style: context.txtTheme.titleLarge)),
        if (access.contains('Call')) const Icon(Icons.call, size: 22),
        const SizedBox(width: 8),
        if (access.contains('Email')) const Icon(Icons.email, size: 22),
        const SizedBox(width: 8),
        if (access.contains('Massaging'))
          const Icon(CupertinoIcons.chat_bubble_fill, size: 22),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildStaticServiceDropdown(String serviceName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: AppColors.primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(
            serviceName,
            style:
            const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textBlackColor),
          ),
          // const Spacer(),
          // const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryColor),
        ],
      ),
    );
  }

  Widget _buildProviderCard(BuildContext context, SingleServiceModel service) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.providerDetailsPage),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.md),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryColor),
          color: AppColors.primaryColor.withOpacity(0.1),
        ),
        child: Row(
          children: <Widget>[
            CustomCachedImage(
              imageUrl: service.profileDetails.image.startsWith('http')
                  ? service.profileDetails.image
                  : "${AppUrl.imageBaseUrl}/${service.profileDetails.image}",
              height: 70,
              width: 70,
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(service.author.name, style: context.txtTheme.labelLarge),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(service.profileDetails.region),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.primaryColor, size: 16),
                      const SizedBox(width: 4),
                      Text("${service.profileDetails.averageRating} Ratings"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingButton(BuildContext context, SingleServiceModel? service) {
    return SizedBox(
      width: context.screenWidth * 0.9,
      height: 50,
      child: ReusableButton(
        onTap: () {
          if (service == null) return;
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => FractionallySizedBox(
              heightFactor: 0.9,
              child: BookingBottomSheet(
                service: service,
                dateTEController: _dateTEController,
                timeController: timeController,
                additionalNoteTEController: _additionalNoteTEController,
                preSelectedServiceId: service.id,
                preSelectedDate: DateTime.now(),
                onSubmitSuccess: () {
                  Get.back();
                  Get.snackbar('Success', 'Booking submitted successfully!',
                      backgroundColor: Colors.green, colorText: Colors.white);
                  GetStorage storage = GetStorage();
                  storage.write('should_navigate_to_booking_after_home', true);
                  storage.write('should_navigate_to_active_jobs', true);
                  Get.toNamed(AppRoutes.mainBottomNavPage);
                },
              ),
            ),
          );
        },
        label: "Book A Slot",
      ),
    );
  }
}*/







///
///
///
///
/// todo:: settign the funcitonality to go dialpad - email - mesage[pending...]
///
///
///
///








import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:manx_mate/core/common/components/custom_network_image.dart';
import 'package:manx_mate/core/common/widgets/reusable_button.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/routes/app_routes.dart';
import '../../../core/common/widgets/time_picker_widget.dart';
import '../../../core/utils/api/app_url.dart';
import '../../favorite/controllers/favorite_controller.dart';
import '../../profile/controllers/review_controller.dart';
import '../controllers/service_controller.dart';
import '../model/single_service_model.dart';
import '../widget/booking_bottom_sheet.dart';

class HomeServiceDetailsPage extends StatefulWidget {
  const HomeServiceDetailsPage({super.key});

  @override
  State<HomeServiceDetailsPage> createState() => _HomeServiceDetailsPageState();
}

class _HomeServiceDetailsPageState extends State<HomeServiceDetailsPage>
    with SingleTickerProviderStateMixin {
  final FavoriteController favoriteController = Get.find<FavoriteController>();
  final TimeController timeController = Get.put(TimeController());
  final ServicesController servicesController = Get.put(ServicesController());

  // Register or Find Review Controller
  final MyReviewController reviewController = Get.isRegistered<MyReviewController>()
      ? Get.find<MyReviewController>()
      : Get.put(MyReviewController());

  late TabController _tabController;
  final TextEditingController _additionalNoteTEController = TextEditingController();
  final TextEditingController _dateTEController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final String serviceId = Get.arguments['serviceId'] ?? '';

    // Initial fetch for service details
    if (serviceId.isNotEmpty) {
      servicesController.fetchSingleService(serviceId);
    }

    // 🔹 Trigger review fetch ONLY when switching to the Review Tab
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_tabController.indexIsChanging) {
        if (serviceId.isNotEmpty) {
          reviewController.fetchReviewsForService(serviceId, null);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _additionalNoteTEController.dispose();
    _dateTEController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Obx(() {
        final service = servicesController.singleServiceDetails.value;
        return _buildBookingButton(context, service);
      }),
      body: SafeArea(
        child: Obx(() {
          if (servicesController.isLoadingSingleService.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final service = servicesController.singleServiceDetails.value;
          if (service == null) {
            return const Center(child: Text("Service details not found."));
          }

          final profile = service.profileDetails;
          final isFav = servicesController.isServiceFavorited(service.id);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderActions(isFav, service.id),
                      _buildServiceImage(profile.image),
                      const SizedBox(height: AppSizes.md),
                      // Updated TitleAndContacts with full functionality
                      _buildTitleAndContacts(profile.name, service.accessibleBySubscription, profile.phone, profile.email),
                      const SizedBox(height: AppSizes.sm),
                      Text(service.subCategory.name),
                      _buildDetailRow(Icons.location_on_outlined, profile.location),
                      _buildDetailRow(Icons.phone_outlined, profile.phone),
                      _buildDetailRow(Icons.star_outline,
                          "${profile.averageRating} (${profile.totalReviews} Ratings)"),
                      const SizedBox(height: AppSizes.md),
                      _buildStaticServiceDropdown(service.subCategory.name),
                      const SizedBox(height: AppSizes.md),
                      Text('Service Provider', style: context.txtTheme.titleLarge),
                      const SizedBox(height: AppSizes.sm),
                      _buildProviderCard(context, service),
                      const SizedBox(height: AppSizes.md),

                      // --- Tab Bar ---
                      TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primaryColor,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: AppColors.primaryColor,
                        indicatorWeight: 3,
                        tabs: const [
                          Tab(text: "Description"),
                          Tab(text: "Reviews"),
                        ],
                      ),

                      // --- Tab View Content ---
                      Obx(() => SizedBox(
                        height: _calculateTabHeight(),
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Tab 1: Description
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(profile.description,
                                  style: const TextStyle(height: 1.5)),
                            ),
                            // Tab 2: Reviews
                            _buildReviewList(service.id),
                          ],
                        ),
                      )),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ========== UPDATED: TitleAndContacts with FULL FUNCTIONALITY ==========
  Widget _buildTitleAndContacts(
      String name,
      List<String> access,
      String? providerPhone,
      String? providerEmail
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row with icons
        Row(
          children: <Widget>[
            Expanded(child: Text(name, style: context.txtTheme.titleLarge)),
            if (access.contains('Call') && providerPhone != null)
              GestureDetector(
                onTap: () => _launchPhoneNumber(providerPhone),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.call, size: 22, color: Colors.green),
                ),
              ),
            if (access.contains('Call') && providerPhone != null) const SizedBox(width: 8),
            if (access.contains('Email') && providerEmail != null)
              GestureDetector(
                onTap: () => _launchEmail(providerEmail),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.email, size: 22, color: Colors.blue),
                ),
              ),
            if (access.contains('Email') && providerEmail != null) const SizedBox(width: 8),
            if (access.contains('Massaging'))
              GestureDetector(
                onTap: () {
                  Get.snackbar(
                    'Coming Soon',
                    'In-app messaging will be available soon.',
                    backgroundColor: Colors.purple,
                    colorText: Colors.white,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(CupertinoIcons.chat_bubble_fill, size: 22, color: Colors.purple),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ========== COPIED METHODS FROM JobDetailsModal ==========
  /// Launch phone dialer
  Future<void> _launchPhoneNumber(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch dialer',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Launch email app
  Future<void> _launchEmail(String email) async {
    // Ensure the email is not empty
    if (email.isEmpty) return;

    // Get the service name for subject
    final String serviceName = servicesController.singleServiceDetails.value?.subCategory.name ?? 'Service';

    // Construct the mailto URI
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email, // <-- This will be the "To" field
    );

    try {
      // Launch external email app
      final bool launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        Get.snackbar(
          'No Email App',
          'No email app found. Please install Gmail, Outlook, or another email app.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Email Error',
        'Unable to open email app. Try installing Gmail or another email client.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }





  // ========== REMAINING ORIGINAL METHODS (unchanged) ==========
  double _calculateTabHeight() {
    if (reviewController.isLoading.value) return 200.0;
    if (reviewController.reviews.isNotEmpty && _tabController.index == 1) {
      return (reviewController.reviews.length * 120.0).clamp(300.0, 800.0);
    }
    return 400.0;
  }

  Widget _buildReviewList(String serviceId) {
    if (reviewController.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reviewController.reviews.isEmpty) {
      return const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text("No reviews for this service yet."),
          ));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviewController.reviews.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final review = reviewController.reviews[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(review.author.image.startsWith('http')
                      ? review.author.image
                      : "${AppUrl.imageBaseUrl}/${review.author.image}"),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.author.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(review.formattedDate,
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(
                      5,
                          (i) => Icon(
                        Icons.star,
                        size: 16,
                        color: i < review.rating ? Colors.amber : Colors.grey[300],
                      )),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.description),
          ],
        );
      },
    );
  }

  Widget _buildHeaderActions(bool isFav, String serviceId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(onPressed: () => Get.back(), icon: const Icon(CupertinoIcons.back)),
      ],
    );
  }

  Widget _buildServiceImage(String imageUrl) {
    return CustomCachedImage(
      imageUrl: imageUrl.startsWith('http') ? imageUrl : "${AppUrl.imageBaseUrl}/$imageUrl",
      width: double.infinity,
      height: 250,
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildStaticServiceDropdown(String serviceName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: AppColors.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              serviceName,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textBlackColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(BuildContext context, SingleServiceModel service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryColor),
        color: AppColors.primaryColor.withOpacity(0.1),
      ),
      child: Row(
        children: <Widget>[
          CustomCachedImage(
            imageUrl: service.profileDetails.image.startsWith('http')
                ? service.profileDetails.image
                : "${AppUrl.imageBaseUrl}/${service.profileDetails.image}",
            height: 70,
            width: 70,
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(service.author.name, style: context.txtTheme.labelLarge),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16),
                    const SizedBox(width: 4),
                    Expanded(child: Text(service.profileDetails.region)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.primaryColor, size: 16),
                    const SizedBox(width: 4),
                    Text("${service.profileDetails.averageRating} Ratings"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingButton(BuildContext context, SingleServiceModel? service) {
    return SizedBox(
      width: context.screenWidth * 0.9,
      height: 50,
      child: ReusableButton(
        onTap: () {
          if (service == null) return;
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => FractionallySizedBox(
              heightFactor: 0.9,
              child: BookingBottomSheet(
                service: service,
                dateTEController: _dateTEController,
                timeController: timeController,
                additionalNoteTEController: _additionalNoteTEController,
                preSelectedServiceId: service.id,
                preSelectedDate: DateTime.now(),
                onSubmitSuccess: () {
                  Get.back();
                  Get.snackbar('Success', 'Booking submitted successfully!',
                      backgroundColor: Colors.green, colorText: Colors.white);
                  GetStorage storage = GetStorage();
                  storage.write('should_navigate_to_booking_after_home', true);
                  storage.write('should_navigate_to_active_jobs', true);
                  Get.toNamed(AppRoutes.mainBottomNavPage);
                },
              ),
            ),
          );
        },
        label: "Book A Slot",
      ),
    );
  }
}
