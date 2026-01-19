
class ConversationAllListResponseModel {
  final bool success;
  final int code;
  final String message;
  final List<ConversationModel> data;

  ConversationAllListResponseModel({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
  });

  factory ConversationAllListResponseModel.fromJson(Map<String, dynamic> json) {
    return ConversationAllListResponseModel(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => ConversationModel.fromJson(e))
          .toList(),
    );
  }
}


class ConversationSingleResponseModel {
  final bool success;
  final int code;
  final String message;
  final ConversationModel data;

  ConversationSingleResponseModel({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
  });

  factory ConversationSingleResponseModel.fromJson(Map<String, dynamic> json) {
    return ConversationSingleResponseModel(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: ConversationModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}


class ConversationModel {
  final String id;
  final List<ConversationUser> users;
  final String type;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final LastMessage? lastMessage;

  ConversationModel({
    required this.id,
    required this.users,
    required this.type,
    this.createdAt,
    this.updatedAt,
    this.lastMessage,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['_id'] ?? '',
      users: (json['users'] as List<dynamic>? ?? [])
          .map((e) => ConversationUser.fromJson(e))
          .toList(),
      type: json['type'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      lastMessage: json['lastMessage'] != null
          ? LastMessage.fromJson(json['lastMessage'])
          : null,
    );
  }
}
class ConversationUser {
  final String id;
  final String name;
  final String image;

  ConversationUser({
    required this.id,
    required this.name,
    required this.image,
  });

  factory ConversationUser.fromJson(Map<String, dynamic> json) {
    return ConversationUser(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}
class LastMessage {
  final String id;
  final MessageAuthor author;
  final String conversationId;
  final String text;
  final bool isDeleted;
  final DateTime? createdAt;

  LastMessage({
    required this.id,
    required this.author,
    required this.conversationId,
    required this.text,
    required this.isDeleted,
    this.createdAt,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      id: json['_id'] ?? '',
      author: MessageAuthor.fromJson(json['author'] ?? {}),
      conversationId: json['conversation'] ?? '',
      text: json['text'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}
class MessageAuthor {
  final String id;
  final String name;
  final String image;

  MessageAuthor({
    required this.id,
    required this.name,
    required this.image,
  });

  factory MessageAuthor.fromJson(Map<String, dynamic> json) {
    return MessageAuthor(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}
