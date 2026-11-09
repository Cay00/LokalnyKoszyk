import 'package:lokalny_koszyk/domain/models/app_notification_item.dart';
import 'package:lokalny_koszyk/domain/repositories/notifications_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseNotificationsRepository implements NotificationsRepository {
  const SupabaseNotificationsRepository(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<List<AppNotificationItem>> getMyNotifications() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw StateError('Brak zalogowanego użytkownika.');
    }

    final rows = await _supabase
        .from('notifications')
        .select('id, type, title, body, is_read, created_at, order_id')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(100);

    return (rows as List<dynamic>).map<AppNotificationItem>((dynamic row) {
      final map = Map<String, dynamic>.from(row as Map);
      return AppNotificationItem(
        id: (map['id'] ?? '').toString(),
        type: (map['type'] ?? '').toString(),
        title: (map['title'] ?? '').toString(),
        body: (map['body'] ?? '').toString(),
        isRead: map['is_read'] == true,
        createdAt: DateTime.tryParse((map['created_at'] ?? '').toString()),
        orderId: map['order_id']?.toString(),
      );
    }).toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final id = notificationId.trim();
    if (id.isEmpty) return;
    await _supabase
        .from('notifications')
        .update(<String, dynamic>{'is_read': true})
        .eq('id', id);
  }

  @override
  Future<void> markAllAsRead() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) return;
    await _supabase
        .from('notifications')
        .update(<String, dynamic>{'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }
}