
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../home/controllers/notification_controller.dart';
import '../../profile/controllers/profile_controller.dart';


class ProviderTopBar extends StatelessWidget {
  const ProviderTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the existing instances
    final ProfileController controller = Get.put(ProfileController());

    final NotificationController notificationController = Get.find<NotificationController>();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xl, horizontal: AppSizes.sm),
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.primaryColor, width: 2)),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.borderRadiusXl),
          bottomRight: Radius.circular(AppSizes.borderRadiusXl),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // 👤 Dynamic provider name
          Obx(() {
            final name = controller.name.value;
            return SizedBox(
              width: 230,
              child: Text(
                name.isNotEmpty ? "Hey, $name" : "Hey there 👋",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // 🖼️ Profile image (reactive)
              Obx(() {
                final imageUrl = controller.getImageUrl();
                return CircleAvatar(
                  radius: 24,
                  backgroundImage:
                  imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  backgroundColor: Colors.grey[200],
                  child: imageUrl.isEmpty
                      ? const Icon(Icons.person, size: 28, color: Colors.grey)
                      : null,
                );
              }),

              const SizedBox(width: 8),

              // 🔔 Notification icon with simple red dot
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () async {
                      // Remove the notification dot immediately when icon is tapped
                      notificationController.markAllNotificationsAsRead();
                      // Then navigate to notification page
                      Get.toNamed(AppRoutes.notificationPage);
                    },
                    icon: const Icon(
                      CupertinoIcons.bell,
                      color: AppColors.primaryColor,
                      size: 28,
                    ),
                  ),

                  // Simple red dot (no numbers)
                  Obx(() {
                    if (notificationController.hasUnreadNotifications.value) {
                      return Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}


