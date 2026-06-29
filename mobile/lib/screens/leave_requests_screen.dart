import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class LeaveRequestsScreen extends StatefulWidget {
  const LeaveRequestsScreen({super.key});

  @override
  State<LeaveRequestsScreen> createState() => _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends State<LeaveRequestsScreen> {
  bool _isLoading = true;
  List<dynamic> _leaveRequests = [];

  @override
  void initState() {
    super.initState();
    _loadLeaveRequests();
  }

  Future<void> _loadLeaveRequests() async {
    setState(() {
      _isLoading = true;
    });

    final result = await ApiService.getLeaveRequests();

    if (mounted) {
      if (result['success'] == true) {
        setState(() {
          _leaveRequests = result['leave_requests'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal memuat riwayat cuti.'),
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
      case 'approved_manager':
        return const Color(0xFF6366F1); // Indigo (Approved by Manager)
      case 'rejected':
        return const Color(0xFFEF4444); // Red (Rejected)
      default:
        return const Color(0xFFF59E0B); // Amber (Pending)
    }
  }

  void _openAddLeaveForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return const AddLeaveFormSheet();
      },
    ).then((value) {
      if (value == true) {
        _loadLeaveRequests();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PENGAJUAN CUTI'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadLeaveRequests,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _leaveRequests.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                      const Center(
                        child: Text(
                          'Belum ada riwayat pengajuan cuti.',
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20.0),
                    itemCount: _leaveRequests.length,
                    itemBuilder: (context, index) {
                      final request = _leaveRequests[index];
                      final status = request['status'] ?? 'pending';
                      final statusName = request['status_name'] ?? 'Menunggu';
                      final leaveTypeName = request['leave_type_name'] ?? 'Cuti';
                      final String? rejectionReason = request['rejection_reason'];

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
                                    leaveTypeName,
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
                                      statusName.toUpperCase(),
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
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('TANGGAL', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${_formatDate(request['start_date'])} - ${_formatDate(request['end_date'])}',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E293B),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          '${request['total_days'] ?? 0}',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFF1F5F9)),
                                        ),
                                        const Text('HARI', style: TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text('ALASAN', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
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
        onPressed: _openAddLeaveForm,
        backgroundColor: const Color(0xFFF59E0B), // Amber color
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AddLeaveFormSheet extends StatefulWidget {
  const AddLeaveFormSheet({super.key});

  @override
  State<AddLeaveFormSheet> createState() => _AddLeaveFormSheetState();
}

class _AddLeaveFormSheetState extends State<AddLeaveFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  
  String _selectedLeaveType = 'annual';
  DateTime? _startDate;
  DateTime? _endDate;
  
  File? _attachmentFile;
  String? _attachmentName;
  bool _isSubmitting = false;

  final Map<String, String> _leaveTypes = {
    'annual': 'Cuti Tahunan',
    'sick': 'Cuti Sakit',
    'maternity': 'Cuti Melahirkan',
    'paternity': 'Cuti Ayah',
    'wedding': 'Cuti Menikah',
    'big_leave': 'Cuti Besar',
    'other': 'Cuti Lainnya',
  };

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFF59E0B),
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
        _startDate = picked;
        // If end date is before new start date, reset end date
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih tanggal mulai terlebih dahulu.')),
      );
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!,
      firstDate: _startDate!,
      lastDate: _startDate!.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFF59E0B),
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

  Future<void> _pickAttachment() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Compress image
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan tentukan tanggal mulai dan selesai cuti.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final String startStr = DateFormat('yyyy-MM-dd').format(_startDate!);
    final String endStr = DateFormat('yyyy-MM-dd').format(_endDate!);

    final result = await ApiService.createLeaveRequest(
      leaveType: _selectedLeaveType,
      startDate: startStr,
      endDate: endStr,
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
            content: Text(result['message'] ?? 'Pengajuan cuti berhasil dikirim.'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
        Navigator.pop(context, true); // Return true to refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal mengirim pengajuan cuti.'),
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
                'BUAT PENGAJUAN CUTI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: Color(0xFFF1F5F9),
                ),
              ),
              const SizedBox(height: 24),

              // 1. Leave Type Dropdown
              const Text('JENIS CUTI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedLeaveType,
                dropdownColor: const Color(0xFF0F172A),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF59E0B)),
                  ),
                ),
                items: _leaveTypes.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value, style: const TextStyle(fontSize: 13, color: Color(0xFFF1F5F9))),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedLeaveType = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // 2. Date Pickers Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TANGGAL MULAI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _selectStartDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 10),
                                Text(
                                  _startDate != null ? DateFormat('dd/MM/yyyy').format(_startDate!) : 'Pilih Tanggal',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _startDate != null ? const Color(0xFFF1F5F9) : const Color(0xFF475569),
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
                                const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFFF59E0B)),
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
              ),
              const SizedBox(height: 20),

              // 3. Reason Input
              const Text('ALASAN CUTI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(fontSize: 13, color: Color(0xFFF1F5F9)),
                decoration: InputDecoration(
                  hintText: 'Tuliskan alasan lengkap pengajuan cuti Anda...',
                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                  contentPadding: const EdgeInsets.all(16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF59E0B)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Alasan cuti harus diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 4. Attachment Picker
              const Text('DOKUMEN PENDUKUNG (OPSIONAL)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
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
                  label: const Text('Pilih Foto Lampiran / Surat Keterangan', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                ),
              const SizedBox(height: 32),

              // 5. Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B), // Amber color
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
                        'KIRIM PENGAJUAN CUTI',
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
