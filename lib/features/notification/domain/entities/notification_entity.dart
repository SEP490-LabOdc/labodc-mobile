// lib/features/notification/domain/entities/notification_entity.dart
class NotificationEntity {
  final String id; // notificationRecipientId
  final String type;
  final String title;
  final String content;
  final String deepLink;
  final DateTime sentAt;
  final bool readStatus;
  final Map<String, dynamic> extraData; // Trường 'data'

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.deepLink,
    required this.sentAt,
    required this.readStatus,
    this.extraData = const {},
  });

  NotificationEntity copyWith({
    bool? readStatus,
  }) {
    return NotificationEntity(
      id: id,
      type: type,
      title: title,
      content: content,
      deepLink: deepLink,
      sentAt: sentAt,
      readStatus: readStatus ?? this.readStatus,
      extraData: extraData,
    );
  }
}