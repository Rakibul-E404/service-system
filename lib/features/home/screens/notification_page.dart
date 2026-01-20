

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






