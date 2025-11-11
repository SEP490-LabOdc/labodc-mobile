import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String notificationRecipientId;
  final String? type;
  final String title;
  final String content;
  final Map<String, dynamic>? data;
  final String? category;
  final String? priority;
  final String? deepLink;
  final DateTime sentAt;
  final bool readStatus;

  const NotificationEntity({
    required this.notificationRecipientId,
    this.type,
    required this.title,
    required this.content,
    this.data,
    this.category,
    this.priority,
    this.deepLink,
    required this.sentAt,
    required this.readStatus,
  });

  @override
  List<Object?> get props => [
        notificationRecipientId,
        type,
        title,
        content,
        data,
        category,
        priority,
        deepLink,
        sentAt,
        readStatus,
      ];

  NotificationEntity copyWith({
    String? notificationRecipientId,
    String? type,
    String? title,
    String? content,
    Map<String, dynamic>? data,
    String? category,
    String? priority,
    String? deepLink,
    DateTime? sentAt,
    bool? readStatus,
  }) {
    return NotificationEntity(
      notificationRecipientId:
          notificationRecipientId ?? this.notificationRecipientId,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      data: data ?? this.data,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      deepLink: deepLink ?? this.deepLink,
      sentAt: sentAt ?? this.sentAt,
      readStatus: readStatus ?? this.readStatus,
    );
  }
}
