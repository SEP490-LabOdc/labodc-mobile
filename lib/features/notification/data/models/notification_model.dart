import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.notificationRecipientId,
    required super.type,
    required super.title,
    required super.content,
    super.data,
    required super.category,
    required super.priority,
    required super.deepLink,
    required super.sentAt,
    required super.readStatus,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationRecipientId:
      json['notificationRecipientId'] ?? json['id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'])
          : null,
      category: json['category'] ?? '',
      priority: json['priority'] ?? '',
      deepLink: json['deepLink'] ?? '',
      sentAt: DateTime.tryParse(json['sentAt'] ?? '') ?? DateTime.now(),
      readStatus: json['readStatus'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationRecipientId': notificationRecipientId,
      'type': type,
      'title': title,
      'content': content,
      'data': data,
      'category': category,
      'priority': priority,
      'deepLink': deepLink,
      'sentAt': sentAt.toIso8601String(),
      'readStatus': readStatus,
    };
  }
}
