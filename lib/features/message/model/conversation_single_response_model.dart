
class ConversationSingleResponseModel {
  final bool success;
  final int code;
  final String message;
  final ConversationDetailData data;

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
      data: ConversationDetailData.fromJson(json['data'] ?? {}),
    );
  }
}
class ConversationDetailData {
  final ConversationInfo conversation;
  final List<MessageModel> messages;
  final Pagination pagination;

  ConversationDetailData({
    required this.conversation,
    required this.messages,
    required this.pagination,
  });

  factory ConversationDetailData.fromJson(Map<String, dynamic> json) {
    return ConversationDetailData(
      conversation: ConversationInfo.fromJson(json['conversation'] ?? {}),
      messages: (json['messages'] as List<dynamic>? ?? [])
          .map((e) => MessageModel.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}
class ConversationInfo {
  final String id;
  final List<String> users;
  final String type;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String lastMessageId;

  ConversationInfo({
    required this.id,
    required this.users,
    required this.type,
    this.createdAt,
    this.updatedAt,
    required this.lastMessageId,
  });

  factory ConversationInfo.fromJson(Map<String, dynamic> json) {
    return ConversationInfo(
      id: json['_id'] ?? '',
      users: (json['users'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      type: json['type'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      lastMessageId: json['lastMessage'] ?? '',
    );
  }
}
class MessageModel {
  final String id;
  final MessageAuthor author;
  final String conversationId;
  final String text;
  final bool isDeleted;
  final DateTime? createdAt;

  MessageModel({
    required this.id,
    required this.author,
    required this.conversationId,
    required this.text,
    required this.isDeleted,
    this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
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
class Pagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}
