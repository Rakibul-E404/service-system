import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/utils/api/app_url.dart';
import '../../home/screens/provider_details_screen.dart';
import '../../profile/screens/report_page.dart';
import '../controllers/message_controller.dart';
import '../model/conversation_single_response_model.dart';

class IndividualChatScreen extends GetView<MessageController> {
  IndividualChatScreen({super.key});

  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light background for chat
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          final conversation = controller.selectedConversation.value;
          if (conversation == null) return const SizedBox();

          final otherUser = controller.getOtherUser(conversation.users);
          if (otherUser == null) return const SizedBox();

          // Handle URL logic
          final String imageUrl = otherUser.image.isNotEmpty
              ? (otherUser.image.startsWith('http')
              ? otherUser.image
              : '${AppUrl.imageBaseUrl}/${otherUser.image}')
              : '';

          return Row(
            children: <Widget>[
              CircleAvatar(
                radius: 18,
                backgroundImage: imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      otherUser.name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      'Available', // You can update this based on your model later
                      style: TextStyle(color: Colors.green, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
        actions: <Widget>[
          IconButton(onPressed: () {}, icon: const Icon(Icons.call, color: Colors.black54)),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (String value) => _handleMenuSelection(value),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(children: [Icon(Icons.person, size: 20), SizedBox(width: 8), Text('View Profile')]),
              ),
              const PopupMenuItem<String>(
                value: 'report',
                child: Row(children: [Icon(Icons.report, size: 20), SizedBox(width: 8), Text('Report User')]),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Loading Indicator
          Obx(() => controller.showBannerLoading.value
              ? const LinearProgressIndicator(minHeight: 2, backgroundColor: Colors.transparent)
              : const SizedBox.shrink()),

          // Messages List
          Expanded(
            child: Obx(() {
              final messages = controller.messages;

              if (messages.isEmpty && !controller.showBannerLoading.value) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadMessages(controller.selectedConversation.value!.id),
                child: ListView.builder(
                  controller: controller.chatScrollController, // 🔹 ADD THIS LINE
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(messages[index]);
                  },
                ),
              );
            }),
          ),

          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message) {
    final bool isMe = message.author.id == (controller.currentUserId ?? '');
    final otherUser = controller.getOtherUser(controller.selectedConversation.value?.users ?? []);

    // Handle URL logic for the other user's avatar
    String otherUserImageUrl = '';
    if (otherUser != null && otherUser.image.isNotEmpty) {
      otherUserImageUrl = otherUser.image.startsWith('http')
          ? otherUser.image
          : '${AppUrl.imageBaseUrl}/${otherUser.image}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          if (!isMe) ...[
            CircleAvatar(
              radius: 12,
              backgroundImage: otherUserImageUrl.isNotEmpty
                  ? NetworkImage(otherUserImageUrl)
                  : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primaryColor : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1)
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.formatTime(message.createdAt),
                    style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[200]!))),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(icon: const Icon(Icons.attach_file, color: Colors.grey), onPressed: () {}),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(24)),
                child: TextField(
                  controller: messageController,
                  decoration: const InputDecoration(hintText: 'Type a message...', border: InputBorder.none),
                  onSubmitted: (val) => _send(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _send,
              child: const CircleAvatar(
                backgroundColor: AppColors.primaryColor,
                child: Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _send() {
    if (messageController.text.trim().isEmpty) return;
    controller.sendMessage(messageController.text.trim());
    messageController.clear();
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 50, color: Colors.grey),
          SizedBox(height: 12),
          Text("No messages yet", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _handleMenuSelection(String value) {
    final otherUser = controller.getOtherUser(controller.selectedConversation.value?.users ?? []);
    if (otherUser == null) return;

    if (value == 'profile') {
      Get.to(() => ProviderDetailsScreen(), arguments: {'authId': otherUser.id});
    } else if (value == 'report') {
      Get.to(() => ReportPage(), arguments: {'reportedUserId': otherUser.id, 'userName': otherUser.name});
    }
  }
}