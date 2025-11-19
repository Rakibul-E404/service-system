/**
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/features/auth/widgets/custom_text_field.dart';
import '../controllers/message_controller.dart';
import '../model/chat_user.dart';
import 'individual_chat_screen.dart';

class MessageScreen extends GetView<MessageController> {
  const MessageScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final MessageController controller = Get.put(MessageController());

    return Scaffold(
      backgroundColor: Colors.white,
 
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: MyTextFormFieldWithIcon(
                formHintText: 'Search',
                prefixIcon: Icon(CupertinoIcons.search, color: AppColors.primaryColor),
              ),
            ),
        
            const SizedBox(height: 16),
        
            // Chat List
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: controller.users.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ChatUser user = controller.users[index];
                    return _buildChatTile(user, controller);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTile(ChatUser user, MessageController controller) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: <Widget>[
          CircleAvatar(radius: 28, backgroundImage: NetworkImage(user.avatar)),
          if (user.isOnline)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      subtitle: Text(user.lastMessage, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
      onTap: () {
        controller.selectUser(user);
        Get.to(() => IndividualChatScreen());
      },
    );
  }
}
*/







///
///
///
///
/// todo::: adding the api
///
///
///
///
///



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/features/auth/widgets/custom_text_field.dart';
import '../controllers/message_controller.dart';
import '../model/chat_user.dart' hide ChatUser;
import 'individual_chat_screen.dart';

class MessageScreen extends GetView<MessageController> {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MessageController controller = Get.put(MessageController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: MyTextFormFieldWithIcon(
                formHintText: 'Search',
                prefixIcon: Icon(CupertinoIcons.search, color: AppColors.primaryColor),
              ),
            ),

            const SizedBox(height: 16),

            // Chat List
            Expanded(
              child: Obx(
                    () {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (controller.users.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No conversations yet',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => controller.refreshConversations(),
                    child: ListView.builder(
                      itemCount: controller.users.length,
                      itemBuilder: (BuildContext context, int index) {
                        final ChatUser user = controller.users[index];
                        return _buildChatTile(user, controller);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTile(ChatUser user, MessageController controller) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: <Widget>[
          CircleAvatar(
            radius: 28,
            backgroundImage: user.avatar.isNotEmpty
                ? NetworkImage(user.avatar)
                : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
          ),
          if (user.isOnline)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      subtitle: Text(
        user.lastMessage,
        style: TextStyle(color: Colors.grey[600], fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        user.time,
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
      ),
      onTap: () {
        controller.selectUser(user);
        Get.to(() => IndividualChatScreen());
      },
    );
  }
}