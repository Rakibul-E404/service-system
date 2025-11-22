

import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/network/network_response.dart';
import 'package:manx_mate/core/service/socket_service.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/core/data/secured_storage.dart';
import 'package:manx_mate/core/config/app_constants.dart';

import '../../../core/utils/logger_utils.dart';
import '../model/chat_user.dart';
import '../model/message.dart';

class MessageController extends GetxController {
  RxList<ChatUser> users = <ChatUser>[].obs;
  RxList<Message> messages = <Message>[].obs;
  Rx<ChatUser?> selectedUser = Rx<ChatUser?>(null);
  RxBool isLoading = false.obs;
  RxBool isLoadingMessages = false.obs;
  RxBool showBannerLoading = false.obs;
  final NetworkCaller _networkCaller = NetworkCaller();
  final SecureStorageService _secureStorage = SecureStorageService();
  String? _currentUserId;

  Future<void> handleListenConversation() async{
    LoggerUtils.debug("listening method handleListenConversation");
    final String? userId = await _secureStorage.read(AppConstants.userId);
    SocketServices().listen("conversation::$userId", (dynamic data){
      loadConversations();
    });
  }

  Future<void> handleListenMessage({required String conversationId}) async{
    LoggerUtils.debug("listening method handleListenMessage");
    SocketServices().listen("message::$conversationId", (dynamic data){
      loadMessages(conversationId);
    });
  }

  @override
  void onInit() {
    super.onInit();
    handleListenConversation();
    _loadCurrentUserId();
    loadConversations();
  }

  Future<void> _loadCurrentUserId() async {
    _currentUserId = await _secureStorage.read(AppConstants.userId);
  }

  Future<void> loadConversations() async {
    try {
      isLoading.value = true;

      final String? token = await _secureStorage.read(AppConstants.authToken);

      if (token == null || token.isEmpty) {
        Get.snackbar('Error', 'Please login again');
        isLoading.value = false;
        return;
      }

      final NetworkResponse response = await _networkCaller.getRequest(
        '${AppUrl.baseUrl}/conversation/all',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      isLoading.value = false;

      if (response.isSuccess && response.jsonResponse != null) {
        final bool success = response.jsonResponse!['success'] ?? false;
        final Map<String, dynamic>? data = response.jsonResponse!['data'];

        if (success && data != null) {
          final List<dynamic> conversations = data['data'] ?? [];
          users.value = await _parseConversations(conversations);
        } else {
          Get.snackbar('Error', 'Failed to load conversations');
        }
      } else {
        final String errorMessage = response.jsonResponse?['message'] ??
            response.errorMessage ?? 'Failed to load conversations';
        Get.snackbar('Error', errorMessage);
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'An unexpected error occurred');
    }
  }

  Future<List<ChatUser>> _parseConversations(List<dynamic> conversations) async {
    if (_currentUserId == null) {
      await _loadCurrentUserId();
    }

    final List<ChatUser> chatUsers = [];

    for (final conversation in conversations) {
      final String conversationId = conversation['_id'] ?? '';
      final List<dynamic> usersList = conversation['users'] ?? [];
      final Map<String, dynamic>? lastMessageData = conversation['lastMessage'];

      Map<String, dynamic>? otherUser;
      for (final user in usersList) {
        final String userId = user['_id'] ?? '';
        if (userId != _currentUserId) {
          otherUser = user;
          break;
        }
      }

      if (otherUser == null && usersList.isNotEmpty) {
        otherUser = usersList[0];
      }

      if (otherUser != null) {
        final String userId = otherUser['_id'] ?? '';
        final String userName = otherUser['name'] ?? 'Unknown User';
        final String userImage = otherUser['image'] ?? '';
        final String fullImageUrl = userImage.isNotEmpty ?
        AppUrl.getUserProfileImageUrl(userImage) : '';

        String lastMessageText = 'No messages yet';
        String lastMessageTime = '';

        if (lastMessageData != null) {
          lastMessageText = lastMessageData['text'] ?? 'No messages yet';
          final String createdAt = lastMessageData['createdAt'] ?? '';
          lastMessageTime = _formatMessageTime(createdAt);
        }

        chatUsers.add(ChatUser(
          id: userId,
          conversationId: conversationId,
          name: userName,
          avatar: fullImageUrl,
          lastMessage: lastMessageText,
          time: lastMessageTime,
          isOnline: false,
        ));
      }
    }

    return chatUsers;
  }

  Future<void> loadMessages(String conversationId) async {
    try {
      showBannerLoading.value = true;

      final String? token = await _secureStorage.read(AppConstants.authToken);

      if (token == null || token.isEmpty) {
        Get.snackbar('Error', 'Please login again');
        showBannerLoading.value = false;
        return;
      }

      final NetworkResponse response = await _networkCaller.getRequest(
        '${AppUrl.baseUrl}/conversation/$conversationId/single',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      showBannerLoading.value = false;

      if (response.isSuccess && response.jsonResponse != null) {
        final bool success = response.jsonResponse!['success'] ?? false;
        final Map<String, dynamic>? data = response.jsonResponse!['data'];

        if (success && data != null) {
          final List<dynamic> messagesData = data['messages'] ?? [];
          messages.value = await _parseMessages(messagesData);
        } else {
          Get.snackbar('Error', 'Failed to load messages');
        }
      } else {
        final String errorMessage = response.jsonResponse?['message'] ??
            response.errorMessage ?? 'Failed to load messages';
        Get.snackbar('Error', errorMessage);
      }
    } catch (e) {
      showBannerLoading.value = false;
      Get.snackbar('Error', 'An unexpected error occurred while loading messages');
    }
  }

  Future<List<Message>> _parseMessages(List<dynamic> messagesData) async {
    if (_currentUserId == null) {
      await _loadCurrentUserId();
    }

    final List<Message> parsedMessages = [];

    for (final messageData in messagesData) {
      final String messageId = messageData['_id'] ?? '';
      final String text = messageData['text'] ?? '';
      final String createdAt = messageData['createdAt'] ?? '';
      final Map<String, dynamic> author = messageData['author'] ?? {};
      final String authorId = author['_id'] ?? '';

      final bool isSentByMe = authorId == _currentUserId;

      final String authorImage = author['image'] ?? '';
      final String authorAvatar = authorImage.isNotEmpty ?
      AppUrl.getUserProfileImageUrl(authorImage) : '';

      parsedMessages.add(Message(
        id: messageId,
        text: text,
        time: _formatMessageTime(createdAt),
        isSentByMe: isSentByMe,
        authorId: authorId,
        authorName: author['name'] ?? 'Unknown',
        authorAvatar: authorAvatar,
      ));
    }

    return parsedMessages;
  }

  String _formatMessageTime(String isoTime) {
    if (isoTime.isEmpty) return '';

    try {
      final DateTime time = DateTime.parse(isoTime).toLocal();
      final String hour = time.hour.toString().padLeft(2, '0');
      final String minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      return '';
    }
  }

  void selectUser(ChatUser user) {
    selectedUser.value = user;
    loadMessages(user.conversationId);
    handleListenMessage(conversationId: user.conversationId);

  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final ChatUser? currentSelectedUser = selectedUser.value;
    if (currentSelectedUser == null) {
      Get.snackbar('Error', 'No conversation selected');
      return;
    }

    try {
      final String? token = await _secureStorage.read(AppConstants.authToken);

      if (token == null || token.isEmpty) {
        Get.snackbar('Error', 'Please login again');
        return;
      }

      final Map<String, dynamic> requestBody = {
        "text": text.trim(),
        "type": "text"
      };

      final NetworkResponse response = await _networkCaller.postRequest(
        '${AppUrl.baseUrl}/conversation/${currentSelectedUser.conversationId}/message',
        body: requestBody,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final bool success = response.jsonResponse!['success'] ?? false;

        if (success) {
          _refreshMessagesSilently(currentSelectedUser.conversationId);
          _refreshConversationsSilently();
        } else {
          final String errorMessage = response.jsonResponse?['message'] ?? 'Failed to send message';
          Get.snackbar('Error', errorMessage);
        }
      } else {
        final String errorMessage = response.jsonResponse?['message'] ??
            response.errorMessage ?? 'Failed to send message';
        Get.snackbar('Error', errorMessage);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: ${e.toString()}');
    }
  }

  Future<void> _refreshMessagesSilently(String conversationId) async {
    try {
      final String? token = await _secureStorage.read(AppConstants.authToken);
      if (token == null || token.isEmpty) return;

      final NetworkResponse response = await _networkCaller.getRequest(
        '${AppUrl.baseUrl}/conversation/$conversationId/single',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final bool success = response.jsonResponse!['success'] ?? false;
        final Map<String, dynamic>? data = response.jsonResponse!['data'];

        if (success && data != null) {
          final List<dynamic> messagesData = data['messages'] ?? [];
          messages.value = await _parseMessages(messagesData);
        }
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _refreshConversationsSilently() async {
    try {
      final String? token = await _secureStorage.read(AppConstants.authToken);
      if (token == null || token.isEmpty) return;

      final NetworkResponse response = await _networkCaller.getRequest(
        '${AppUrl.baseUrl}/conversation/all',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final bool success = response.jsonResponse!['success'] ?? false;
        final Map<String, dynamic>? data = response.jsonResponse!['data'];

        if (success && data != null) {
          final List<dynamic> conversations = data['data'] ?? [];
          users.value = await _parseConversations(conversations);
        }
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> refreshConversations() async {
    await loadConversations();
  }

  Future<void> refreshMessages() async {
    final ChatUser? currentUser = selectedUser.value;
    if (currentUser != null) {
      await loadMessages(currentUser.conversationId);
    }
  }
}

class ChatUser {
  final String id;
  final String conversationId;
  final String name;
  final String avatar;
  final String lastMessage;
  final String time;
  final bool isOnline;

  ChatUser({
    required this.id,
    required this.conversationId,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.time,
    required this.isOnline,
  });
}

class Message {
  final String id;
  final String text;
  final String time;
  final bool isSentByMe;
  final String authorId;
  final String authorName;
  final String authorAvatar;

  Message({
    required this.id,
    required this.text,
    required this.time,
    required this.isSentByMe,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
  });
}