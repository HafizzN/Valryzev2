import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class OvertimeRequestsScreen extends StatefulWidget {
  const OvertimeRequestsScreen({super.key});

  @override
  State<OvertimeRequestsScreen> createState() => _OvertimeRequestsScreenState();
}

class _OvertimeRequestsScreenState extends State<OvertimeRequestsScreen> {
  bool _isLoading = true;
  List<dynamic> _overtimeRequests = [];

  @override
  void initState() {
    super.initState();
    _loadOvertimeRequests();
  }

  Future<void> _loadOvertimeRequests() async {
    setState(() {
      _isLoading = true;
    });

    final result = await ApiService.getOvertimeRequests();

    if (mounted) {
      if (result['success'] == true) {
        setState(() {
          _overtimeRequests = result['overtime_requests'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal memuat riwayat lembur.'),
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

  void _openAddOvertimeForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return const AddOvertimeFormSheet();
      },
    ).then((value) {
      if (value == true) {
        _loadOvertimeRequests();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PENGAJUAN LEMBUR'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadOvertimeRequests,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _overtimeRequests.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                      const Center(
                        child: Text(
                          'Belum ada riwayat pengajuan lembur.',
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20.0),
                    itemCount: _overtimeRequests.length,
                    itemBuilder: (context, index) {
                      final request = _overtimeRequests[index];
                      final status = request['status'] ?? 'pending';
                      final String? rejectionReason = request['rejection_reason'];
                      final String startTime = request['start_time'] ?? '-';
                      final String endTime = request['end_time'] ?? '-';

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
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('TANGGAL LEMBUR', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDate(request['date']),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFF1F5F9),
                                        ),
                                      ),
                                    ],
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
                              
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('WAKTU LEMBUR', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$startTime - $endTime WIB',
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
                                          '${request['total_hours'] ?? 0.0}',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFF1F5F9)),
                                        ),
                                        const Text('JAM', style: TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text('TUGAS / PEKERJAAN LEMBUR', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
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
        onPressed: _openAddOvertimeForm,
        backgroundColor: const Color(0xFFEF4444), // Red color
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AddOvertimeFormSheet extends StatefulWidget {
  const AddOvertimeFormSheet({super.key});

  @override
  State<AddOvertimeFormSheet> createState() => _AddOvertimeFormSheetState();
}

class _AddOvertimeFormSheetState extends State<AddOvertimeFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  
  DateTime? _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isSubmitting = false;

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
      firstDate: now.subtract(const Duration(days: 7)), // Can request backdated overtime up to 7 days
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFEF4444),
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
      });
    }
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 17, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFEF4444),
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
      initialTime: _endTime ?? const TimeOfDay(hour: 21, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFEF4444),
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
        const SnackBar(content: Text('Silakan pilih tanggal kerja lembur.')),
      );
      return;
    }

    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan tentukan jam mulai dan jam selesai lembur.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final String dateStr = DateFormat('yyyy-MM-dd').format(_date!);
    final String startTimeStr = _formatTimeOfDay(_startTime);
    final String endTimeStr = _formatTimeOfDay(_endTime);

    final result = await ApiService.createOvertimeRequest(
      date: dateStr,
      startTime: startTimeStr,
      endTime: endTimeStr,
      reason: _reasonController.text,
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Pengajuan lembur berhasil dikirim.'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
        Navigator.pop(context, true); // Return true to refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal mengirim pengajuan lembur.'),
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
                'BUAT PENGAJUAN LEMBUR',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: Color(0xFFF1F5F9),
                ),
              ),
              const SizedBox(height: 24),

              // 1. Date Picker
              const Text('TANGGAL LEMBUR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
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
                      const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFFEF4444)),
                      const SizedBox(width: 10),
                      Text(
                        _date != null ? DateFormat('dd/MM/yyyy').format(_date!) : 'Pilih Tanggal Lembur',
                        style: TextStyle(
                          fontSize: 12,
                          color: _date != null ? const Color(0xFFF1F5F9) : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Time Pickers Row
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
                                const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFFEF4444)),
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
                                const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFFEF4444)),
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
              const SizedBox(height: 20),

              // 3. Reason Input
              const Text('TUGAS / PEKERJAAN YANG DIKERJAKAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(fontSize: 13, color: Color(0xFFF1F5F9)),
                decoration: InputDecoration(
                  hintText: 'Tuliskan deskripsi tugas yang Anda kerjakan saat lembur...',
                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                  contentPadding: const EdgeInsets.all(16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEF4444)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi tugas lembur harus diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // 4. Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444), // Red color
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
                        'KIRIM PENGAJUAN LEMBUR',
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
