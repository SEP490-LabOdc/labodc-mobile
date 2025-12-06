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
    super.deepLink,
    required super.sentAt,
    required super.readStatus,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      // [SAFE PARSE] Sử dụng toString() và null check để tránh crash
      notificationRecipientId: json['notificationRecipientId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'GENERAL',
      title: json['title']?.toString() ?? 'Thông báo',
      content: json['content']?.toString() ?? '',

      // Xử lý data map an toàn
      data: json['data'] is Map<String, dynamic> ? json['data'] : null,

      category: json['category']?.toString() ?? 'SYSTEM',
      priority: json['priority']?.toString() ?? 'LOW',
      deepLink: json['deepLink']?.toString(),

      // [DATE FIX] DateTime.tryParse an toàn hơn
      sentAt: json['sentAt'] != null
          ? DateTime.tryParse(json['sentAt'].toString()) ?? DateTime.now()
          : DateTime.now(),

      // Xử lý boolean an toàn
      readStatus: json['readStatus'] == true,
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