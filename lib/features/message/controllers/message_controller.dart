/**
// Chat Controller
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../model/chat_user.dart';
import '../model/message.dart';

class MessageController extends GetxController {
  RxList<ChatUser> users = <ChatUser>[].obs;
  RxList<Message> messages = <Message>[].obs;
  Rx<ChatUser?> selectedUser = Rx<ChatUser?>(null);

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  void loadUsers() {
    users.value = <ChatUser>[
      ChatUser(
        id: '1',
        name: 'Rocky Parker',
        avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
        lastMessage: 'you: okay fine. 08:36 am',
        time: '08:36 am',
        isOnline: true,
      ),
      ChatUser(
        id: '2',
        name: 'Maizy Hughert',
        avatar: 'https://images.unsplash.com/photo-1494790108755-2616b772390e?w=100&h=100&fit=crop',
        lastMessage: 'you: okay fine. 08:36 am',
        time: '08:36 am',
        isOnline: false,
      ),
      ChatUser(
        id: '3',
        name: 'Rocky',
        avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop',
        lastMessage: 'you: okay fine. 08:36 am',
        time: '08:36 am',
        isOnline: false,
      ),
      ChatUser(
        id: '4',
        name: 'Maizy Hughert',
        avatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop',
        lastMessage: 'you: okay fine. 08:36 am',
        time: '08:36 am',
        isOnline: true,
      ),
    ];
  }

  void selectUser(ChatUser user) {
    selectedUser.value = user;
    loadMessages(user.id);
  }

  void loadMessages(String userId) {
    // Sample messages for Rocky Parker
    if (userId == '1') {
      messages.value = <Message>[
        Message(id: '1', text: 'Hiyyiii!', time: '3:01 pm', isSentByMe: false),
        Message(
          id: '2',
          text: 'when are we meeting its been so longggg since we meeted.',
          time: '3:01 pm',
          isSentByMe: true,
        ),
        Message(id: '3', text: 'Hyyyy... georg', time: '3:02 pm', isSentByMe: false),
        Message(id: '4', text: 'nxtt week for sure', time: '3:02 pm', isSentByMe: false),
        Message(
          id: '5',
          text: 'We will meet soon sorry babe I promise upcoming sun we will meet for sure.',
          time: '3:02 pm',
          isSentByMe: true,
        ),
        Message(
          id: '6',
          text: 'when are we meeting its been so longggg since we meeted.',
          time: '3:02 pm',
          isSentByMe: true,
        ),
      ];
    } else {
      messages.value = <Message>[
        Message(id: '1', text: 'Hey there!', time: '2:30 pm', isSentByMe: false),
        Message(id: '2', text: 'Hello! How are you?', time: '2:31 pm', isSentByMe: true),
      ];
    }
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final Message newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      time: _getCurrentTime(),
      isSentByMe: true,
    );

    messages.add(newMessage);
  }

  String _getCurrentTime() {
    final DateTime now = DateTime.now();
    final int hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final String period = now.hour >= 12 ? 'pm' : 'am';
    return '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period';
  }
}
*/












///
///
///
/// todo:: addding the api
///
///
///



// import 'package:get/get.dart';
// import 'package:manx_mate/core/network/network_caller.dart';
// import 'package:manx_mate/core/network/network_response.dart';
// import 'package:manx_mate/core/utils/api/app_url.dart';
// import 'package:manx_mate/core/data/secured_storage.dart';
// import 'package:manx_mate/core/config/app_constants.dart';
//
// import '../model/chat_user.dart';
// import '../model/message.dart';
//
// class MessageController extends GetxController {
//   RxList<ChatUser> users = <ChatUser>[].obs;
//   RxList<Message> messages = <Message>[].obs;
//   Rx<ChatUser?> selectedUser = Rx<ChatUser?>(null);
//   RxBool isLoading = false.obs;
//   final NetworkCaller _networkCaller = NetworkCaller();
//   final SecureStorageService _secureStorage = SecureStorageService();
//
//   @override
//   void onInit() {
//     super.onInit();
//     loadConversations();
//   }
//
//   Future<void> loadConversations() async {
//     try {
//       isLoading.value = true;
//
//       final String? token = await _secureStorage.read(AppConstants.authToken);
//
//       if (token == null || token.isEmpty) {
//         Get.snackbar('Error', 'Please login again');
//         isLoading.value = false;
//         return;
//       }
//
//       final NetworkResponse response = await _networkCaller.getRequest(
//         '${AppUrl.baseUrl}/conversation/all',
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       isLoading.value = false;
//
//       if (response.isSuccess && response.jsonResponse != null) {
//         final bool success = response.jsonResponse!['success'] ?? false;
//         final Map<String, dynamic>? data = response.jsonResponse!['data'];
//
//         if (success && data != null) {
//           final List<dynamic> conversations = data['data'] ?? [];
//           users.value = _parseConversations(conversations);
//         } else {
//           Get.snackbar('Error', 'Failed to load conversations');
//         }
//       } else {
//         final String errorMessage = response.jsonResponse?['message'] ??
//             response.errorMessage ?? 'Failed to load conversations';
//         Get.snackbar('Error', errorMessage);
//       }
//     } catch (e) {
//       isLoading.value = false;
//       Get.snackbar('Error', 'An unexpected error occurred');
//     }
//   }
//
//   List<ChatUser> _parseConversations(List<dynamic> conversations) {
//     return conversations.map((conversation) {
//       final String conversationId = conversation['_id'] ?? '';
//       final List<dynamic> usersList = conversation['users'] ?? [];
//       final Map<String, dynamic>? lastMessageData = conversation['lastMessage'];
//
//       // Get the other user in the conversation (assuming 2 users per conversation)
//       final Map<String, dynamic> otherUser = usersList.isNotEmpty ?
//       usersList.firstWhere((user) => true, orElse: () => {}) : {};
//
//       final String userId = otherUser['_id'] ?? '';
//       final String userName = otherUser['name'] ?? 'Unknown User';
//       final String userImage = otherUser['image'] ?? '';
//       final String fullImageUrl = userImage.isNotEmpty ?
//       AppUrl.getUserProfileImageUrl(userImage) : '';
//
//       // Parse last message
//       String lastMessageText = 'No messages yet';
//       String lastMessageTime = '';
//
//       if (lastMessageData != null) {
//         lastMessageText = lastMessageData['text'] ?? 'No messages yet';
//         final String createdAt = lastMessageData['createdAt'] ?? '';
//         lastMessageTime = _formatMessageTime(createdAt);
//       }
//
//       return ChatUser(
//         id: userId,
//         conversationId: conversationId,
//         name: userName,
//         avatar: fullImageUrl,
//         lastMessage: lastMessageText,
//         time: lastMessageTime,
//         isOnline: false, // You might need to get this from another API
//       );
//     }).toList();
//   }
//
//   String _formatMessageTime(String isoTime) {
//     if (isoTime.isEmpty) return '';
//
//     try {
//       final DateTime time = DateTime.parse(isoTime).toLocal();
//       final DateTime now = DateTime.now();
//       final Duration difference = now.difference(time);
//
//       if (difference.inDays == 0) {
//         // Today - show time
//         final String hour = time.hour.toString().padLeft(2, '0');
//         final String minute = time.minute.toString().padLeft(2, '0');
//         return '$hour:$minute';
//       } else if (difference.inDays == 1) {
//         return 'Yesterday';
//       } else if (difference.inDays < 7) {
//         return '${difference.inDays} days ago';
//       } else {
//         return '${time.day}/${time.month}/${time.year}';
//       }
//     } catch (e) {
//       return '';
//     }
//   }
//
//   void selectUser(ChatUser user) {
//     selectedUser.value = user;
//     loadMessages(user.conversationId);
//   }
//
//   void loadMessages(String conversationId) {
//     // TODO: Implement API call to load messages for specific conversation
//     // For now, using sample messages
//     messages.value = <Message>[
//       Message(id: '1', text: 'Hiyyiii!', time: '3:01 pm', isSentByMe: false),
//       Message(
//         id: '2',
//         text: 'when are we meeting its been so longggg since we meeted.',
//         time: '3:01 pm',
//         isSentByMe: true,
//       ),
//     ];
//   }
//
//   void sendMessage(String text) {
//     if (text.trim().isEmpty) return;
//
//     final Message newMessage = Message(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       text: text.trim(),
//       time: _getCurrentTime(),
//       isSentByMe: true,
//     );
//
//     messages.add(newMessage);
//   }
//
//   String _getCurrentTime() {
//     final DateTime now = DateTime.now();
//     final int hour = now.hour > 12 ? now.hour - 12 : now.hour;
//     final String period = now.hour >= 12 ? 'pm' : 'am';
//     return '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period';
//   }
//
//   // Refresh conversations
//   Future<void> refreshConversations() async {
//     await loadConversations();
//   }
// }
//
//
//
// class ChatUser {
//   final String id;
//   final String conversationId;
//   final String name;
//   final String avatar;
//   final String lastMessage;
//   final String time;
//   final bool isOnline;
//
//   ChatUser({
//     required this.id,
//     required this.conversationId,
//     required this.name,
//     required this.avatar,
//     required this.lastMessage,
//     required this.time,
//     required this.isOnline,
//   });
// }








import 'package:get/get.dart';
import 'package:manx_mate/core/network/network_caller.dart';
import 'package:manx_mate/core/network/network_response.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import 'package:manx_mate/core/data/secured_storage.dart';
import 'package:manx_mate/core/config/app_constants.dart';

import '../model/chat_user.dart';
import '../model/message.dart';

class MessageController extends GetxController {
  RxList<ChatUser> users = <ChatUser>[].obs;
  RxList<Message> messages = <Message>[].obs;
  Rx<ChatUser?> selectedUser = Rx<ChatUser?>(null);
  RxBool isLoading = false.obs;
  RxBool isLoadingMessages = false.obs;
  final NetworkCaller _networkCaller = NetworkCaller();
  final SecureStorageService _secureStorage = SecureStorageService();
  String? _currentUserId;

  @override
  void onInit() {
    super.onInit();
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
    // Ensure current user ID is loaded
    if (_currentUserId == null) {
      await _loadCurrentUserId();
    }

    final List<ChatUser> chatUsers = [];

    for (final conversation in conversations) {
      final String conversationId = conversation['_id'] ?? '';
      final List<dynamic> usersList = conversation['users'] ?? [];
      final Map<String, dynamic>? lastMessageData = conversation['lastMessage'];

      // Find the other user in the conversation (not the current user)
      Map<String, dynamic>? otherUser;
      for (final user in usersList) {
        final String userId = user['_id'] ?? '';
        if (userId != _currentUserId) {
          otherUser = user;
          break;
        }
      }

      // If no other user found, use the first user
      if (otherUser == null && usersList.isNotEmpty) {
        otherUser = usersList[0];
      }

      if (otherUser != null) {
        final String userId = otherUser['_id'] ?? '';
        final String userName = otherUser['name'] ?? 'Unknown User';
        final String userImage = otherUser['image'] ?? '';
        final String fullImageUrl = userImage.isNotEmpty ?
        AppUrl.getUserProfileImageUrl(userImage) : '';

        // Parse last message
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
          isOnline: false, // You might need to get this from another API
        ));
      }
    }

    return chatUsers;
  }

  Future<void> loadMessages(String conversationId) async {
    try {
      isLoadingMessages.value = true;
      messages.clear();

      final String? token = await _secureStorage.read(AppConstants.authToken);

      if (token == null || token.isEmpty) {
        Get.snackbar('Error', 'Please login again');
        isLoadingMessages.value = false;
        return;
      }

      final NetworkResponse response = await _networkCaller.getRequest(
        '${AppUrl.baseUrl}/conversation/$conversationId/single',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      isLoadingMessages.value = false;

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
      isLoadingMessages.value = false;
      Get.snackbar('Error', 'An unexpected error occurred while loading messages');
    }
  }

  Future<List<Message>> _parseMessages(List<dynamic> messagesData) async {
    // Ensure current user ID is loaded
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

      // Determine if message is sent by current user
      final bool isSentByMe = authorId == _currentUserId;

      // Get author avatar
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

      // Format time as HH:mm
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

      // TODO: Implement API call to send message
      // For now, add message locally
      final Message newMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text.trim(),
        time: _getCurrentTime(),
        isSentByMe: true,
        authorId: _currentUserId ?? '',
        authorName: await _secureStorage.read(AppConstants.userName) ?? 'You',
        authorAvatar: '',
      );

      messages.insert(0, newMessage);

      // Refresh messages to get the latest from server
      await loadMessages(currentSelectedUser.conversationId);

    } catch (e) {
      Get.snackbar('Error', 'Failed to send message');
    }
  }

  String _getCurrentTime() {
    final DateTime now = DateTime.now();
    final String hour = now.hour.toString().padLeft(2, '0');
    final String minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Refresh conversations
  Future<void> refreshConversations() async {
    await loadConversations();
  }

  // Refresh messages for current conversation
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