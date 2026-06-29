import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class PermissionRequestsScreen extends StatefulWidget {
  const PermissionRequestsScreen({super.key});

  @override
  State<PermissionRequestsScreen> createState() => _PermissionRequestsScreenState();
}

class _PermissionRequestsScreenState extends State<PermissionRequestsScreen> {
  bool _isLoading = true;
  List<dynamic> _permissionRequests = [];

  @override
  void initState() {
    super.initState();
    _loadPermissionRequests();
  }

  Future<void> _loadPermissionRequests() async {
    setState(() {
      _isLoading = true;
    });

    final result = await ApiService.getPermissionRequests();

    if (mounted) {
      if (result['success'] == true) {
        setState(() {
          _permissionRequests = result['permission_requests'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal memuat riwayat izin.'),
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
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy HH:mm', 'id_ID').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return const Color(0xFF10B981); // Emerald (Approved)
      case 'rejected':
        return const Color(0xFFEF4444); // Red (Rejected)
      default:
        return const Color(0xFFF59E0B); // Amber (Pending)
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Menunggu';
    }
  }

  void _openAddPermissionForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return const AddPermissionFormSheet();
      },
    ).then((value) {
      if (value == true) {
        _loadPermissionRequests();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PENGAJUAN IZIN & SAKIT'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPermissionRequests,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _permissionRequests.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                      const Center(
                        child: Text(
                          'Belum ada riwayat pengajuan izin/sakit.',
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20.0),
                    itemCount: _permissionRequests.length,
                    itemBuilder: (context, index) {
                      final request = _permissionRequests[index];
                      final status = request['status'] ?? 'pending';
                      final typeName = request['permission_type_name'] ?? 'Izin';
                      final String? rejectionReason = request['rejection_reason'];
                      final String? startTime = request['start_time'];
                      final String? endTime = request['end_time'];
                      final String? endDate = request['end_date'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.white.withOpacity(0.06), width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    typeName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFF1F5F9),
                                    ),
                                  ),
                                  const Spacer(),
                                  // Status Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _getStatusText(status).toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(status),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: Color(0xFF1E293B), height: 24),
                              
                              // Dates and Times
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('TANGGAL / WAKTU', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                                        const SizedBox(height: 4),
                                        Text(
                                          endDate != null && endDate != request['date']
                                              ? '${_formatDate(request['date'])} - ${_formatDate(endDate)}'
                                              : _formatDate(request['date']),
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
                                        ),
                                        if (startTime != null && endTime != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            'Jam: $startTime - $endTime WIB',
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text('KETERANGAN / ALASAN', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                              const SizedBox(height: 4),
                              Text(
                                request['reason'] ?? '-',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                              ),
                              
                              if (rejectionReason != null && rejectionReason.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444).withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.15)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.error_outline_rounded, size: 14, color: Color(0xFFF87171)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Alasan Penolakan:',
                                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF87171)),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              rejectionReason,
                                              style: const TextStyle(fontSize: 11, color: Color(0xFFFCA5A5)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 10, color: Color(0xFF475569)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Diajukan pada: ${_formatDateTime(request['created_at'])}',
                                    style: const TextStyle(fontSize: 9, color: Color(0xFF475569)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddPermissionForm,
        backgroundColor: const Color(0xFF8B5CF6), // Purple color
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AddPermissionFormSheet extends StatefulWidget {
  const AddPermissionFormSheet({super.key});

  @override
  State<AddPermissionFormSheet> createState() => _AddPermissionFormSheetState();
}

class _AddPermissionFormSheetState extends State<AddPermissionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  
  String _selectedPermissionType = 'sick';
  DateTime? _date;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  
  bool _isMultiDay = false;
  bool _isPartialHours = false;

  File? _attachmentFile;
  String? _attachmentName;
  bool _isSubmitting = false;

  final Map<String, String> _permissionTypes = {
    'sick': 'Sakit / Kurang Sehat',
    'family': 'Keperluan Keluarga Mendesak',
    'field_duty': 'Dinas Luar / Tugas Kantor',
    'personal': 'Izin Pribadi Lainnya',
  };

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8B5CF6),
              onPrimary: Colors.white,
              surface: Color(0xFF0F172A),
              onSurface: Color(0xFFF1F5F9),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _date = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih tanggal mulai terlebih dahulu.')),
      );
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _date!,
      firstDate: _date!,
      lastDate: _date!.add(const Duration(days: 14)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8B5CF6),
              onPrimary: Colors.white,
              surface: Color(0xFF0F172A),
              onSurface: Color(0xFFF1F5F9),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 8, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8B5CF6),
              onPrimary: Colors.white,
              surface: Color(0xFF0F172A),
              onSurface: Color(0xFFF1F5F9),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? const TimeOfDay(hour: 17, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8B5CF6),
              onPrimary: Colors.white,
              surface: Color(0xFF0F172A),
              onSurface: Color(0xFFF1F5F9),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _pickAttachment() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1200,
      );

      if (image != null) {
        setState(() {
          _attachmentFile = File(image.path);
          _attachmentName = image.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: $e')),
      );
    }
  }

  void _clearAttachment() {
    setState(() {
      _attachmentFile = null;
      _attachmentName = null;
    });
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih tanggal pengajuan izin.')),
      );
      return;
    }

    if (_isMultiDay && _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih tanggal selesai izin.')),
      );
      return;
    }

    if (_isPartialHours && (_startTime == null || _endTime == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan tentukan jam mulai dan jam selesai izin.')),
      );
      return;
    }

    // Sick leave should ideally have an attachment (but not strictly enforced on backend unless desired)
    if (_selectedPermissionType == 'sick' && _attachmentFile == null) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tanpa Lampiran?'),
          content: const Text('Anda mengajukan izin sakit tanpa melampirkan Surat Dokter. Pengajuan tetap dapat dikirim, namun disarankan melampirkan dokumen pendukung.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Kirim Saja', style: TextStyle(color: Color(0xFF8B5CF6))),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final String dateStr = DateFormat('yyyy-MM-dd').format(_date!);
    final String? endDateStr = _isMultiDay && _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : null;
    final String? startTimeStr = _isPartialHours ? _formatTimeOfDay(_startTime) : null;
    final String? endTimeStr = _isPartialHours ? _formatTimeOfDay(_endTime) : null;

    final result = await ApiService.createPermissionRequest(
      permissionType: _selectedPermissionType,
      date: dateStr,
      endDate: endDateStr,
      startTime: startTimeStr,
      endTime: endTimeStr,
      reason: _reasonController.text,
      attachmentPath: _attachmentFile?.path,
      attachmentName: _attachmentName,
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Pengajuan izin berhasil dikirim.'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
        Navigator.pop(context, true); // Return true to refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal mengirim pengajuan izin.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final paddingBottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + paddingBottom),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pull Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'BUAT PENGAJUAN IZIN / SAKIT',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: Color(0xFFF1F5F9),
                ),
              ),
              const SizedBox(height: 24),

              // 1. Permission Type Dropdown
              const Text('JENIS IZIN / KETERANGAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPermissionType,
                dropdownColor: const Color(0xFF0F172A),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
                  ),
                ),
                items: _permissionTypes.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value, style: const TextStyle(fontSize: 13, color: Color(0xFFF1F5F9))),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedPermissionType = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // 2. Multi-day and Partial-hour Switches
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _isMultiDay,
                activeColor: const Color(0xFF8B5CF6),
                title: const Text('Izin lebih dari 1 hari', style: TextStyle(fontSize: 12, color: Color(0xFFE2E8F0))),
                onChanged: (val) {
                  setState(() {
                    _isMultiDay = val ?? false;
                    if (!_isMultiDay) _endDate = null;
                  });
                },
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _isPartialHours,
                activeColor: const Color(0xFF8B5CF6),
                title: const Text('Izin sebagian jam kerja (tidak penuh seharian)', style: TextStyle(fontSize: 12, color: Color(0xFFE2E8F0))),
                onChanged: (val) {
                  setState(() {
                    _isPartialHours = val ?? false;
                    if (!_isPartialHours) {
                      _startTime = null;
                      _endTime = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 12),

              // 3. Date Picker(s)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_isMultiDay ? 'TANGGAL MULAI' : 'TANGGAL', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _selectDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF8B5CF6)),
                                const SizedBox(width: 10),
                                Text(
                                  _date != null ? DateFormat('dd/MM/yyyy').format(_date!) : 'Pilih Tanggal',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _date != null ? const Color(0xFFF1F5F9) : const Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isMultiDay) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TANGGAL SELESAI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _selectEndDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.08)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF8B5CF6)),
                                  const SizedBox(width: 10),
                                  Text(
                                    _endDate != null ? DateFormat('dd/MM/yyyy').format(_endDate!) : 'Pilih Tanggal',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _endDate != null ? const Color(0xFFF1F5F9) : const Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              // 4. Time Pickers (if partial hours)
              if (_isPartialHours) ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('JAM MULAI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _selectStartTime,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.08)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF8B5CF6)),
                                  const SizedBox(width: 10),
                                  Text(
                                    _startTime != null ? _formatTimeOfDay(_startTime) : 'Mulai',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _startTime != null ? const Color(0xFFF1F5F9) : const Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('JAM SELESAI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _selectEndTime,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.08)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF8B5CF6)),
                                  const SizedBox(width: 10),
                                  Text(
                                    _endTime != null ? _formatTimeOfDay(_endTime) : 'Selesai',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _endTime != null ? const Color(0xFFF1F5F9) : const Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // 5. Reason Input
              const Text('KETERANGAN / ALASAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(fontSize: 13, color: Color(0xFFF1F5F9)),
                decoration: InputDecoration(
                  hintText: 'Tuliskan alasan lengkap pengajuan izin/sakit Anda...',
                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                  contentPadding: const EdgeInsets.all(16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Alasan pengajuan izin harus diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 6. Attachment Picker
              const Text('SURAT DOKUMEN / FOTO BUKTI (OPSIONAL)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              const SizedBox(height: 8),
              if (_attachmentFile != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _attachmentFile!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _attachmentName ?? 'Gambar dipilih',
                          style: const TextStyle(fontSize: 12, color: Color(0xFFE2E8F0)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: _clearAttachment,
                        icon: const Icon(Icons.cancel_rounded, size: 18, color: Color(0xFFEF4444)),
                        tooltip: 'Hapus lampiran',
                      ),
                    ],
                  ),
                )
              else
                OutlinedButton.icon(
                  onPressed: _pickAttachment,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: Colors.white.withOpacity(0.08)),
                  ),
                  icon: const Icon(Icons.add_photo_alternate_rounded, size: 18, color: Color(0xFF94A3B8)),
                  label: const Text('Pilih Foto Lampiran / Surat Dokter', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                ),
              const SizedBox(height: 32),

              // 7. Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6), // Purple color
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'KIRIM PENGAJUAN IZIN',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
