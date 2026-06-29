import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/valryze_design.dart';
import 'add_employee_screen.dart';
import 'add_division_screen.dart';

class TeamAttendanceScreen extends StatefulWidget {
  const TeamAttendanceScreen({super.key});

  @override
  State<TeamAttendanceScreen> createState() => _TeamAttendanceScreenState();
}

class _TeamAttendanceScreenState extends State<TeamAttendanceScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String _roleName = 'manager';
  List<dynamic> _attendanceList = [];
  List<dynamic> _directoryList = [];

  String _searchQuery = '';
  final _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    final profile = await ApiService.getProfile();
    if (!mounted) return;

    if (profile['success'] == true) {
      _roleName = profile['user']['role_name'] ?? 'manager';
    }

    await _fetchData();
  }

  Future<void> _fetchData() async {
    if (_roleName == 'hrd') {
      final attendanceRes = await ApiService.getManagerTeamAttendance();
      final directoryRes = await ApiService.getHrEmployees();

      if (!mounted) return;

      setState(() {
        if (directoryRes['success'] == true) {
          _directoryList = directoryRes['employees'] ?? [];
        }
        if (attendanceRes['success'] == true) {
          _attendanceList = attendanceRes['attendance'] ?? [];
        }
        _isLoading = false;
      });
    } else {
      final attendanceRes = await ApiService.getManagerTeamAttendance();

      if (!mounted) return;

      setState(() {
        if (attendanceRes['success'] == true) {
          _attendanceList = attendanceRes['attendance'] ?? [];
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = ValryzeDesign.roleStyle(_roleName);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: ValryzeDesign.pageBackground(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_roleName == 'hrd') {
      return Scaffold(
        backgroundColor: ValryzeDesign.pageBackground(context),
        appBar: AppBar(
          backgroundColor: style.navBg,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'MANAJEMEN KARYAWAN',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: style.accent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: const [
              Tab(text: 'Live Kehadiran'),
              Tab(text: 'Direktori'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildLiveAttendanceTab(style), _buildDirectoryTab(style)],
        ),
        floatingActionButton: _tabController.index == 1
            ? FloatingActionButton(
                onPressed: _showAddDataSheet,
                backgroundColor: style.accent,
                foregroundColor: Colors.white,
                tooltip: 'Tambah Data Baru',
                child: const Icon(Icons.add),
              )
            : null,
      );
    }

    return Scaffold(
      backgroundColor: ValryzeDesign.pageBackground(context),
      appBar: AppBar(
        backgroundColor: style.navBg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'KEHADIRAN TIM SAYA',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
      ),
      body: _buildLiveAttendanceTab(style),
    );
  }

  Widget _buildLiveAttendanceTab(ValryzeRoleStyle style) {
    final filteredList = _attendanceList.where((item) {
      final name = (item['name'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    final total = filteredList.length;
    final present = filteredList.where((item) {
      return item['status'] == 'present' || item['status'] == 'late';
    }).length;
    final late = filteredList.where((item) => item['status'] == 'late').length;
    final leavePermission = filteredList.where((item) {
      return item['status'] == 'leave' || item['status'] == 'permission';
    }).length;
    final absent = total - present - leavePermission;
    final ratio = total > 0 ? (present / total) : 0.0;

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ValryzeHeroCard(
            style: style,
            eyebrow: _roleName == 'hrd' ? 'LIVE KEHADIRAN' : 'TEAM INSIGHT',
            title: '${(ratio * 100).toInt()}% hadir hari ini',
            subtitle:
                'Pantau status kehadiran dan validasi absen tim secara real-time.',
            stats: [
              ValryzeStatData(label: 'Anggota', value: '$total'),
              ValryzeStatData(label: 'Hadir', value: '$present'),
              ValryzeStatData(label: 'Pending', value: '$absent'),
            ],
          ),
          const SizedBox(height: 14),
          ValryzeCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rasio Kehadiran',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: ValryzeDesign.primaryText(context),
                      ),
                    ),
                    Text(
                      '$present / $total',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: style.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: ratio,
                  backgroundColor: ValryzeDesign.divider(context),
                  color: style.accent,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMiniStat(
                        'Terlambat',
                        '$late',
                        const Color(0xFFF59E0B),
                      ),
                    ),
                    Expanded(
                      child: _buildMiniStat(
                        'Cuti/Izin',
                        '$leavePermission',
                        const Color(0xFF8B5CF6),
                      ),
                    ),
                    Expanded(
                      child: _buildMiniStat(
                        'Belum Absen',
                        '$absent',
                        const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSearchField('Cari nama karyawan...'),
          const SizedBox(height: 16),
          if (filteredList.isEmpty)
            _buildEmptyState('Tidak ada data kehadiran ditemukan.')
          else
            ...filteredList.map(
              (item) => _buildAttendanceListTile(item, style),
            ),
        ],
      ),
    );
  }

  Widget _buildDirectoryTab(ValryzeRoleStyle style) {
    final filteredList = _directoryList.where((item) {
      final name = (item['name'] ?? '').toString().toLowerCase();
      final division = (item['division'] ?? '').toString().toLowerCase();
      final needle = _searchQuery.toLowerCase();
      return name.contains(needle) || division.contains(needle);
    }).toList();

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ValryzeHeroCard(
            style: style,
            eyebrow: 'DIREKTORI KARYAWAN',
            title: '${_directoryList.length} karyawan aktif',
            subtitle:
                'Data singkat karyawan, divisi, posisi, dan status kontrak.',
            stats: [
              ValryzeStatData(
                label: 'Aktif',
                value: '${_directoryList.length}',
              ),
              ValryzeStatData(label: 'Tampil', value: '${filteredList.length}'),
              const ValryzeStatData(label: 'Akses', value: 'HR'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchField('Cari berdasarkan nama atau divisi...'),
          const SizedBox(height: 16),
          if (filteredList.isEmpty)
            _buildEmptyState('Tidak ada karyawan ditemukan di direktori.')
          else
            ...filteredList.map((item) => _buildDirectoryListTile(item, style)),
        ],
      ),
    );
  }

  Widget _buildSearchField(String hint) {
    return TextField(
      controller: _searchController,
      onChanged: (val) => setState(() => _searchQuery = val),
      style: TextStyle(color: ValryzeDesign.primaryText(context), fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: ValryzeDesign.secondaryText(context)),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: ValryzeDesign.secondaryText(context),
          size: 20,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        filled: true,
        fillColor: ValryzeDesign.fieldBackground(context),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: ValryzeDesign.divider(context)),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: ValryzeDesign.secondaryText(context),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAttendanceListTile(
    Map<String, dynamic> item,
    ValryzeRoleStyle style,
  ) {
    final status = item['status'] ?? 'absent';
    final statusLabel = item['status_label'] ?? 'Mangkir';
    final statusColor = _statusColor(status);
    final statusIcon = _statusIcon(status);
    final hasPhoto = item['check_in_photo'] != null;

    return ValryzeCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ValryzeAvatar(
            name: item['name'] ?? '??',
            color: style.accent,
            radius: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '-',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: ValryzeDesign.primaryText(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['position'] ?? '-',
                  style: TextStyle(
                    fontSize: 10,
                    color: ValryzeDesign.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    if (item['check_in'] != null)
                      _timeChip(
                        Icons.login_rounded,
                        'In ${item['check_in']}',
                        const Color(0xFF10B981),
                      ),
                    if (item['check_out'] != null)
                      _timeChip(
                        Icons.logout_rounded,
                        'Out ${item['check_out']}',
                        const Color(0xFFEF4444),
                      ),
                    if (item['check_in'] == null && item['check_out'] == null)
                      Text(
                        'Belum ada riwayat absen',
                        style: TextStyle(
                          fontSize: 10,
                          color: ValryzeDesign.secondaryText(context),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ValryzeStatusBadge(
                label: statusLabel,
                color: statusColor,
                icon: statusIcon,
              ),
              if (hasPhoto) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showPhotoDialog(
                    item['name'] ?? 'Swafoto',
                    item['check_in_photo'],
                    item['check_in_address'],
                  ),
                  child: const Text(
                    'Lihat Foto',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w900,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDirectoryListTile(
    Map<String, dynamic> item,
    ValryzeRoleStyle style,
  ) {
    return ValryzeCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ValryzeAvatar(
            name: item['name'] ?? '??',
            color: style.accent,
            radius: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '-',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: ValryzeDesign.primaryText(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item['division'] ?? '-'} - ${item['position'] ?? '-'}',
                  style: TextStyle(
                    fontSize: 11,
                    color: ValryzeDesign.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 10,
                      color: ValryzeDesign.secondaryText(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Bergabung: ${item['join_date']}',
                      style: TextStyle(
                        fontSize: 10,
                        color: ValryzeDesign.secondaryText(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ValryzeStatusBadge(
            label: item['employment_type'] ?? 'Permanent',
            color: style.accent,
          ),
        ],
      ),
    );
  }

  Widget _timeChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: ValryzeDesign.primaryText(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    if (status == 'present') return const Color(0xFF10B981);
    if (status == 'late') return const Color(0xFFF59E0B);
    if (status == 'leave' || status == 'permission')
      return const Color(0xFF8B5CF6);
    return const Color(0xFFEF4444);
  }

  IconData _statusIcon(String status) {
    if (status == 'present') return Icons.check_circle_rounded;
    if (status == 'late') return Icons.access_time_filled_rounded;
    if (status == 'leave' || status == 'permission')
      return Icons.event_note_rounded;
    return Icons.cancel_outlined;
  }

  void _showAddDataSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: ValryzeDesign.cardBackground(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'MANAJEMEN DATA BARU',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: ValryzeDesign.secondaryText(context),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 20),
              _buildAddTile(
                icon: Icons.person_add_rounded,
                color: ValryzeDesign.hrd.accent,
                title: 'Tambah Karyawan Baru',
                subtitle: 'Daftarkan akun karyawan baru ke portal',
                onTap: () async {
                  Navigator.pop(context);
                  final refresh = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEmployeeScreen(),
                    ),
                  );
                  if (refresh == true) _fetchData();
                },
              ),
              Divider(color: ValryzeDesign.divider(context)),
              _buildAddTile(
                icon: Icons.business_rounded,
                color: const Color(0xFF10B981),
                title: 'Tambah Divisi Baru',
                subtitle: 'Buat divisi/departemen kerja baru',
                onTap: () async {
                  Navigator.pop(context);
                  final refresh = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddDivisionScreen(),
                    ),
                  );
                  if (refresh == true) _fetchData();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.12),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: ValryzeDesign.primaryText(context),
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: ValryzeDesign.secondaryText(context),
          fontSize: 11,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showPhotoDialog(String title, String imageUrl, String? address) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: ValryzeDesign.cardBackground(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: ValryzeDesign.primaryText(context),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: ValryzeDesign.secondaryText(context),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: ValryzeDesign.quietSurface(context),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_rounded,
                          size: 40,
                          color: ValryzeDesign.secondaryText(context),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gambar gagal dimuat.',
                          style: TextStyle(
                            fontSize: 11,
                            color: ValryzeDesign.secondaryText(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (address != null && address.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFFEF4444),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        address,
                        style: TextStyle(
                          fontSize: 11,
                          color: ValryzeDesign.secondaryText(context),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 40,
              color: ValryzeDesign.secondaryText(context),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: ValryzeDesign.secondaryText(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
