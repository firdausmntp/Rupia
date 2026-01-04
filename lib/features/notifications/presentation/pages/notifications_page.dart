import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/date_formatter.dart';

// Notification model
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final NotificationType type;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.type,
    this.isRead = false,
  });
}

enum NotificationType {
  budget,
  reminder,
  achievement,
  system,
}

// Notifications provider
final notificationsProvider = StateProvider<List<NotificationItem>>((ref) {
  // Sample notifications - in production, this would come from a service
  return [
    NotificationItem(
      id: '1',
      title: 'Budget Warning',
      message: 'Pengeluaran kategori Makanan sudah mencapai 80% dari budget bulanan.',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.budget,
    ),
    NotificationItem(
      id: '2',
      title: 'Pengingat Tagihan',
      message: 'Tagihan listrik akan jatuh tempo dalam 3 hari.',
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.reminder,
    ),
    NotificationItem(
      id: '3',
      title: 'Achievement Unlocked! 🏆',
      message: 'Selamat! Anda sudah mencatat 100 transaksi.',
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.achievement,
    ),
    NotificationItem(
      id: '4',
      title: 'Backup Berhasil',
      message: 'Data Anda sudah berhasil di-backup ke cloud.',
      date: DateTime.now().subtract(const Duration(days: 3)),
      type: NotificationType.system,
      isRead: true,
    ),
  ];
});

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final isDark = ref.watch(isDarkModeProvider);
    final isAmoled = ref.watch(isAmoledModeProvider);
    
    final backgroundColor = isAmoled 
        ? AppColors.backgroundAmoled 
        : isDark 
            ? AppColors.backgroundDark 
            : AppColors.background;
    final cardColor = isAmoled 
        ? AppColors.cardBackgroundAmoled 
        : isDark 
            ? AppColors.cardBackgroundDark 
            : Colors.white;
    final textSecondary = isAmoled 
        ? AppColors.textSecondaryAmoled 
        : isDark 
            ? AppColors.textSecondaryDark 
            : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(notificationsProvider.notifier).state = [];
              },
              child: const Text('Hapus Semua'),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: textSecondary.withValues(alpha: 0.5),
                  ),
                  const Gap(16),
                  Text(
                    'Tidak ada notifikasi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textSecondary,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Notifikasi akan muncul di sini',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Gap(14),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationItem(
                  context,
                  notification,
                  cardColor,
                  textSecondary,
                  ref,
                );
              },
            ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationItem notification,
    Color cardColor,
    Color textSecondary,
    WidgetRef ref,
  ) {
    IconData icon;
    Color iconColor;
    
    switch (notification.type) {
      case NotificationType.budget:
        icon = Icons.account_balance_wallet;
        iconColor = AppColors.warning;
        break;
      case NotificationType.reminder:
        icon = Icons.alarm;
        iconColor = AppColors.info;
        break;
      case NotificationType.achievement:
        icon = Icons.emoji_events;
        iconColor = AppColors.income;
        break;
      case NotificationType.system:
        icon = Icons.info_outline;
        iconColor = AppColors.primary;
        break;
    }

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.expense,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        final list = ref.read(notificationsProvider);
        ref.read(notificationsProvider.notifier).state = 
            list.where((n) => n.id != notification.id).toList();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: notification.isRead ? null : Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    notification.message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    DateFormatter.formatRelative(notification.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
