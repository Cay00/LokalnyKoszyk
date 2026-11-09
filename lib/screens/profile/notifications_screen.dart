import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/domain/models/app_notification_item.dart';
import 'package:lokalny_koszyk/domain/repositories/notifications_repository.dart';
import 'package:lokalny_koszyk/presentation/orders_bloc.dart';
import 'package:lokalny_koszyk/widgets/common/default_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = true;
  String? _error;
  List<AppNotificationItem> _items = const <AppNotificationItem>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items =
          await context.read<NotificationsRepository>().getMyNotifications();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    try {
      await context.read<NotificationsRepository>().markAllAsRead();
      await _load();
    } catch (_) {}
  }

  Future<void> _onTap(AppNotificationItem item) async {
    if (!item.isRead) {
      try {
        await context.read<NotificationsRepository>().markAsRead(item.id);
        if (!mounted) return;
        setState(() {
          _items = _items
              .map(
                (AppNotificationItem n) => n.id == item.id
                    ? AppNotificationItem(
                        id: n.id,
                        type: n.type,
                        title: n.title,
                        body: n.body,
                        isRead: true,
                        createdAt: n.createdAt,
                        orderId: n.orderId,
                      )
                    : n,
              )
              .toList();
        });
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = _items.any((AppNotificationItem n) => !n.isRead);
    return DefaultScreen(
      title: 'Powiadomienia',
      onBack: widget.onBack,
      actions: hasUnread
          ? <Widget>[
              TextButton(
                onPressed: _markAllRead,
                child: const Text('Przeczytane'),
              ),
            ]
          : const <Widget>[],
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: DefaultScreen.bodyPadding(context),
          children: <Widget>[
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Text(_error!, style: AppTypography.normal)
            else if (_items.isEmpty)
              Text(
                'Nie masz jeszcze żadnych powiadomień.',
                style: AppTypography.normal,
              )
            else
              for (final AppNotificationItem item in _items)
                _NotificationTile(
                  item: item,
                  onTap: () => _onTap(item),
                ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.onTap,
  });

  final AppNotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: item.isRead ? AppColors.white : const Color(0xFFF7FBEA),
        borderRadius: BorderRadius.circular(AppRadius.normal),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.normal),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.normal),
              border: Border.all(color: AppColors.background),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(item.title, style: AppTypography.normalBold),
                    ),
                    Text(
                      formatOrderDate(item.createdAt),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item.body, style: AppTypography.normal),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
