// lib/features/notification/data/models/notification_model.dart

import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.type,
    required super.title,
    required super.content,
    required super.deepLink,
    required super.sentAt,
    required super.readStatus,
    super.extraData,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>;
    if (dataList.isEmpty) {
      throw const FormatException("Không tìm thấy dữ liệu thông báo trong response.");
    }

    final data = dataList.first as Map<String, dynamic>;
    return NotificationModel(
      id: json['notificationRecipientId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      deepLink: json['deepLink'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      readStatus: json['readStatus'] as bool,
      extraData: (json['data'] as Map<String, dynamic>?) ?? {},
    );
  }
}