

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/extensions/widget_extensions.dart';
import '../../../core/config/app_colors.dart';
import '../controllers/notification_controller.dart';

class NotificationPage extends GetView<NotificationController> {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(CupertinoIcons.back),
                  ),
                  Expanded(
                    child: Text("Notifications", style: context.txtTheme.headlineMedium).centered,
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.isNotEmpty) {
                  return Center(
                    child: Text(
                      controller.errorMessage.value,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (controller.notifications.isEmpty) {
                  return const Center(
                    child: Text('No notifications available'),
                  );
                }

                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: controller.notifications.length,
                  itemBuilder: (BuildContext context, int index) {
                    final notification = controller.notifications[index];
                    final senderName = notification['sender']?['name'] ?? 'Unknown';
                    final title = notification['title'] ?? '';
                    final description = notification['description'] ?? '';
                    final createdAt = notification['createdAt'] ?? '';

                    final notificationTime = DateTime.tryParse(createdAt);
                    String timeText = '';
                    if (notificationTime != null) {
                      final difference = DateTime.now().difference(notificationTime);
                      if (difference.inMinutes < 60) {
                        timeText = '${difference.inMinutes} minutes ago';
                      } else if (difference.inHours < 24) {
                        timeText = '${difference.inHours} hours ago';
                      } else {
                        timeText = '${difference.inDays} days ago';
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: Container(
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            border: Border.all(color: AppColors.primaryColor),
                            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                          ),
                          child: const Icon(
                            CupertinoIcons.bell,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('$senderName: $title'),
                            Text(
                              description,
                              style: context.txtTheme.bodySmall?.copyWith(color: AppColors.greyColor),
                            ),
                            Text(
                              timeText,
                              style: context.txtTheme.bodySmall?.copyWith(color: AppColors.greyColor),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
                      child: Divider(color: AppColors.primaryColor),
                    );
                  },
                );
              }),

            ],
          ),
        ),
      ),
    );
  }
}





///
///
///
///
///
///
///
/// todo::::: showing the notificaiton dot
///
///
///
///
///
///








//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:manx_mate/core/config/app_sizes.dart';
// import 'package:manx_mate/core/extensions/context_extensions.dart';
// import 'package:manx_mate/core/extensions/widget_extensions.dart';
// import '../../../core/config/app_colors.dart';
// import '../controllers/notification_controller.dart';
//
// class NotificationPage extends GetView<NotificationController> {
//   const NotificationPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Get.back();
//           },
//           icon: const Icon(CupertinoIcons.back),
//         ),
//         title: Text("Notifications", style: context.txtTheme.headlineMedium),
//         actions: [
//           // Clear all notifications button
//           Obx(() {
//             if (controller.notifications.isNotEmpty) {
//               return IconButton(
//                 onPressed: () {
//                   _showClearAllDialog(context);
//                 },
//                 icon: const Icon(CupertinoIcons.clear),
//                 tooltip: 'Clear all notifications',
//               );
//             }
//             return const SizedBox.shrink();
//           }),
//           const SizedBox(width: 8),
//         ],
//       ),
//       body: SafeArea(
//         child: RefreshIndicator(
//           onRefresh: () async {
//             await controller.refreshNotifications();
//           },
//           child: Obx(() {
//             if (controller.isLoading.value) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             if (controller.errorMessage.isNotEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       controller.errorMessage.value,
//                       style: const TextStyle(color: Colors.red),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: () {
//                         controller.fetchNotifications();
//                       },
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               );
//             }
//
//             if (controller.notifications.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       CupertinoIcons.bell_slash,
//                       size: 64,
//                       color: Colors.grey[400],
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'No notifications yet',
//                       style: TextStyle(
//                         fontSize: 18,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'We\'ll notify you when something arrives',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[500],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }
//
//             return ListView.separated(
//               physics: const AlwaysScrollableScrollPhysics(),
//               itemCount: controller.notifications.length,
//               itemBuilder: (BuildContext context, int index) {
//                 final notification = controller.notifications[index];
//                 final senderName = notification['sender']?['name'] ?? 'System';
//                 final title = notification['title'] ?? 'No Title';
//                 final description = notification['description'] ?? '';
//                 final createdAt = notification['createdAt'] ?? '';
//                 final isRead = notification['read'] ?? false;
//                 final notificationId = notification['_id'] ?? '';
//
//                 final notificationTime = DateTime.tryParse(createdAt);
//                 String timeText = 'Just now';
//                 if (notificationTime != null) {
//                   final difference = DateTime.now().difference(notificationTime);
//                   if (difference.inMinutes < 1) {
//                     timeText = 'Just now';
//                   } else if (difference.inMinutes < 60) {
//                     timeText = '${difference.inMinutes} min ago';
//                   } else if (difference.inHours < 24) {
//                     timeText = '${difference.inHours} hr ago';
//                   } else {
//                     timeText = '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
//                   }
//                 }
//
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//                   child: Card(
//                     elevation: 1,
//                     color: isRead ? Colors.white : AppColors.primaryColor.withOpacity(0.05),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
//                       side: BorderSide(
//                         color: AppColors.primaryColor.withOpacity(0.2),
//                         width: 1,
//                       ),
//                     ),
//                     child: ListTile(
//                       onTap: () async {
//                         if (!isRead) {
//                           await controller.markNotificationAsRead(notificationId);
//                         }
//                         // Handle notification tap (navigate to relevant screen)
//                         _handleNotificationTap(notification);
//                       },
//                       leading: Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: isRead ? AppColors.whiteColor : AppColors.primaryColor.withOpacity(0.1),
//                           border: Border.all(
//                             color: isRead ? AppColors.primaryColor : AppColors.primaryColor.withOpacity(0.5),
//                           ),
//                           borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
//                         ),
//                         child: Icon(
//                           CupertinoIcons.bell,
//                           color: isRead ? AppColors.primaryColor : AppColors.primaryColor,
//                           size: 20,
//                         ),
//                       ),
//                       title: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: <Widget>[
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   title,
//                                   style: TextStyle(
//                                     fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
//                                     fontSize: 16,
//                                   ),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                               if (!isRead)
//                                 Container(
//                                   width: 8,
//                                   height: 8,
//                                   decoration: const BoxDecoration(
//                                     color: Colors.red,
//                                     shape: BoxShape.circle,
//                                   ),
//                                 ),
//                             ],
//                           ),
//                           if (description.isNotEmpty) ...[
//                             const SizedBox(height: 4),
//                             Text(
//                               description,
//                               style: context.txtTheme.bodySmall?.copyWith(
//                                 color: AppColors.greyColor,
//                                 fontWeight: isRead ? FontWeight.normal : FontWeight.w500,
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ],
//                           const SizedBox(height: 4),
//                           Row(
//                             children: [
//                               Text(
//                                 'From: $senderName',
//                                 style: context.txtTheme.bodySmall?.copyWith(
//                                   color: AppColors.greyColor,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                               const Spacer(),
//                               Text(
//                                 timeText,
//                                 style: context.txtTheme.bodySmall?.copyWith(
//                                   color: AppColors.greyColor,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//               separatorBuilder: (BuildContext context, int index) {
//                 return const SizedBox(height: 4);
//               },
//             );
//           }),
//         ),
//       ),
//     );
//   }
//
//   void _showClearAllDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Clear All Notifications'),
//           content: const Text('Are you sure you want to clear all notifications?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Get.back();
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Get.back();
//                 controller.clearAllNotifications();
//               },
//               child: const Text(
//                 'Clear All',
//                 style: TextStyle(color: Colors.red),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _handleNotificationTap(Map<String, dynamic> notification) {
//     // Handle navigation based on notification type or data
//     final type = notification['type'] ?? '';
//     final data = notification['data'] ?? {};
//
//     // Example: Navigate to different screens based on notification type
//     switch (type) {
//       case 'booking':
//       // Get.toNamed(AppRoutes.bookingDetails, arguments: data);
//         break;
//       case 'message':
//       // Get.toNamed(AppRoutes.chat, arguments: data);
//         break;
//       default:
//       // Default behavior or show notification details
//         break;
//     }
//   }
// }
