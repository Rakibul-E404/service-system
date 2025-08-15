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
