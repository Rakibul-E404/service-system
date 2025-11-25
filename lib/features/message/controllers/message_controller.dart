/**


import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/network/network_response.dart';
import 'package:manx_mate/core/service/socket_service.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/core/data/secured_storage.dart';
import 'package:manx_mate/core/config/app_constants.dart';
import '../../../core/utils/logger_utils.dart';

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
}*/














///
///
///
///
/// todO::: create the conversation
///
///
///







/**import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/network/network_response.dart';
import 'package:manx_mate/core/service/socket_service.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/core/data/secured_storage.dart';
import 'package:manx_mate/core/config/app_constants.dart';
import 'package:manx_mate/core/utils/logger_utils.dart';
import '../screens/individual_chat_screen.dart';

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

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  Future<void> _initializeController() async {
    await _loadCurrentUserId();
    await loadConversations();
    _setupSocketListeners();
  }

  Future<void> _loadCurrentUserId() async {
    _currentUserId = await _secureStorage.read(AppConstants.userId);
    LoggerUtils.debug("Current User ID: $_currentUserId");
  }

  void _setupSocketListeners() {
    if (_currentUserId != null) {
      // Listen for new conversations
      SocketServices().listen("conversation::$_currentUserId", (dynamic data) {
        LoggerUtils.debug("New conversation event received: $data");
        loadConversations(); // Refresh the list
      });

      // Listen for conversation updates
      SocketServices().listen("conversation_update::$_currentUserId", (dynamic data) {
        LoggerUtils.debug("Conversation update received: $data");
        loadConversations(); // Refresh the list
      });
    }
  }

  // ADD THIS MISSING METHOD
  Future<void> handleListenConversation() async {
    LoggerUtils.debug("listening method handleListenConversation");
    final String? userId = await _secureStorage.read(AppConstants.userId);
    if (userId != null) {
      SocketServices().listen("conversation::$userId", (dynamic data) {
        LoggerUtils.debug("Conversation socket event: $data");
        loadConversations();
      });
    }
  }

  // ADD THIS MISSING METHOD
  Future<void> handleListenMessage({required String conversationId}) async {
    LoggerUtils.debug("listening method handleListenMessage for: $conversationId");
    SocketServices().listen("message::$conversationId", (dynamic data) {
      LoggerUtils.debug("New message received: $data");
      loadMessages(conversationId);
    });
  }

  Future<void> loadConversations() async {
    try {
      isLoading.value = true;

      final String? token = await _secureStorage.read(AppConstants.authToken);

      // if (token == null || token.isEmpty) {
      //   Get.snackbar('Error', 'Please login again');
      //   isLoading.value = false;
      //   return;
      // }

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
          final List<ChatUser> parsedUsers = await _parseConversations(conversations);

          // Update the list - this will trigger UI update
          users.value = parsedUsers;

          LoggerUtils.debug("Loaded ${users.length} conversations");
        } else {
          final String errorMessage = response.jsonResponse?['message'] ?? 'Failed to load conversations';
          Get.snackbar('Error', errorMessage);
        }
      } else {
        final String errorMessage = response.jsonResponse?['message'] ??
            response.errorMessage ?? 'Failed to load conversations';
        Get.snackbar('Error', errorMessage);
      }
    } catch (e) {
      LoggerUtils.error("Error loading conversations: $e");
      Get.snackbar('Error', 'An unexpected error occurred');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<ChatUser>> _parseConversations(List<dynamic> conversations) async {
    if (_currentUserId == null) {
      await _loadCurrentUserId();
    }

    final List<ChatUser> chatUsers = [];

    for (final conversation in conversations) {
      try {
        final String conversationId = conversation['_id'] ?? '';
        final List<dynamic> usersList = conversation['users'] ?? [];
        final Map<String, dynamic>? lastMessageData = conversation['lastMessage'];

        LoggerUtils.debug("Processing conversation: $conversationId");
        LoggerUtils.debug("Users list: $usersList");
        LoggerUtils.debug("Last message: $lastMessageData");

        // Find the other user in the conversation
        Map<String, dynamic>? otherUser;

        if (usersList.isEmpty) {
          LoggerUtils.debug("Empty users list for conversation: $conversationId");
          // If users list is empty, try to get user info from last message author
          if (lastMessageData != null && lastMessageData['author'] != null) {
            final Map<String, dynamic> author = lastMessageData['author'];
            final String authorId = author['_id']?.toString() ?? '';

            // If author is not current user, use author as other user
            if (authorId != _currentUserId) {
              otherUser = author;
              LoggerUtils.debug("Using last message author as other user: ${author['name']}");
            } else {
              LoggerUtils.debug("Last message author is current user, skipping");
              continue; // Skip if we can't identify the other user
            }
          } else {
            LoggerUtils.debug("No last message author available, skipping conversation");
            continue; // Skip if we can't identify the other user
          }
        } else {
          // Normal case: find other user in users list
          for (final user in usersList) {
            final String userId = user['_id']?.toString() ?? '';
            if (userId != _currentUserId) {
              otherUser = user;
              break;
            }
          }

          // If no other user found, take the first one
          if (otherUser == null && usersList.isNotEmpty) {
            otherUser = usersList[0];
          }
        }

        if (otherUser != null) {
          final String userId = otherUser['_id']?.toString() ?? '';
          final String userName = otherUser['name']?.toString()?.trim() ?? 'Unknown User';
          final String userImage = otherUser['image']?.toString() ?? '';
          final String fullImageUrl = userImage.isNotEmpty ?
          AppUrl.getUserProfileImageUrl(userImage) : '';

          // Parse last message
          String lastMessageText = 'Start a conversation';
          String lastMessageTime = '';

          if (lastMessageData != null && lastMessageData['text'] != null) {
            lastMessageText = lastMessageData['text']?.toString() ?? 'Start a conversation';
            final String createdAt = lastMessageData['createdAt']?.toString() ?? '';
            lastMessageTime = _formatMessageTime(createdAt);
          }

          // Check if user is online (you might need to implement this based on your backend)
          final bool isOnline = otherUser['isOnline'] == true;

          chatUsers.add(ChatUser(
            id: userId,
            conversationId: conversationId,
            name: userName,
            avatar: fullImageUrl,
            lastMessage: lastMessageText,
            time: lastMessageTime,
            isOnline: isOnline,
          ));

          LoggerUtils.debug("✅ Parsed user: $userName, Last message: $lastMessageText");
        } else {
          LoggerUtils.debug("❌ Could not identify other user for conversation: $conversationId");
        }
      } catch (e) {
        LoggerUtils.error("Error parsing conversation: $e");
        LoggerUtils.error("Problematic conversation data: $conversation");
      }
    }

    // Sort by last message time (most recent first)
    chatUsers.sort((a, b) {
      // Handle empty time strings
      if (a.time.isEmpty && b.time.isEmpty) return 0;
      if (a.time.isEmpty) return 1;
      if (b.time.isEmpty) return -1;
      return b.time.compareTo(a.time);
    });

    LoggerUtils.debug("✅ Final parsed conversations: ${chatUsers.length}");
    return chatUsers;
  }

  Future<void> loadMessages(String conversationId) async {
    try {
      showBannerLoading.value = true;

      final String? token = await _secureStorage.read(AppConstants.authToken);

      // if (token == null || token.isEmpty) {
      //   Get.snackbar('Error', 'Please login again');
      //   showBannerLoading.value = false;
      //   return;
      // }

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

          LoggerUtils.debug("Loaded ${messages.length} messages for conversation: $conversationId");
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
      LoggerUtils.error("Error loading messages: $e");
      Get.snackbar('Error', 'An unexpected error occurred while loading messages');
    }
  }

  Future<List<Message>> _parseMessages(List<dynamic> messagesData) async {
    if (_currentUserId == null) {
      await _loadCurrentUserId();
    }

    final List<Message> parsedMessages = [];

    for (final messageData in messagesData) {
      try {
        final String messageId = messageData['_id']?.toString() ?? '';
        final String text = messageData['text']?.toString() ?? '';
        final String createdAt = messageData['createdAt']?.toString() ?? '';
        final Map<String, dynamic> author = messageData['author'] ?? {};
        final String authorId = author['_id']?.toString() ?? '';

        final bool isSentByMe = authorId == _currentUserId;

        final String authorImage = author['image']?.toString() ?? '';
        final String authorAvatar = authorImage.isNotEmpty ?
        AppUrl.getUserProfileImageUrl(authorImage) : '';

        parsedMessages.add(Message(
          id: messageId,
          text: text,
          time: _formatMessageTime(createdAt),
          isSentByMe: isSentByMe,
          authorId: authorId,
          authorName: author['name']?.toString() ?? 'Unknown',
          authorAvatar: authorAvatar,
        ));
      } catch (e) {
        LoggerUtils.error("Error parsing message: $e");
      }
    }

    // Sort messages by time (oldest first for display)
    parsedMessages.sort((a, b) => a.time.compareTo(b.time));

    return parsedMessages;
  }

  String _formatMessageTime(String isoTime) {
    if (isoTime.isEmpty) return '';

    try {
      final DateTime time = DateTime.parse(isoTime).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDay = DateTime(time.year, time.month, time.day);

      if (messageDay == today) {
        // Today - show time only
        final String hour = time.hour.toString().padLeft(2, '0');
        final String minute = time.minute.toString().padLeft(2, '0');
        return '$hour:$minute';
      } else if (messageDay == today.subtract(const Duration(days: 1))) {
        // Yesterday
        return 'Yesterday';
      } else {
        // Other days - show date
        final String day = time.day.toString().padLeft(2, '0');
        final String month = time.month.toString().padLeft(2, '0');
        return '$day/$month';
      }
    } catch (e) {
      return '';
    }
  }

  void selectUser(ChatUser user) {
    selectedUser.value = user;
    loadMessages(user.conversationId);
    handleListenMessage(conversationId: user.conversationId);
  }

  // Create conversation and navigate to chat
  Future<void> createConversationAndNavigate({
    required String receiverId,
    required String receiverName,
    required String receiverAvatar,
  }) async {
    try {
      // First, check if conversation already exists
      final ChatUser? existingConversation = _findExistingConversation(receiverId);

      if (existingConversation != null) {
        // Conversation exists, navigate directly
        _navigateToChatScreen(existingConversation);
        return;
      }

      isLoading.value = true;

      final String? token = await _secureStorage.read(AppConstants.authToken);

      // if (token == null || token.isEmpty) {
      //   Get.snackbar('Error', 'Please login again');
      //   isLoading.value = false;
      //   return;
      // }

      // Create new conversation
      final Map<String, dynamic> requestBody = {
        "receiverId": receiverId,
      };

      final NetworkResponse response = await _networkCaller.postRequest(
        '${AppUrl.baseUrl}/conversation/create',
        body: requestBody,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      isLoading.value = false;

      if (response.isSuccess && response.jsonResponse != null) {
        final bool success = response.jsonResponse!['success'] ?? false;
        final Map<String, dynamic>? data = response.jsonResponse!['data'];

        if (success && data != null) {
          final String conversationId = data['_id'] ?? '';

          // Create ChatUser object
          final ChatUser chatUser = ChatUser(
            id: receiverId,
            conversationId: conversationId,
            name: receiverName,
            avatar: receiverAvatar,
            lastMessage: 'Start a conversation',
            time: _formatMessageTime(DateTime.now().toIso8601String()),
            isOnline: false,
          );

          // Add to users list immediately
          users.insert(0, chatUser);

          // Navigate to chat
          _navigateToChatScreen(chatUser);

          Get.snackbar('Success', 'Conversation started');

        } else {
          final String errorMessage = response.jsonResponse?['message'] ?? 'Failed to create conversation';
          Get.snackbar('Error', errorMessage);
        }
      } else {
        final String errorMessage = response.jsonResponse?['message'] ??
            response.errorMessage ?? 'Failed to create conversation';
        Get.snackbar('Error', errorMessage);
      }
    } catch (e) {
      isLoading.value = false;
      LoggerUtils.error("Error creating conversation: $e");
      Get.snackbar('Error', 'Failed to start conversation: ${e.toString()}');
    }
  }

  ChatUser? _findExistingConversation(String receiverId) {
    try {
      return users.firstWhere(
            (user) => user.id == receiverId,
      );
    } catch (e) {
      return null;
    }
  }

  void _navigateToChatScreen(ChatUser user) {
    // Set the selected user
    selectedUser.value = user;

    // Load messages for this conversation
    loadMessages(user.conversationId);

    // Set up message listener
    handleListenMessage(conversationId: user.conversationId);

    // Navigate to chat screen
    Get.to(() => IndividualChatScreen());
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

      // if (token == null || token.isEmpty) {
      //   Get.snackbar('Error', 'Please login again');
      //   return;
      // }

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
          // Refresh messages to show the new one
          await loadMessages(currentSelectedUser.conversationId);
          // Refresh conversations to update last message
          await _refreshConversationsSilently();
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
      LoggerUtils.error("Error sending message: $e");
      Get.snackbar('Error', 'Failed to send message: ${e.toString()}');
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
      LoggerUtils.error("Error refreshing conversations: $e");
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

  // Force refresh the conversations list
  void forceRefreshConversations() {
    loadConversations();
  }

  @override
  void onClose() {
    LoggerUtils.debug("MessageController onClose called");
    super.onClose();
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

  @override
  String toString() {
    return 'ChatUser{id: $id, name: $name, lastMessage: $lastMessage}';
  }
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

  @override
  String toString() {
    return 'Message{text: $text, isSentByMe: $isSentByMe, time: $time}';
  }
}*/





///
///
///
/// todo::: locking the error popup
///
///
///




import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/network/network_response.dart';
import 'package:manx_mate/core/service/socket_service.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/core/data/secured_storage.dart';
import 'package:manx_mate/core/config/app_constants.dart';
import 'package:manx_mate/core/utils/logger_utils.dart';
import '../screens/individual_chat_screen.dart';

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

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  Future<void> _initializeController() async {
    await _loadCurrentUserId();
    await loadConversations();
    _setupSocketListeners();
  }

  Future<void> _loadCurrentUserId() async {
    _currentUserId = await _secureStorage.read(AppConstants.userId);
    LoggerUtils.debug("Current User ID: $_currentUserId");
  }

  void _setupSocketListeners() {
    if (_currentUserId != null) {
      // Listen for new conversations
      SocketServices().listen("conversation::$_currentUserId", (dynamic data) {
        LoggerUtils.debug("New conversation event received: $data");
        loadConversations(); // Refresh the list
      });

      // Listen for conversation updates
      SocketServices().listen("conversation_update::$_currentUserId", (dynamic data) {
        LoggerUtils.debug("Conversation update received: $data");
        loadConversations(); // Refresh the list
      });
    }
  }

  // ADD THIS MISSING METHOD
  Future<void> handleListenConversation() async {
    LoggerUtils.debug("listening method handleListenConversation");
    final String? userId = await _secureStorage.read(AppConstants.userId);
    if (userId != null) {
      SocketServices().listen("conversation::$userId", (dynamic data) {
        LoggerUtils.debug("Conversation socket event: $data");
        loadConversations();
      });
    }
  }

  // ADD THIS MISSING METHOD
  Future<void> handleListenMessage({required String conversationId}) async {
    LoggerUtils.debug("listening method handleListenMessage for: $conversationId");
    SocketServices().listen("message::$conversationId", (dynamic data) {
      LoggerUtils.debug("New message received: $data");
      loadMessages(conversationId);
    });
  }

  Future<void> loadConversations() async {
    try {
      isLoading.value = true;

      final String? token = await _secureStorage.read(AppConstants.authToken);

      // Silent token validation - no error popup
      if (token == null || token.isEmpty) {
        LoggerUtils.debug("No auth token available, skipping conversations load");
        users.value = []; // Clear existing conversations
        isLoading.value = false;
        return;
      }

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
          final List<ChatUser> parsedUsers = await _parseConversations(conversations);

          // Update the list - this will trigger UI update
          users.value = parsedUsers;

          LoggerUtils.debug("Loaded ${users.length} conversations");
        } else {
          final String errorMessage = response.jsonResponse?['message'] ?? 'Failed to load conversations';
          LoggerUtils.debug("Error loading conversations: $errorMessage");
          // No snackbar error
        }
      } else {
        final String errorMessage = response.jsonResponse?['message'] ??
            response.errorMessage ?? 'Failed to load conversations';
        LoggerUtils.debug("Network error loading conversations: $errorMessage");
        // No snackbar error
      }
    } catch (e) {
      LoggerUtils.error("Error loading conversations: $e");
      // No snackbar error
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<ChatUser>> _parseConversations(List<dynamic> conversations) async {
    if (_currentUserId == null) {
      await _loadCurrentUserId();
    }

    final List<ChatUser> chatUsers = [];

    for (final conversation in conversations) {
      try {
        final String conversationId = conversation['_id'] ?? '';
        final List<dynamic> usersList = conversation['users'] ?? [];
        final Map<String, dynamic>? lastMessageData = conversation['lastMessage'];

        LoggerUtils.debug("Processing conversation: $conversationId");
        LoggerUtils.debug("Users list: $usersList");
        LoggerUtils.debug("Last message: $lastMessageData");

        // Find the other user in the conversation
        Map<String, dynamic>? otherUser;

        if (usersList.isEmpty) {
          LoggerUtils.debug("Empty users list for conversation: $conversationId");
          // If users list is empty, try to get user info from last message author
          if (lastMessageData != null && lastMessageData['author'] != null) {
            final Map<String, dynamic> author = lastMessageData['author'];
            final String authorId = author['_id']?.toString() ?? '';

            // If author is not current user, use author as other user
            if (authorId != _currentUserId) {
              otherUser = author;
              LoggerUtils.debug("Using last message author as other user: ${author['name']}");
            } else {
              LoggerUtils.debug("Last message author is current user, skipping");
              continue; // Skip if we can't identify the other user
            }
          } else {
            LoggerUtils.debug("No last message author available, skipping conversation");
            continue; // Skip if we can't identify the other user
          }
        } else {
          // Normal case: find other user in users list
          for (final user in usersList) {
            final String userId = user['_id']?.toString() ?? '';
            if (userId != _currentUserId) {
              otherUser = user;
              break;
            }
          }

          // If no other user found, take the first one
          if (otherUser == null && usersList.isNotEmpty) {
            otherUser = usersList[0];
          }
        }

        if (otherUser != null) {
          final String userId = otherUser['_id']?.toString() ?? '';
          final String userName = otherUser['name']?.toString()?.trim() ?? 'Unknown User';
          final String userImage = otherUser['image']?.toString() ?? '';
          final String fullImageUrl = userImage.isNotEmpty ?
          AppUrl.getUserProfileImageUrl(userImage) : '';

          // Parse last message
          String lastMessageText = 'Start a conversation';
          String lastMessageTime = '';

          if (lastMessageData != null && lastMessageData['text'] != null) {
            lastMessageText = lastMessageData['text']?.toString() ?? 'Start a conversation';
            final String createdAt = lastMessageData['createdAt']?.toString() ?? '';
            lastMessageTime = _formatMessageTime(createdAt);
          }

          // Check if user is online (you might need to implement this based on your backend)
          final bool isOnline = otherUser['isOnline'] == true;

          chatUsers.add(ChatUser(
            id: userId,
            conversationId: conversationId,
            name: userName,
            avatar: fullImageUrl,
            lastMessage: lastMessageText,
            time: lastMessageTime,
            isOnline: isOnline,
          ));

          LoggerUtils.debug("✅ Parsed user: $userName, Last message: $lastMessageText");
        } else {
          LoggerUtils.debug("❌ Could not identify other user for conversation: $conversationId");
        }
      } catch (e) {
        LoggerUtils.error("Error parsing conversation: $e");
        LoggerUtils.error("Problematic conversation data: $conversation");
      }
    }

    // Sort by last message time (most recent first)
    chatUsers.sort((a, b) {
      // Handle empty time strings
      if (a.time.isEmpty && b.time.isEmpty) return 0;
      if (a.time.isEmpty) return 1;
      if (b.time.isEmpty) return -1;
      return b.time.compareTo(a.time);
    });

    LoggerUtils.debug("✅ Final parsed conversations: ${chatUsers.length}");
    return chatUsers;
  }

  Future<void> loadMessages(String conversationId) async {
    try {
      showBannerLoading.value = true;

      final String? token = await _secureStorage.read(AppConstants.authToken);

      // Silent token validation - no error popup
      if (token == null || token.isEmpty) {
        LoggerUtils.debug("No auth token available, skipping messages load");
        messages.value = []; // Clear existing messages
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

          LoggerUtils.debug("Loaded ${messages.length} messages for conversation: $conversationId");
        } else {
          LoggerUtils.debug("Failed to load messages for conversation: $conversationId");
          // No snackbar error
        }
      } else {
        final String errorMessage = response.jsonResponse?['message'] ??
            response.errorMessage ?? 'Failed to load messages';
        LoggerUtils.debug("Network error loading messages: $errorMessage");
        // No snackbar error
      }
    } catch (e) {
      showBannerLoading.value = false;
      LoggerUtils.error("Error loading messages: $e");
      // No snackbar error
    }
  }

  Future<List<Message>> _parseMessages(List<dynamic> messagesData) async {
    if (_currentUserId == null) {
      await _loadCurrentUserId();
    }

    final List<Message> parsedMessages = [];

    for (final messageData in messagesData) {
      try {
        final String messageId = messageData['_id']?.toString() ?? '';
        final String text = messageData['text']?.toString() ?? '';
        final String createdAt = messageData['createdAt']?.toString() ?? '';
        final Map<String, dynamic> author = messageData['author'] ?? {};
        final String authorId = author['_id']?.toString() ?? '';

        final bool isSentByMe = authorId == _currentUserId;

        final String authorImage = author['image']?.toString() ?? '';
        final String authorAvatar = authorImage.isNotEmpty ?
        AppUrl.getUserProfileImageUrl(authorImage) : '';

        parsedMessages.add(Message(
          id: messageId,
          text: text,
          time: _formatMessageTime(createdAt),
          isSentByMe: isSentByMe,
          authorId: authorId,
          authorName: author['name']?.toString() ?? 'Unknown',
          authorAvatar: authorAvatar,
        ));
      } catch (e) {
        LoggerUtils.error("Error parsing message: $e");
      }
    }

    // Sort messages by time (oldest first for display)
    parsedMessages.sort((a, b) => a.time.compareTo(b.time));

    return parsedMessages;
  }

  String _formatMessageTime(String isoTime) {
    if (isoTime.isEmpty) return '';

    try {
      final DateTime time = DateTime.parse(isoTime).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDay = DateTime(time.year, time.month, time.day);

      if (messageDay == today) {
        // Today - show time only
        final String hour = time.hour.toString().padLeft(2, '0');
        final String minute = time.minute.toString().padLeft(2, '0');
        return '$hour:$minute';
      } else if (messageDay == today.subtract(const Duration(days: 1))) {
        // Yesterday
        return 'Yesterday';
      } else {
        // Other days - show date
        final String day = time.day.toString().padLeft(2, '0');
        final String month = time.month.toString().padLeft(2, '0');
        return '$day/$month';
      }
    } catch (e) {
      return '';
    }
  }

  void selectUser(ChatUser user) {
    selectedUser.value = user;
    loadMessages(user.conversationId);
    handleListenMessage(conversationId: user.conversationId);
  }

  // Create conversation and navigate to chat
  Future<void> createConversationAndNavigate({
    required String receiverId,
    required String receiverName,
    required String receiverAvatar,
  }) async {
    try {
      // First, check if conversation already exists
      final ChatUser? existingConversation = _findExistingConversation(receiverId);

      if (existingConversation != null) {
        // Conversation exists, navigate directly
        _navigateToChatScreen(existingConversation);
        return;
      }

      isLoading.value = true;

      final String? token = await _secureStorage.read(AppConstants.authToken);

      // Silent token validation - no error popup
      if (token == null || token.isEmpty) {
        LoggerUtils.debug("No auth token available, cannot create conversation");
        isLoading.value = false;
        return;
      }

      // Create new conversation
      final Map<String, dynamic> requestBody = {
        "receiverId": receiverId,
      };

      final NetworkResponse response = await _networkCaller.postRequest(
        '${AppUrl.baseUrl}/conversation/create',
        body: requestBody,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      isLoading.value = false;

      if (response.isSuccess && response.jsonResponse != null) {
        final bool success = response.jsonResponse!['success'] ?? false;
        final Map<String, dynamic>? data = response.jsonResponse!['data'];

        if (success && data != null) {
          final String conversationId = data['_id'] ?? '';

          // Create ChatUser object
          final ChatUser chatUser = ChatUser(
            id: receiverId,
            conversationId: conversationId,
            name: receiverName,
            avatar: receiverAvatar,
            lastMessage: 'Start a conversation',
            time: _formatMessageTime(DateTime.now().toIso8601String()),
            isOnline: false,
          );

          // Add to users list immediately
          users.insert(0, chatUser);

          // Navigate to chat
          _navigateToChatScreen(chatUser);

          // No success snackbar to avoid popups

        } else {
          final String errorMessage = response.jsonResponse?['message'] ?? 'Failed to create conversation';
          LoggerUtils.debug("Error creating conversation: $errorMessage");
          // No snackbar error
        }
      } else {
        final String errorMessage = response.jsonResponse?['message'] ??
            response.errorMessage ?? 'Failed to create conversation';
        LoggerUtils.debug("Network error creating conversation: $errorMessage");
        // No snackbar error
      }
    } catch (e) {
      isLoading.value = false;
      LoggerUtils.error("Error creating conversation: $e");
      // No snackbar error
    }
  }

  ChatUser? _findExistingConversation(String receiverId) {
    try {
      return users.firstWhere(
            (user) => user.id == receiverId,
      );
    } catch (e) {
      return null;
    }
  }

  void _navigateToChatScreen(ChatUser user) {
    // Set the selected user
    selectedUser.value = user;

    // Load messages for this conversation
    loadMessages(user.conversationId);

    // Set up message listener
    handleListenMessage(conversationId: user.conversationId);

    // Navigate to chat screen
    Get.to(() => IndividualChatScreen());
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final ChatUser? currentSelectedUser = selectedUser.value;
    if (currentSelectedUser == null) {
      LoggerUtils.debug("No conversation selected for sending message");
      return;
    }

    try {
      final String? token = await _secureStorage.read(AppConstants.authToken);

      // Silent token validation - no error popup
      if (token == null || token.isEmpty) {
        LoggerUtils.debug("No auth token available, cannot send message");
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
          // Refresh messages to show the new one
          await loadMessages(currentSelectedUser.conversationId);
          // Refresh conversations to update last message
          await _refreshConversationsSilently();
        } else {
          final String errorMessage = response.jsonResponse?['message'] ?? 'Failed to send message';
          LoggerUtils.debug("Error sending message: $errorMessage");
          // No snackbar error
        }
      } else {
        final String errorMessage = response.jsonResponse?['message'] ??
            response.errorMessage ?? 'Failed to send message';
        LoggerUtils.debug("Network error sending message: $errorMessage");
        // No snackbar error
      }
    } catch (e) {
      LoggerUtils.error("Error sending message: $e");
      // No snackbar error
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
      LoggerUtils.error("Error refreshing conversations: $e");
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

  // Force refresh the conversations list
  void forceRefreshConversations() {
    loadConversations();
  }

  @override
  void onClose() {
    LoggerUtils.debug("MessageController onClose called");
    super.onClose();
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

  @override
  String toString() {
    return 'ChatUser{id: $id, name: $name, lastMessage: $lastMessage}';
  }
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

  @override
  String toString() {
    return 'Message{text: $text, isSentByMe: $isSentByMe, time: $time}';
  }
}