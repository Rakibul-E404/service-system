import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/screens/provider_details_screen.dart';
import '../../profile/screens/report_page.dart';
import '../controllers/message_controller.dart';

class IndividualChatScreen extends GetView<MessageController> {
  IndividualChatScreen({super.key});

  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          final ChatUser? user = controller.selectedUser.value;
          if (user == null) {
            return const SizedBox();
          }

          return Row(
            children: <Widget>[
              CircleAvatar(
                radius: 18,
                backgroundImage: user.avatar.isNotEmpty
                    ? NetworkImage(user.avatar)
                    : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    user.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          );
        }),
        actions: <Widget>[
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (String value) => _handleMenuSelection(value, context),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('View Profile'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.report, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Report User'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Banner Loading Indicator
          Obx(() => controller.showBannerLoading.value
              ? Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.amber[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[700]!),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Loading messages...',
                  style: TextStyle(
                    color: Colors.amber[800],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
              : const SizedBox.shrink()),

          // Messages List
          Expanded(
            child: Obx(() {
              if (controller.messages.isEmpty && !controller.showBannerLoading.value) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No messages yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Text(
                        'Start a conversation',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.refreshMessages(),
                child: ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Message message = controller.messages[index];
                    return _buildMessageBubble(message);
                  },
                ),
              );
            }),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                // Attachment Icon
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Get.snackbar(
                          'Info',
                          'Attachment feature coming soon',
                          backgroundColor: Colors.blue,
                          colorText: Colors.white,
                        );
                      },
                      child: Icon(Icons.attach_file, color: Colors.amber[600], size: 24),
                    ),
                  ),
                ),

                // Text Input
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: messageController,
                      decoration: const InputDecoration(
                        hintText: 'Send Message',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (String text) => _sendMessage(controller, text),
                    ),
                  ),
                ),

                // Send Button
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: () => _sendMessage(controller, messageController.text),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber[600],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
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

  Widget _buildMessageBubble(Message message) {
    final ChatUser? selectedUser = controller.selectedUser.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          if (!message.isSentByMe) ...<Widget>[
            CircleAvatar(
              radius: 12,
              backgroundImage: selectedUser != null && selectedUser.avatar.isNotEmpty
                  ? NetworkImage(selectedUser.avatar)
                  : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: Get.width * 0.7),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: message.isSentByMe ? Colors.amber[200] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    message.text,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.time,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),

          if (message.isSentByMe) ...<Widget>[
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              child: Icon(Icons.done_all, size: 16, color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }

  void _sendMessage(MessageController controller, String text) {
    if (text.trim().isEmpty) return;

    controller.sendMessage(text);
    messageController.clear();
  }

  void _handleMenuSelection(String value, BuildContext context) {
    final ChatUser? selectedUser = controller.selectedUser.value;

    switch (value) {
      case 'profile':
        _viewProfile(selectedUser);
        break;
      case 'report':
        _navigateToReportScreen(selectedUser); // Direct navigation
        break;
    }
  }

  void _navigateToReportScreen(ChatUser? user) {
    if (user == null) {
      Get.snackbar('Error', 'User not found');
      return;
    }

    // Navigate directly to ReportPage with the author ID
    Get.to(
          () => ReportPage(),
      arguments: {
        'reportedUserId': user.id, // Pass the author ID
        'userName': user.name, // Pass user name for context
      },
    );
  }




  void _viewProfile(ChatUser? user) {
    if (user == null) {
      Get.snackbar('Error', 'User not found');
      return;
    }

    // Navigate to ProviderDetailsScreen with the user ID as authId
    Get.to(
          () => ProviderDetailsScreen(),
      arguments: {
        'authId': user.id, // This matches what ProviderDetailsController expects
      },
    );
  }

}