import 'package:lokalny_koszyk/domain/models/app_notification_item.dart';

abstract class NotificationsRepository {
  Future<List<AppNotificationItem>> getMyNotifications();

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead();
}
