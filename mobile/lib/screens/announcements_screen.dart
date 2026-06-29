import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../widgets/valryze_design.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  bool _isLoading = true;
  List<dynamic> _announcements = [];
  String _roleName = 'karyawan';

  @override
  void initState() {
    super.initState();
    _loadRoleName();
    _loadAnnouncements();
  }

  Future<void> _loadRoleName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _roleName = prefs.getString('role_name') ?? 'karyawan';
      });
    }
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
    });

    final result = await ApiService.getAnnouncements();

    if (mounted) {
      if (result['success'] == true) {
        setState(() {
          _announcements = result['announcements'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal memuat pengumuman.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy HH:mm', 'id_ID').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'info':
        return const Color(0xFF06B6D4); // Cyan
      case 'meeting':
        return const Color(0xFF8B5CF6); // Purple
      case 'holiday':
        return const Color(0xFF10B981); // Emerald
      case 'activity':
        return const Color(0xFFF59E0B); // Amber
      default:
        return const Color(0xFF94A3B8); // Slate
    }
  }

  void _showCreateAnnouncementSheet() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedCategory = 'info';
    bool isPinned = false;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ValryzeDesign.cardBackground(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final style = ValryzeDesign.roleStyle(_roleName);
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'BUAT PENGUMUMAN BARU',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: style.accent,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tulis pengumuman resmi perusahaan yang akan disebarluaskan ke seluruh karyawan.',
                      style: TextStyle(
                        fontSize: 12,
                        color: ValryzeDesign.secondaryText(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Judul Form Field
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: ValryzeDesign.primaryText(context), fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Judul Pengumuman',
                        labelStyle: TextStyle(color: ValryzeDesign.secondaryText(context), fontSize: 12),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.02),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: style.accent, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Kategori Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      dropdownColor: ValryzeDesign.cardBackground(context),
                      style: TextStyle(color: ValryzeDesign.primaryText(context), fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        labelStyle: TextStyle(color: ValryzeDesign.secondaryText(context), fontSize: 12),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.02),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: style.accent, width: 1.5),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'info', child: Text('Informasi')),
                        DropdownMenuItem(value: 'meeting', child: Text('Rapat / Pertemuan')),
                        DropdownMenuItem(value: 'holiday', child: Text('Hari Libur')),
                        DropdownMenuItem(value: 'activity', child: Text('Kegiatan')),
                        DropdownMenuItem(value: 'other', child: Text('Lainnya')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setSheetState(() {
                            selectedCategory = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Konten Pengumuman
                    TextField(
                      controller: contentController,
                      maxLines: 5,
                      style: TextStyle(color: ValryzeDesign.primaryText(context), fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Isi Pengumuman',
                        labelStyle: TextStyle(color: ValryzeDesign.secondaryText(context), fontSize: 12),
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.02),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: style.accent, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Pin Toggle
                    SwitchListTile(
                      value: isPinned,
                      activeColor: style.accent,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Sematkan Pengumuman (Pin to Top)',
                        style: TextStyle(
                          fontSize: 12,
                          color: ValryzeDesign.primaryText(context),
                        ),
                      ),
                      subtitle: Text(
                        'Menampilkan pengumuman ini di baris paling atas.',
                        style: TextStyle(
                          fontSize: 10,
                          color: ValryzeDesign.secondaryText(context),
                        ),
                      ),
                      onChanged: (val) {
                        setSheetState(() {
                          isPinned = val;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Submit Button
                    ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final title = titleController.text.trim();
                              final content = contentController.text.trim();
                              
                              if (title.isEmpty || content.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Judul dan isi pengumuman tidak boleh kosong.'),
                                    backgroundColor: Color(0xFFEF4444),
                                  ),
                                );
                                return;
                              }
                              
                              setSheetState(() {
                                isSubmitting = true;
                              });
                              
                              final result = await ApiService.createAnnouncement(
                                title: title,
                                content: content,
                                category: selectedCategory,
                                isPinned: isPinned,
                              );
                              
                              if (mounted) {
                                if (result['success'] == true) {
                                  Navigator.pop(context); // Close bottom sheet
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Pengumuman berhasil diterbitkan!'),
                                      backgroundColor: Color(0xFF10B981),
                                    ),
                                  );
                                  _loadAnnouncements(); // Refresh list
                                } else {
                                  setSheetState(() {
                                    isSubmitting = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result['message'] ?? 'Gagal membuat pengumuman.'),
                                      backgroundColor: const Color(0xFFEF4444),
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: style.accent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('TERBITKAN PENGUMUMAN'),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canCreate = _roleName == 'hrd' || _roleName == 'manager';
    final roleStyle = ValryzeDesign.roleStyle(_roleName);

    return Scaffold(
      backgroundColor: ValryzeDesign.pageBackground(context),
      appBar: AppBar(
        title: const Text('PENGUMUMAN'),
        backgroundColor: roleStyle.navBg,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton(
              onPressed: _showCreateAnnouncementSheet,
              backgroundColor: roleStyle.accent,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add_rounded),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _loadAnnouncements,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _announcements.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                      Center(
                        child: Text(
                          'Belum ada pengumuman terbaru.',
                          style: TextStyle(color: ValryzeDesign.secondaryText(context)),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20.0),
                    itemCount: _announcements.length,
                    itemBuilder: (context, index) {
                      final announcement = _announcements[index];
                      final bool isPinned = announcement['is_pinned'] ?? false;
                      final String category = announcement['category'] ?? '';
                      final String categoryName = announcement['category_name'] ?? 'Lainnya';

                      return Card(
                        color: ValryzeDesign.cardBackground(context),
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: isPinned
                              ? BorderSide(
                                  color: roleStyle.accent.withOpacity(0.4),
                                  width: 1.5,
                                )
                              : BorderSide(
                                  color: Colors.white.withOpacity(0.06),
                                  width: 1,
                                ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _showAnnouncementDetails(announcement),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Category Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(category).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        categoryName.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: _getCategoryColor(category),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    // Pinned Indicator
                                    if (isPinned) ...[
                                      Icon(
                                        Icons.push_pin_rounded,
                                        size: 14,
                                        color: roleStyle.accent,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'PINNED',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: roleStyle.accent,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  announcement['title'] ?? '-',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: ValryzeDesign.primaryText(context),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  announcement['content'] ?? '-',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: ValryzeDesign.secondaryText(context),
                                    height: 1.4,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(Icons.access_time_rounded, size: 12, color: ValryzeDesign.secondaryText(context)),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDate(announcement['published_at']),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: ValryzeDesign.secondaryText(context),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (announcement['attachment_url'] != null)
                                      Icon(
                                        Icons.attachment_rounded,
                                        size: 14,
                                        color: roleStyle.accent,
                                      ),
                                  ],
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

  void _showAnnouncementDetails(Map<String, dynamic> announcement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ValryzeDesign.cardBackground(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final bool isPinned = announcement['is_pinned'] ?? false;
        final String category = announcement['category'] ?? '';
        final String categoryName = announcement['category_name'] ?? 'Lainnya';
        final String? attachmentUrl = announcement['attachment_url'];
        final roleStyle = ValryzeDesign.roleStyle(_roleName);

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(category).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          categoryName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: _getCategoryColor(category),
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (isPinned) ...[
                        Icon(
                          Icons.push_pin_rounded,
                          size: 14,
                          color: roleStyle.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'PINNED',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: roleStyle.accent,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    announcement['title'] ?? '-',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ValryzeDesign.primaryText(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 12, color: ValryzeDesign.secondaryText(context)),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(announcement['published_at']),
                        style: TextStyle(
                          fontSize: 11,
                          color: ValryzeDesign.secondaryText(context),
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.white.withOpacity(0.08), height: 32),
                  Text(
                    announcement['content'] ?? '-',
                    style: TextStyle(
                      fontSize: 13,
                      color: ValryzeDesign.primaryText(context).withOpacity(0.85),
                      height: 1.6,
                    ),
                  ),
                  if (attachmentUrl != null) ...[
                    const SizedBox(height: 32),
                    Card(
                      color: Colors.white.withOpacity(0.02),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white.withOpacity(0.04), width: 1),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: roleStyle.accent.withOpacity(0.12),
                          child: Icon(Icons.insert_drive_file_rounded, color: roleStyle.accent),
                        ),
                        title: Text(
                          'Lampiran Dokumen',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ValryzeDesign.primaryText(context)),
                        ),
                        subtitle: Text(
                          'Ketuk untuk mengunduh atau membuka lampiran.',
                          style: TextStyle(fontSize: 11, color: ValryzeDesign.secondaryText(context)),
                        ),
                        trailing: Icon(Icons.open_in_new_rounded, size: 16, color: ValryzeDesign.secondaryText(context)),
                        onTap: () async {
                          final uri = Uri.parse(attachmentUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Tidak dapat membuka tautan lampiran.')),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
