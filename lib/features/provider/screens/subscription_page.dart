
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
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
          style: context.txtTheme.labelLarge,
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
                // Subscription Info Banner (if user has active subscription)
                Obx(() {
                  if (controller.currentPackage.value != null &&
                      controller.endDate.value != null) {
                    return _buildSubscriptionInfoBanner();
                  }
                  return const SizedBox.shrink();
                }),

                // "My Package" label
                const Text(
                  'My Package',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Subscription Cards
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

  Widget _buildSubscriptionCard(SubscriptionPlan plan) {
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
          // Top section with icon and current badge
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Crown/Premium icon with colored background
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
                // Current badge (only for current plan)
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

          // Features list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan features
                ...plan.description.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check,
                        size: 18,
                        color: Colors.green[700],
                      ),
                      const SizedBox(width: 8),
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

                // Plan title
                Text(
                  plan.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),

                // Price section
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
                        '/${_getDurationText(plan.duration)}',
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

                // Upgrade button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan
                        ? null
                        : () => controller.onUpgradeNow(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: plan.title.toLowerCase() == 'basic'
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

  String _getDurationText(int duration) {
    if (duration == 1) {
      return 'month';
    } else if (duration < 12) {
      return 'monthly';
    } else if (duration == 12) {
      return 'year';
    } else {
      return 'yearly';
    }
  }

  Widget _buildSubscriptionInfoBanner() {
    final endDate = DateTime.parse(controller.endDate.value!);
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








///
///
///
///
/// todo::: matching design with the UI
///
///
///
///





// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:manx_mate/core/extensions/context_extensions.dart';
// import '../controllers/subscription_controller.dart';
//
// class SubscriptionPage extends GetView<SubscriptionController> {
//   const SubscriptionPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // Ensure controller is registered
//     if (!Get.isRegistered<SubscriptionController>()) {
//       Get.put(SubscriptionController());
//     }
//
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
//           onPressed: () => Get.back(),
//         ),
//         title: Text(
//           'Subscription',
//           style: context.txtTheme.labelLarge,
//         ),
//         centerTitle: false,
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(height: 16),
//                 Text('Loading subscription plans...'),
//               ],
//             ),
//           );
//         }
//
//         if (controller.subscriptionPlans.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.inbox_outlined,
//                   size: 64,
//                   color: Colors.grey[400],
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'No subscription plans available',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 ElevatedButton(
//                   onPressed: () => controller.refreshSubscriptions(),
//                   child: const Text('Retry'),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         // Debug: Print plan count
//         debugPrint('🔍 Number of plans: ${controller.subscriptionPlans.length}');
//         for (var i = 0; i < controller.subscriptionPlans.length; i++) {
//           debugPrint('Plan $i: ${controller.subscriptionPlans[i].title}');
//         }
//
//         return RefreshIndicator(
//           onRefresh: controller.refreshSubscriptions,
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // "My Package" label
//                 const Text(
//                   'My Package',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//
//                 // Build all cards with timeline
//                 _buildSubscriptionTimeline(),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }
//
//   Widget _buildSubscriptionTimeline() {
//     final planCount = controller.subscriptionPlans.length;
//
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Timeline column with dots and lines
//         SizedBox(
//           width: 16,
//           child: Column(
//             children: List.generate(planCount * 2 - 1, (index) {
//               // Even indices are dots, odd indices are lines
//               if (index.isEven) {
//                 // This is a dot
//                 final planIndex = index ~/ 2;
//                 final plan = controller.subscriptionPlans[planIndex];
//                 final Color primaryColor = controller.getPlanColor(plan.title);
//
//                 return Container(
//                   width: 16,
//                   height: 16,
//                   decoration: BoxDecoration(
//                     color: primaryColor,
//                     shape: BoxShape.circle,
//                   ),
//                 );
//               } else {
//                 // This is a line
//                 final planIndex = index ~/ 2;
//                 final plan = controller.subscriptionPlans[planIndex];
//                 final Color primaryColor = controller.getPlanColor(plan.title);
//
//                 return AnimatedLineIndicator(
//                   color: primaryColor,
//                   height: 380,
//                   delay: Duration(milliseconds: planIndex * 1000),
//                 );
//               }
//             }),
//           ),
//         ),
//
//         const SizedBox(width: 12),
//
//         // Cards column
//         Expanded(
//           child: Column(
//             children: List.generate(planCount, (index) {
//               final plan = controller.subscriptionPlans[index];
//               final isLast = index == planCount - 1;
//
//               return Padding(
//                 padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
//                 child: _buildSubscriptionCard(
//                   plan,
//                   controller.isCurrentPlan(plan.title),
//                   controller.getPlanColor(plan.title),
//                 ),
//               );
//             }),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSubscriptionCard(SubscriptionPlan plan, bool isCurrentPlan, Color primaryColor) {
//     final Color backgroundColor = controller.getPlanBackgroundColor(plan.title);
//     final Color borderColor = primaryColor.withOpacity(0.5);
//
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: borderColor,
//           width: 1.5,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Crown icon with badge at top
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Crown icon
//                 Container(
//                   width: 56,
//                   height: 56,
//                   decoration: BoxDecoration(
//                     color: primaryColor,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Icon(
//                     Icons.workspace_premium,
//                     color: Colors.white,
//                     size: 32,
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 // Plan badge (Current Plan or plan name)
//                 _buildPlanBadge(plan.title, isCurrentPlan, primaryColor),
//               ],
//             ),
//           ),
//
//           // Features list with checkmarks
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ...plan.description.map((feature) => Padding(
//                   padding: const EdgeInsets.only(bottom: 8),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Icon(
//                         Icons.check,
//                         size: 18,
//                         color: Colors.black87,
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           feature,
//                           style: const TextStyle(
//                             fontSize: 13,
//                             color: Colors.black87,
//                             height: 1.4,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 16),
//
//           // Plan title in bold
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Text(
//               plan.title,
//               style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 20),
//
//           // Price with duration
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   '€ ${plan.price.toStringAsFixed(0)}',
//                   style: const TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(width: 4),
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 3),
//                   child: Text(
//                     '/${_getDurationText(plan.duration)}',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 20),
//
//           // Upgrade Now button
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: SizedBox(
//               width: double.infinity,
//               height: 52,
//               child: ElevatedButton(
//                 onPressed: isCurrentPlan
//                     ? null
//                     : () => controller.onUpgradeNow(plan),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: isCurrentPlan
//                       ? Colors.grey[400]
//                       : const Color(0xFFFDD835), // Yellow
//                   foregroundColor: Colors.black,
//                   disabledBackgroundColor: Colors.grey[400],
//                   disabledForegroundColor: Colors.black87,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: Text(
//                   isCurrentPlan ? 'Current Plan' : 'Upgrade Now',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Build the badge (Current Plan or plan name)
//   Widget _buildPlanBadge(String title, bool isCurrentPlan, Color primaryColor) {
//     String badgeText;
//     Color badgeColor;
//
//     if (isCurrentPlan) {
//       badgeText = 'Current Plan';
//       badgeColor = primaryColor;
//     } else {
//       badgeText = title;
//       badgeColor = const Color(0xFFFDD835); // Yellow
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 16,
//         vertical: 8,
//       ),
//       decoration: BoxDecoration(
//         color: badgeColor,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         badgeText,
//         style: TextStyle(
//           color: isCurrentPlan && title.toLowerCase() == 'basic'
//               ? Colors.white
//               : Colors.black,
//           fontSize: 13,
//           fontWeight: FontWeight.w700,
//         ),
//       ),
//     );
//   }
//
//   String _getDurationText(int duration) {
//     if (duration == 1) {
//       return 'month';
//     } else if (duration < 12) {
//       return 'monthly';
//     } else if (duration == 12) {
//       return 'year';
//     } else {
//       return 'yearly';
//     }
//   }
// }
//
// // Animated line widget that grows from top to bottom
// class AnimatedLineIndicator extends StatefulWidget {
//   final Color color;
//   final double height;
//   final Duration delay;
//
//   const AnimatedLineIndicator({
//     super.key,
//     required this.color,
//     required this.height,
//     this.delay = Duration.zero,
//   });
//
//   @override
//   State<AnimatedLineIndicator> createState() => _AnimatedLineIndicatorState();
// }
//
// class _AnimatedLineIndicatorState extends State<AnimatedLineIndicator>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//
//     _animation = Tween<double>(
//       begin: 0.0,
//       end: widget.height,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     ));
//
//     // Start animation after delay
//     Future.delayed(widget.delay, () {
//       if (mounted) {
//         _controller.forward();
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _animation,
//       builder: (context, child) {
//         return Container(
//           width: 4,
//           height: _animation.value,
//           decoration: BoxDecoration(
//             color: widget.color,
//             borderRadius: BorderRadius.circular(2),
//           ),
//         );
//       },
//     );
//   }
// }

