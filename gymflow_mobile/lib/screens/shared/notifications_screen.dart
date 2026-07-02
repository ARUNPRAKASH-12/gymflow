import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _api = ApiService();
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final result = await _api.getNotifications();
      setState(() => _notifications = result['notifications'] ?? []);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markRead(String id) async {
    await _api.markNotificationRead(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => n['is_read'] != true).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: GymFlowColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$unreadCount new', style: const TextStyle(fontSize: 12, color: Colors.white)),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: GymFlowColors.textMuted),
                      const SizedBox(height: 16),
                      Text('No notifications', style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (c, i) {
                      final n = _notifications[i];
                      final isRead = n['is_read'] == true;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: isRead ? null : GymFlowColors.surfaceLight,
                        child: InkWell(
                          onTap: () {
                            if (!isRead) _markRead(n['id']);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _typeColor(n['type']).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(_typeIcon(n['type']), color: _typeColor(n['type']), size: 20),
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
                                              n['title'] ?? '',
                                              style: TextStyle(
                                                fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                                                color: isRead ? GymFlowColors.textSecondary : GymFlowColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                          if (!isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: GymFlowColors.primary,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(n['body'] ?? '', style: Theme.of(context).textTheme.bodySmall),
                                      const SizedBox(height: 4),
                                      Text(
                                        n['created_at']?.toString().substring(0, 16) ?? '',
                                        style: TextStyle(fontSize: 11, color: GymFlowColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Color _typeColor(String? type) {
    switch (type) {
      case 'membership_expiry':
        return GymFlowColors.warning;
      case 'payment_reminder':
        return GymFlowColors.error;
      case 'workout':
        return GymFlowColors.success;
      case 'promotional':
        return GymFlowColors.secondary;
      default:
        return GymFlowColors.info;
    }
  }

  IconData _typeIcon(String? type) {
    switch (type) {
      case 'membership_expiry':
        return Icons.timer;
      case 'payment_reminder':
        return Icons.payment;
      case 'workout':
        return Icons.fitness_center;
      case 'promotional':
        return Icons.campaign;
      default:
        return Icons.notifications;
    }
  }
}
