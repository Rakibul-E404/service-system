/**

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/subscription_controller.dart';

class SubscriptionPage extends GetView<SubscriptionController> {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered
    if (!Get.isRegistered<SubscriptionController>()) {
      Get.put(SubscriptionController());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Subscription',
          style: context.textTheme.labelLarge,
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading subscription plans...'),
              ],
            ),
          );
        }

        if (controller.subscriptionPlans.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No subscription plans available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => controller.refreshSubscriptions(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshSubscriptions,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subscription Info Banner
                Obx(() {
                  if (controller.currentPackage.value != null &&
                      controller.endDate.value != null) {
                    return _buildSubscriptionInfoBanner();
                  }
                  return const SizedBox.shrink();
                }),

                const Text(
                  'My Package',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Subscription Cards using SubscriptionModel
                ...controller.subscriptionPlans.asMap().entries.map((entry) {
                  final index = entry.key;
                  final plan = entry.value;
                  final isLast = index == controller.subscriptionPlans.length - 1;

                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                    child: _buildSubscriptionCard(plan),
                  );
                }),
              ],
            ),
          ),
        );
      }),
    );
  }

  String? get activeSubscription => controller.currentPackage.value;

  Widget _buildSubscriptionCard(SubscriptionModel plan) {
    final bool isCurrentPlan = controller.isCurrentPlan(plan.title);
    final Color backgroundColor = controller.getPlanBackgroundColor(plan.title);
    final Color primaryColor = controller.getPlanColor(plan.title);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    controller.getPlanIcon(plan.title),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const Spacer(),
                if (isCurrentPlan)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Current Plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...plan.description.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 12),
                Text(
                  plan.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '€ ${plan.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '/${_getDurationText(plan.duration, plan.durationType)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan
                        ? null
                        : () => controller.onUpgradeNow(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: (plan.title.toLowerCase() == 'basic' || plan.title.toLowerCase() == 'standard')
                          ? Colors.white
                          : Colors.black,
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[600],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isCurrentPlan ? 'Current Plan' : 'Upgrade Now',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDurationText(int duration, String type) {
    if (type.isNotEmpty) return type.toLowerCase();
    if (duration == 1) return 'month';
    if (duration == 12) return 'year';
    return '$duration months';
  }

  Widget _buildSubscriptionInfoBanner() {
    final endDateStr = controller.endDate.value!;
    final endDate = DateTime.parse(endDateStr);
    final daysLeft = endDate.difference(DateTime.now()).inDays;
    final formattedEndDate = '${endDate.day}/${endDate.month}/${endDate.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active: ${controller.currentPackage.value}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Expires on $formattedEndDate',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
                if (daysLeft <= 7 && daysLeft > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '⚠️ $daysLeft days left',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

*/






///
///
///
/// todO:: matching with subscription id
///
///
///





import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/subscription_controller.dart';

class SubscriptionPage extends GetView<SubscriptionController> {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SubscriptionController>()) {
      Get.put(SubscriptionController());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Subscription',
          style: context.textTheme.labelLarge,
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading subscription plans...'),
              ],
            ),
          );
        }

        if (controller.subscriptionPlans.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No subscription plans available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => controller.refreshSubscriptions(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshSubscriptions,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subscription Info Banner
                Obx(() {
                  if (controller.currentPackageTitle.value != null &&
                      controller.endDate.value != null) {
                    return _buildSubscriptionInfoBanner();
                  }
                  return const SizedBox.shrink();
                }),
                const SizedBox(height: 16),

                ...controller.subscriptionPlans.map((plan) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _buildSubscriptionCard(plan),
                  );
                }),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSubscriptionCard(SubscriptionModel plan) {
    final bool isCurrentPlan = controller.isCurrentPlan(plan);
    final Color primaryColor = controller.getPlanColor(plan.title);
    final Color backgroundColor = controller.getPlanBackgroundColor(plan.title);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(controller.getPlanIcon(plan.title), color: Colors.white, size: 28),
                ),
                const Spacer(),
                if (isCurrentPlan)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(20)),
                    child: const Text(
                      'Current Plan',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...plan.description.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(feature, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4)),
                )),
                const SizedBox(height: 12),
                Text(plan.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('€ ${plan.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '/${plan.durationType.toLowerCase()}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan ? null : () => controller.onUpgradeNow(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: (plan.title.toLowerCase() == 'basic' || plan.title.toLowerCase() == 'standard')
                          ? Colors.white
                          : Colors.black,
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[600],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: Text(isCurrentPlan ? 'Current Plan' : 'Upgrade Now', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionInfoBanner() {
    final endDateStr = controller.endDate.value!;
    final endDate = DateTime.parse(endDateStr);
    final daysLeft = endDate.difference(DateTime.now()).inDays;
    final formattedEndDate = '${endDate.day}/${endDate.month}/${endDate.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.blue.shade100]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.info_outline, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Active: ${controller.currentPackageTitle.value}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Expires on $formattedEndDate', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                if (daysLeft <= 7 && daysLeft > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('⚠️ $daysLeft days left', style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
