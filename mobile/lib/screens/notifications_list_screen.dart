import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NotificationsListScreen extends StatefulWidget {
  const NotificationsListScreen({super.key});

  @override
  State<NotificationsListScreen> createState() => _NotificationsListScreenState();
}

class _NotificationsListScreenState extends State<NotificationsListScreen> {
  bool _isLoading = true;
  List<dynamic> _notifications = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await ApiService.getNotifications();

    if (!mounted) return;

    if (response['success'] == true) {
      setState(() {
        _notifications = response['notifications'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response['message'] ?? 'Gagal memuat notifikasi.';
        _isLoading = false;
      });
    }
  }

  Future<void> _markRead(int id) async {
    final response = await ApiService.readNotification(id);
    if (response['success'] == true) {
      _fetchNotifications();
    }
  }

  Future<void> _markAllRead() async {
    final response = await ApiService.readAllNotifications();
    if (response['success'] == true) {
      _fetchNotifications();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua notifikasi ditandai dibaca!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'leave':
        return Icons.flight_takeoff_rounded;
      case 'attendance':
        return Icons.alarm_rounded;
      case 'overtime':
        return Icons.work_history_rounded;
      case 'system':
        return Icons.dns_rounded;
      case 'document':
        return Icons.description_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'leave':
        return const Color(0xFF8B5CF6); // Purple
      case 'attendance':
        return const Color(0xFFF59E0B); // Amber
      case 'overtime':
        return const Color(0xFF0EA5E9); // Cyan
      case 'system':
        return const Color(0xFF10B981); // Emerald
      case 'document':
        return const Color(0xFFA78BFA); // Light Purple
      default:
        return const Color(0xFF06B6D4); // VALRYZE Cyan
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => n['read_at'] == null).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NOTIFIKASI & PENGINGAT'),
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all_rounded, color: Color(0xFF10B981)),
              tooltip: 'Tandai Semua Dibaca',
              onPressed: _markAllRead,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Reminder Banner Card
                  _buildDailyReminderCard(),

                  Expanded(
                    child: _errorMessage != null
                        ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                        : _notifications.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _notifications.length,
                                itemBuilder: (context, index) {
                                  final notif = _notifications[index];
                                  final bool isUnread = notif['read_at'] == null;
                                  final String type = notif['type'] ?? 'info';
                                  final int id = notif['id'];

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: InkWell(
                                      onTap: () {
                                        if (isUnread) {
                                          _markRead(id);
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Icon indicator
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundColor: _getColorForType(type).withOpacity(0.12),
                                              child: Icon(
                                                _getIconForType(type),
                                                color: _getColorForType(type),
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            
                                            // Notification text
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          notif['title'] ?? 'Notifikasi Baru',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                                                            color: isUnread ? Colors.white : const Color(0xFF94A3B8),
                                                          ),
                                                        ),
                                                      ),
                                                      if (isUnread)
                                                        Container(
                                                          width: 8,
                                                          height: 8,
                                                          decoration: const BoxDecoration(
                                                            color: Color(0xFF06B6D4), // Cyan unread dot
                                                            shape: BoxShape.circle,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    notif['message'] ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFFCBD5E1),
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    _formatTime(notif['created_at']),
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Color(0xFF64748B),
                                                      fontWeight: FontWeight.w500,
                                                    ),
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
                ],
              ),
      ),
    );
  }

  Widget _buildDailyReminderCard() {
    final now = DateTime.now();
    String reminderText = 'Semoga hari Anda menyenangkan! Jangan lupa lakukan check-in harian sebelum toleransi waktu shift berakhir.';
    IconData reminderIcon = Icons.wb_sunny_rounded;
    Color iconColor = const Color(0xFFF59E0B);

    if (now.hour >= 16) {
      reminderText = 'Shift kerja Anda akan segera selesai. Pastikan Anda melakukan check-out absensi sebelum meninggalkan kantor!';
      reminderIcon = Icons.home_rounded;
      iconColor = const Color(0xFF10B981);
    }

    return Card(
      margin: const EdgeInsets.all(16),
      color: const Color(0xFF06B6D4).withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(reminderIcon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PENGINGAT MANDIRI',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF06B6D4),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reminderText,
                    style: const TextStyle(fontSize: 11, color: Color(0xFFCBD5E1), height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white.withOpacity(0.04),
            child: const Icon(Icons.notifications_none_rounded, size: 36, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak Ada Notifikasi',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 6),
          const Text(
            'Semua pemberitahuan dan pengingat Anda akan muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '';
    try {
      final dt = DateTime.parse(dateTimeStr).toLocal();
      final now = DateTime.now();
      
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return 'Hari ini, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
      
      final yesterday = now.subtract(const Duration(days: 1));
      if (dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day) {
        return 'Kemarin, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }

      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
