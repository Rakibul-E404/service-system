
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:manx_mate/core/config/app_sizes.dart';
import 'package:manx_mate/features/auth/widgets/custom_text_field.dart';
import 'package:manx_mate/features/auth/screens/profile_service.dart'; // Add this import
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/api/app_url.dart';
import '../../../shared/subscriptions_controller.dart';
import '../controllers/message_controller.dart';
import '../model/conversation_all_list_response_model.dart';
import 'individual_chat_screen.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final MessageController controller = Get.isRegistered<MessageController>()
      ? Get.find<MessageController>()
      : Get.put(MessageController());

  final SubscriptionsController subController = Get.isRegistered<SubscriptionsController>()
      ? Get.find<SubscriptionsController>()
      : Get.put(SubscriptionsController());

  final ProfileService profileService = Get.find<ProfileService>();

  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   surfaceTintColor: Colors.white,
      //   elevation: 0.5,
      //   title: const Text(
      //     'Messages',
      //     style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
      //   ),
      //   centerTitle: true,
      //
      // ),
      body: SafeArea(
        child: Obx(() {
          if (!profileService.isLoggedIn.value) {
            return _buildLoginPrompt(context);
          }

          return Column(
            children: <Widget>[
              _buildSearchBar(),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return _buildLoadingState();
                  }

                  // Updated filtering logic using the new ConversationModel list
                  final filteredConversations = controller.conversations.where((conv) {
                    final otherUser = controller.getOtherUser(conv.users);
                    return otherUser?.name
                        .toLowerCase()
                        .contains(_searchQuery.value.toLowerCase()) ??
                        false;
                  }).toList();

                  if (filteredConversations.isEmpty) {
                    return _buildEmptyState(_searchQuery.value.isNotEmpty);
                  }

                  // Inside MessageScreen build
                  return RefreshIndicator(
                    onRefresh: () => controller.loadConversations(),
                    color: AppColors.primaryColor,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(), // 🔹 Ensure this is here
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredConversations.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      itemBuilder: (context, index) {
                        return _buildChatTile(filteredConversations[index]);
                      },
                    ),
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: MyTextFormFieldWithIcon(
        controller: _searchController,
        formHintText: 'Search conversations...',
        prefixIcon: const Icon(CupertinoIcons.search,
            color: AppColors.primaryColor, size: 20),
        onChanged: (value) => _searchQuery.value = value,
      ),
    );
  }

  Widget _buildChatTile(ConversationModel conversation) {
    // Extract the other person's info
    final otherUser = controller.getOtherUser(conversation.users);
    if (otherUser == null) return const SizedBox.shrink();

    // Use Obx to make the tile reactive to subscription changes
    return Obx(() {
      final bool hasAccess = subController.canMessage;

      return InkWell(
        onTap: () {
          if (hasAccess) {
            controller.selectConversation(conversation);
          } else {
            // Show the premium alert if they don't have "Massaging" access or are inactive
            subController.showPremiumContactAlert("Messaging");
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              // Avatar with a subtle desaturation if locked
              Opacity(
                opacity: hasAccess ? 1.0 : 0.6,
                child: _buildAvatar(otherUser),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          otherUser.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: hasAccess ? Colors.black : Colors.black54,
                          ),
                        ),
                        Text(
                          controller.formatTime(conversation.lastMessage?.createdAt),
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessage?.text ?? 'Start a conversation',
                            style: TextStyle(
                              color: hasAccess ? Colors.grey[600] : Colors.grey[400],
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Visual Indicator: Show a lock icon if user is not premium/active
                        if (!hasAccess)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.lock_outline,
                              size: 14,
                              color: Colors.amber[800],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }


  Widget _buildAvatar(ConversationUser user) {
    // Logic: Use full URL if it starts with http, otherwise append to base URL
    final String imageUrl = user.image.isNotEmpty
        ? (user.image.startsWith('http')
        ? user.image
        : '${AppUrl.imageBaseUrl}/${user.image}')
        : '';

    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.grey[100],
      child: ClipOval(
        child: imageUrl.isNotEmpty
            ? Image.network(
          imageUrl,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildDefaultAvatar(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            );
          },
        )
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Image.asset(
      'assets/images/default_avatar.png',
      width: 56,
      height: 56,
      fit: BoxFit.cover,
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Not Logged In',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text('Please login to view your messages'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Get.offAllNamed('/role-selection');
            },
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isSearching ? CupertinoIcons.search : Icons.chat_bubble_outline,
              size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(isSearching ? "No results found" : "No messages yet",
              style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor));
  }
}

