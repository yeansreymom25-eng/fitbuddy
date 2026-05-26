import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../services/app_notification_service.dart';

class NotificationSheet extends StatefulWidget {
  const NotificationSheet({super.key});

  @override
  State<NotificationSheet> createState() => _NotificationSheetState();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationSheet(),
    );
  }
}

class _NotificationSheetState extends State<NotificationSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<List<AppNotification>>(
              stream: AppNotificationService.instance.watchNotifications(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: _NotificationColors.green,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _buildEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Unable to load notifications',
                    message: 'Please check your connection and try again.',
                  );
                }

                final notifications = snapshot.data ?? [];

                if (notifications.isEmpty) {
                  return _buildEmptyState(
                    icon: Icons.notifications_none_rounded,
                    title: 'No notifications yet',
                    message:
                        'When you receive notifications, they will appear here.',
                  );
                }

                return _buildNotificationList(notifications);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Notifications',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                StreamBuilder<int>(
                  stream: AppNotificationService.instance.watchUnreadCount(),
                  builder: (context, snapshot) {
                    final unreadCount = snapshot.data ?? 0;
                    if (unreadCount == 0) {
                      return const SizedBox.shrink();
                    }
                    return TextButton(
                      onPressed: () async {
                        await AppNotificationService.instance.markAllAsRead();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: _NotificationColors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(0, 36),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      child: const Text('Mark all read'),
                    );
                  },
                ),
                IconButton(
                  onPressed: () => _showClearDialog(),
                  icon: const Icon(Icons.more_vert_rounded),
                  color: _NotificationColors.textGrey,
                  iconSize: 22,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<AppNotification> notifications) {
    // Group notifications by date
    final today = <AppNotification>[];
    final yesterday = <AppNotification>[];
    final older = <AppNotification>[];

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));

    for (final notification in notifications) {
      if (notification.timestamp.isAfter(todayStart)) {
        today.add(notification);
      } else if (notification.timestamp.isAfter(yesterdayStart)) {
        yesterday.add(notification);
      } else {
        older.add(notification);
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (today.isNotEmpty) ...[
          _buildSectionHeader('Today'),
          ...today.map((n) => _buildNotificationItem(n)),
        ],
        if (yesterday.isNotEmpty) ...[
          _buildSectionHeader('Yesterday'),
          ...yesterday.map((n) => _buildNotificationItem(n)),
        ],
        if (older.isNotEmpty) ...[
          _buildSectionHeader('Earlier'),
          ...older.map((n) => _buildNotificationItem(n)),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: _NotificationColors.textGrey,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(AppNotification notification) {
    final style = _getNotificationStyle(notification.type);

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE5E5),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(
          Icons.delete_rounded,
          color: Color(0xFFD62828),
          size: 24,
        ),
      ),
      confirmDismiss: (_) async {
        await AppNotificationService.instance
            .deleteNotification(notification.id);
        return true;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : style.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? const Color(0xFFE8E8E8)
                : style.borderColor,
            width: 1,
          ),
          boxShadow: notification.isRead
              ? null
              : [
                  BoxShadow(
                    color: style.color.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              if (!notification.isRead) {
                await AppNotificationService.instance
                    .markAsRead(notification.id);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: style.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      style.icon,
                      color: style.color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: notification.isRead
                                      ? FontWeight.w700
                                      : FontWeight.w900,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: style.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: TextStyle(
                            color: _NotificationColors.textGrey,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: _NotificationColors.textGrey
                                  .withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              notification.timeAgo,
                              style: TextStyle(
                                color: _NotificationColors.textGrey
                                    .withValues(alpha: 0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _NotificationColors.softGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: _NotificationColors.green,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _NotificationColors.textGrey,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showClearDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Clear all notifications?',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'This will permanently delete all your notifications.',
          style: TextStyle(
            color: _NotificationColors.textGrey,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFD62828),
            ),
            child: const Text(
              'Clear All',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AppNotificationService.instance.clearAllNotifications();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  _NotificationStyle _getNotificationStyle(NotificationType type) {
    switch (type) {
      case NotificationType.reminder:
        return const _NotificationStyle(
          icon: Icons.notifications_active_rounded,
          color: _NotificationColors.blue,
          backgroundColor: Color(0xFFF0F7FF),
          borderColor: Color(0xFFD6E9FF),
        );
      case NotificationType.achievement:
        return const _NotificationStyle(
          icon: Icons.emoji_events_rounded,
          color: _NotificationColors.orange,
          backgroundColor: Color(0xFFFFF8F0),
          borderColor: Color(0xFFFFE8D1),
        );
      case NotificationType.motivation:
        return const _NotificationStyle(
          icon: Icons.auto_awesome_rounded,
          color: _NotificationColors.purple,
          backgroundColor: Color(0xFFF8F4FF),
          borderColor: Color(0xFFE8DBFF),
        );
      case NotificationType.mealPlan:
        return const _NotificationStyle(
          icon: Icons.restaurant_menu_rounded,
          color: _NotificationColors.green,
          backgroundColor: Color(0xFFF0FBF6),
          borderColor: Color(0xFFD6F3E5),
        );
      case NotificationType.progress:
        return const _NotificationStyle(
          icon: Icons.trending_up_rounded,
          color: _NotificationColors.teal,
          backgroundColor: Color(0xFFF0FDFB),
          borderColor: Color(0xFFD1F5EF),
        );
      case NotificationType.system:
        return const _NotificationStyle(
          icon: Icons.info_rounded,
          color: _NotificationColors.grey,
          backgroundColor: Color(0xFFF5F5F5),
          borderColor: Color(0xFFE0E0E0),
        );
    }
  }
}

class _NotificationStyle {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;

  const _NotificationStyle({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
  });
}

class _NotificationColors {
  static const green = Color(0xFF1F8A5B);
  static const softGreen = Color(0xFFE7F6EE);
  static const blue = Color(0xFF2B7FFF);
  static const purple = Color(0xFF7B4CE0);
  static const orange = Color(0xFFE8862E);
  static const teal = Color(0xFF14B8A6);
  static const grey = Color(0xFF6B7280);
  static const textGrey = Color(0xFF66736B);

  const _NotificationColors._();
}
