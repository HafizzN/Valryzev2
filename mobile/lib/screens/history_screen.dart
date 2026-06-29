import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _history = [];
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    final monthStr = DateFormat('yyyy-MM').format(_selectedMonth);
    final result = await ApiService.getHistory(monthStr);

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _history = result['history'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal memuat riwayat absensi.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _exportHistory(String format) async {
    final token = await ApiService.getToken();
    final monthStr = DateFormat('yyyy-MM').format(_selectedMonth);
    final urlString = '${ApiService.baseUrl}/attendance/export?export=$format&month=$monthStr&api_token=$token';
    
    final uri = Uri.parse(urlString);
    try {
      // Launching directly works more reliably on Android 11+
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal melakukan ekspor: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _selectMonth(int offset) {
    setState(() {
      // Calculate month offset (e.g. -1 for previous month, +1 for next)
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + offset,
        1,
      );
    });
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat('MMMM yyyy', 'id_ID').format(_selectedMonth);

    return Scaffold(
      appBar: AppBar(
        title: const Text('RIWAYAT ABSENSI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFF87171)),
            tooltip: 'Ekspor PDF',
            onPressed: () => _exportHistory('pdf'),
          ),
          IconButton(
            icon: const Icon(Icons.grid_on_rounded, color: Color(0xFF34D399)),
            tooltip: 'Ekspor Excel',
            onPressed: () => _exportHistory('excel'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. Month Selector Header Bar
          _buildMonthSelectorHeader(monthName),
          
          // 2. Main History List Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadHistory,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _history.isEmpty
                      ? _buildEmptyState()
                      : _buildHistoryListView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelectorHeader(String monthName) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      color: const Color(0xFF0F172A),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF94A3B8)),
            onPressed: () => _selectMonth(-1),
          ),
          Text(
            monthName.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: Color(0xFFF1F5F9),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            // Disable moving forward past current month
            onPressed: _canMoveForward() ? () => _selectMonth(1) : null,
          ),
        ],
      ),
    );
  }

  bool _canMoveForward() {
    final now = DateTime.now();
    return _selectedMonth.year < now.year || 
          (_selectedMonth.year == now.year && _selectedMonth.month < now.month);
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        const Center(
          child: Icon(
            Icons.event_note_rounded,
            size: 64,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Tidak Ada Riwayat Absensi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Anda belum memiliki catatan kehadiran untuk bulan ini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final record = _history[index];
        return _buildHistoryCard(record);
      },
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> record) {
    // Parse date for nice formatting
    final DateTime date = DateTime.parse(record['date']);
    final String formattedDate = DateFormat('dd MMM yyyy', 'id_ID').format(date);
    final String dayName = record['day_name'] ?? '';
    
    final String checkIn = record['check_in_time'] ?? '--:--';
    final String checkOut = record['check_out_time'] ?? '--:--';
    final String duration = record['duration'] ?? '-';
    
    final String status = record['status'] ?? 'absent';
    final String statusLabel = record['status_label'] ?? '';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showDetailBottomSheet(record),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
            // Top Row: Date & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF1F5F9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dayName,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(status, statusLabel),
              ],
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(color: Color(0xFF1E293B), height: 1),
            ),
            
            // Bottom Row: Check In, Check Out, Work Duration Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailColumn('JAM MASUK', checkIn, Icons.login_rounded, const Color(0xFF6366F1)),
                _buildDetailColumn('JAM PULANG', checkOut, Icons.logout_rounded, const Color(0xFF10B981)),
                _buildDetailColumn('DURASI KERJA', duration, Icons.timer_outlined, const Color(0xFF8B5CF6)),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, String label) {
    Color color;
    switch (status) {
      case 'present':
        color = const Color(0xFF10B981); // Emerald Green
        break;
      case 'late':
        color = const Color(0xFFF59E0B); // Amber Yellow
        break;
      case 'absent':
        color = const Color(0xFFEF4444); // Red
        break;
      case 'leave':
        color = const Color(0xFF8B5CF6); // Purple
        break;
      case 'permission':
        color = const Color(0xFF3B82F6); // Blue
        break;
      case 'sick':
        color = const Color(0xFFF97316); // Orange
        break;
      default:
        color = const Color(0xFF64748B); // Gray
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value, IconData icon, Color iconColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: iconColor.withOpacity(0.7)),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE2E8F0),
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailBottomSheet(Map<String, dynamic> record) {
    final DateTime date = DateTime.parse(record['date']);
    final String formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    
    final String checkIn = record['check_in_time'] ?? '-';
    final String checkOut = record['check_out_time'] ?? '-';
    final String checkInPhoto = record['check_in_photo_url'] ?? '';
    final String checkOutPhoto = record['check_out_photo_url'] ?? '';
    final String checkInAddress = record['check_in_address'] ?? 'Tidak ada alamat';
    final String checkOutAddress = record['check_out_address'] ?? 'Tidak ada alamat';
    final double? checkInDistance = record['check_in_distance'] != null ? double.tryParse(record['check_in_distance'].toString()) : null;
    final double? checkOutDistance = record['check_out_distance'] != null ? double.tryParse(record['check_out_distance'].toString()) : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatusBadge(record['status'] ?? 'absent', record['status_label'] ?? ''),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFF1E293B)),
                  const SizedBox(height: 10),
                  _buildSectionHeader('ABSEN MASUK (CHECK-IN)', checkIn, Colors.indigoAccent),
                  const SizedBox(height: 10),
                  if (checkIn != '-') ...[
                    _buildPhotoContainer(checkInPhoto),
                    const SizedBox(height: 12),
                    _buildInfoRow('Jarak:', checkInDistance != null ? '${checkInDistance.toStringAsFixed(1)} meter dari kantor' : '-'),
                    const SizedBox(height: 4),
                    _buildInfoRow('Alamat:', checkInAddress),
                  ] else
                    const Center(child: Text('Belum absen masuk', style: TextStyle(color: Color(0xFF64748B), fontSize: 12))),
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFF1E293B)),
                  const SizedBox(height: 10),
                  _buildSectionHeader('ABSEN PULANG (CHECK-OUT)', checkOut, Colors.green),
                  const SizedBox(height: 10),
                  if (checkOut != '-') ...[
                    _buildPhotoContainer(checkOutPhoto),
                    const SizedBox(height: 12),
                    _buildInfoRow('Jarak:', checkOutDistance != null ? '${checkOutDistance.toStringAsFixed(1)} meter dari kantor' : '-'),
                    const SizedBox(height: 4),
                    _buildInfoRow('Alamat:', checkOutAddress),
                  ] else
                    const Center(child: Text('Belum absen pulang', style: TextStyle(color: Color(0xFF64748B), fontSize: 12))),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, String time, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        Text(time, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildPhotoContainer(String photoUrl) {
    if (photoUrl.isEmpty) return const SizedBox();
    return Center(
      child: Container(
        height: 160,
        width: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155), width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          photoUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.broken_image_rounded, color: Color(0xFFEF4444)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFFE2E8F0))),
      ],
    );
  }
}
