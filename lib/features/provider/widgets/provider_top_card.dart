import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../profile/controllers/profile_controller.dart'; // ✅ Use ProfileController for data

class ProviderTopBar extends StatelessWidget {
  const ProviderTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Get or create the ProfileController (shared instance)
    final ProfileController controller = Get.put(ProfileController());

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
            return Text(
              name.isNotEmpty ? "Hey, $name 👋" : "Hey there 👋",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            );
          }),

          Row(
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

              // 🔔 Notification icon
              IconButton(
                onPressed: () {
                  Get.toNamed(AppRoutes.notificationPage);
                },
                icon: const Icon(
                  CupertinoIcons.bell,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
