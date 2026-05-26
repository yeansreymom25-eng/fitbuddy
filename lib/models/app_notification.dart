import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  reminder,
  achievement,
  motivation,
  mealPlan,
  progress,
  system,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'type': type.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      if (data != null) 'data': data,
    };
  }

  factory AppNotification.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    final timestampValue = data['timestamp'];
    final typeString = data['type'] as String? ?? 'system';

    return AppNotification(
      id: snapshot.id,
      title: (data['title'] as String?) ?? 'Notification',
      message: (data['message'] as String?) ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == typeString,
        orElse: () => NotificationType.system,
      ),
      timestamp: timestampValue is Timestamp
          ? timestampValue.toDate()
          : DateTime.now(),
      isRead: (data['isRead'] as bool?) ?? false,
      data: data['data'] as Map<String, dynamic>?,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}
