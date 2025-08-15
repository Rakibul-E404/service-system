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
          ],
        ),
      ),
    );
  }
}
