import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'check_in_screen.dart';
import 'check_out_screen.dart';
import 'history_screen.dart';
import 'announcements_screen.dart';
import 'leave_requests_screen.dart';
import 'permission_requests_screen.dart';
import 'overtime_requests_screen.dart';
import 'payslips_screen.dart';
import 'team_attendance_screen.dart';
import 'approvals_list_screen.dart';
import 'notifications_list_screen.dart';
import 'payroll_management_screen.dart';
import 'main_navigation_holder.dart';
import '../widgets/real_time_clock_card.dart';
import '../widgets/attendance_chart_widget.dart';
import '../widgets/valryze_design.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String _roleName = 'karyawan';
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _activeAttendance;
  List<dynamic> _shifts = [];
  List<dynamic> _announcements = [];

  // Stats for Manager/HR
  Map<String, dynamic> _managerStats = {
    'team_size': 0,
    'present_today': 0,
    'late_today': 0,
    'on_leave_today': 0,
    'pending_approvals_count': 0,
  };

  Map<String, dynamic> _hrSummary = {
    'total_employees': 0,
    'total_openings': 0,
    'total_applicants': 0,
    'total_payout': 0,
    'pending_approvals_count': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final profileResult = await ApiService.getProfile();
    final announcementsResult = await ApiService.getAnnouncements();

    if (!mounted) return;

    if (profileResult['success'] == true) {
      _user = profileResult['user'];
      _activeAttendance = profileResult['active_attendance'];
      _shifts = profileResult['shifts'] ?? [];
      _roleName = profileResult['user']['role_name'] ?? 'karyawan';

      if (announcementsResult['success'] == true) {
        _announcements = announcementsResult['announcements'] ?? [];
      }

      // Fetch extra statistics based on role
      if (_roleName == 'manager') {
        final statsResult = await ApiService.getManagerStats();
        if (statsResult['success'] == true && statsResult['stats'] != null) {
          _managerStats = statsResult['stats'];
        }

        final teamAttendanceResult = await ApiService.getManagerTeamAttendance();
        if (teamAttendanceResult['success'] == true && teamAttendanceResult['attendance'] != null) {
          _managerStats['team_attendance'] = teamAttendanceResult['attendance'];
        } else {
          _managerStats['team_attendance'] = [];
        }

        final approvalsResult = await ApiService.getManagerApprovals();
        if (approvalsResult['success'] == true && approvalsResult['approvals'] != null) {
          _managerStats['pending_approvals'] = approvalsResult['approvals'];
        } else {
          _managerStats['pending_approvals'] = [];
        }
      } else if (_roleName == 'hrd') {
        final recruitmentResult = await ApiService.getHrRecruitmentOnboarding();
        final payrollResult = await ApiService.getHrPayrollSummary();
        final approvalsResult = await ApiService.getHrApprovals();

        int totalOpenings = 0;
        int totalApplicants = 0;
        int totalEmployees = 0;
        int totalPayout = 0;
        int pendingApprovals = 0;
        int presentToday = 0;
        int lateToday = 0;
        int onLeaveToday = 0;
        List<dynamic> todayAttendance = [];

        if (recruitmentResult['success'] == true &&
            recruitmentResult['summary'] != null) {
          totalOpenings = recruitmentResult['summary']['total_openings'] ?? 0;
          totalApplicants =
              recruitmentResult['summary']['total_applicants'] ?? 0;
        }

        if (payrollResult['success'] == true) {
          if (payrollResult['summary'] != null) {
            totalEmployees = payrollResult['summary']['total_employees'] ?? 0;
            totalPayout = payrollResult['summary']['total_payout'] ?? 0;
            presentToday = payrollResult['summary']['present_today'] ?? 0;
            lateToday = payrollResult['summary']['late_today'] ?? 0;
            onLeaveToday = payrollResult['summary']['on_leave_today'] ?? 0;
          }
          todayAttendance = payrollResult['today_attendance'] ?? [];
        }

        if (approvalsResult['success'] == true && approvalsResult['approvals'] is List) {
          pendingApprovals = (approvalsResult['approvals'] as List).length;
        }

        _hrSummary = {
          'total_employees': totalEmployees,
          'total_openings': totalOpenings,
          'total_applicants': totalApplicants,
          'total_payout': totalPayout,
          'pending_approvals_count': pendingApprovals,
          'present_today': presentToday,
          'late_today': lateToday,
          'on_leave_today': onLeaveToday,
          'today_attendance': todayAttendance,
        };
      }

      setState(() {
        _isLoading = false;
      });

      _checkBirthdayCelebration();
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            profileResult['message'] ?? 'Gagal memuat data dashboard.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Aplikasi'),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi Smart HR Portal?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Keluar',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.logout();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleStyle = ValryzeDesign.roleStyle(_roleName);

    return Scaffold(
      backgroundColor: ValryzeDesign.pageBackground(context),
      body: Column(
        children: [
          ValryzeAppHeader(
            style: roleStyle,
            user: _user,
            onNotifications: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsListScreen(),
                ),
              );
            },
            onRefresh: _loadDashboardData,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _buildDashboardItems(roleStyle),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDashboardItems(ValryzeRoleStyle roleStyle) {
    final items = <Widget>[
      _buildRoleHeroCard(roleStyle),
      const SizedBox(height: 16),
    ];

    if (_roleName == 'manager') {
      items.addAll([
        _buildManagerTeamInsight(),
        const SizedBox(height: 16),
        _buildManagerPerluApproval(),
        const SizedBox(height: 16),
        _buildManagerKehadiranTim(),
        const SizedBox(height: 16),
        _buildPremiumAnnouncementsCard(),
      ]);
    } else if (_roleName == 'hrd') {
      items.addAll([
        const RealTimeClockCard(),
        const SizedBox(height: 16),
        _buildDashboardShiftCard(),
        const SizedBox(height: 16),
        _buildPremiumAnnouncementsCard(),
        const SizedBox(height: 16),
        _buildHrTodayFocus(),
        const SizedBox(height: 16),
        _buildRecentAttendance(),
        const SizedBox(height: 16),
        _buildHrBottomKpi(),
      ]);
    } else {
      // karyawan / default
      items.addAll([
        _buildEmployeeAttendanceActionCard(),
        const SizedBox(height: 16),
        _buildEmployeeStatsGrid(),
        const SizedBox(height: 16),
        _buildEmployeePerformaCard(),
        const SizedBox(height: 16),
        _buildPremiumAnnouncementsCard(),
      ]);
    }

    return items;
  }

  Widget _buildRoleHeroCard(ValryzeRoleStyle style) {
    if (_user == null) return const SizedBox.shrink();

    final name = _user!['name']?.toString() ?? '-';
    final division = _user!['division']?.toString() ?? '-';
    final position = _user!['position']?.toString() ?? '-';
    final today = DateFormat('EEE, d MMM', 'id_ID').format(DateTime.now());

    if (_roleName == 'hrd') {
      final employees = _hrSummary['total_employees'] ?? 0;
      final present = _hrSummary['present_today'] ?? 0;
      final pending = _hrSummary['pending_approvals_count'] ?? 0;
      final rate = employees > 0 ? '${((present / employees) * 100).round()}%' : '0%';

      return ValryzeHeroCard(
        style: style,
        title: 'HR DASHBOARD',
        name: '$name ✨',
        subtitle: '$today · 08:00–17:00',
        stats: [
          ValryzeStatData(
            value: '$present',
            label: 'Hadir',
            color: ValryzeDesign.green,
          ),
          ValryzeStatData(
            value: '$pending',
            label: 'Pending',
            color: ValryzeDesign.amber,
          ),
          ValryzeStatData(
            value: rate,
            label: 'Rate',
            color: ValryzeDesign.indigo,
          ),
        ],
      );
    }

    if (_roleName == 'manager') {
      final size = _managerStats['team_size'] ?? 0;
      final present = _managerStats['present_today'] ?? 0;
      final pending = _managerStats['pending_approvals_count'] ?? 0;

      return ValryzeHeroCard(
        style: style,
        title: position.toUpperCase(),
        name: name,
        subtitle: '$today · $division',
        stats: [
          ValryzeStatData(value: '$size', label: 'Anggota'),
          ValryzeStatData(
            value: '$present',
            label: 'Hadir',
            color: ValryzeDesign.green,
          ),
          ValryzeStatData(
            value: '$pending',
            label: 'Pending',
            color: ValryzeDesign.amber,
          ),
        ],
      );
    }

    final hasCheckedIn = _activeAttendance != null;
    final shiftTime = _activeShiftName();
    final streak = _user!['streak'] ?? 0;
    final leaveBalance = _user!['leave_balance'] ?? 12;

    return ValryzeHeroCard(
      style: style,
      title: 'SELAMAT PAGI',
      name: '$name 👋',
      subtitle: '📍 Kantor Padang Barat · $shiftTime\n⭐ $streak hari streak kehadiran 🔥',
      stats: [
        ValryzeStatData(
          value: '$streak',
          label: 'Streak',
          color: ValryzeDesign.amber,
        ),
        ValryzeStatData(
          value: hasCheckedIn ? 'Aktif' : 'Belum',
          label: 'Status',
          color: style.accent,
        ),
        ValryzeStatData(
          value: '$leaveBalance',
          label: 'Sisa Cuti',
          color: ValryzeDesign.green,
        ),
      ],
    );
  }

  String _activeShiftName() {
    final assignedShiftId = _user?['shift_id'];
    final activeShift = _shifts.cast<dynamic>().firstWhere(
      (s) => s is Map && s['id'] == assignedShiftId,
      orElse: () => _shifts.isNotEmpty ? _shifts.first : null,
    );

    if (activeShift is Map && activeShift['name'] != null) {
      final start = activeShift['start_time']?.toString();
      final end = activeShift['end_time']?.toString();
      if (start != null && end != null) {
        return '${activeShift['name']} · $start-$end';
      }
      return activeShift['name'].toString();
    }

    return 'Shift 08:00–17:00';
  }

  // ==========================================
  // HRD SPECIFIC WIDGETS
  // ==========================================

  Widget _buildHrTodayFocus() {
    final pending = _hrSummary['pending_approvals_count'] ?? 7;
    return Card(
      color: ValryzeDesign.cardBackground(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.04)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt_rounded, color: Colors.cyan, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Today's Focus",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ValryzeDesign.primaryText(context),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'AI',
                    style: TextStyle(
                      color: Colors.cyan,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFocusItem(
              Icons.warning_amber_rounded,
              Colors.orange,
              '$pending approval menunggu tindakan hari ini',
            ),
            const Divider(color: Colors.white10, height: 16),
            _buildFocusItem(
              Icons.trending_up_rounded,
              Colors.green,
              'Kehadiran naik 5% dibanding kemarin',
            ),
            const Divider(color: Colors.white10, height: 16),
            _buildFocusItem(
              Icons.people_outline_rounded,
              Colors.redAccent,
              '3 karyawan mendekati batas cuti tahunan',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusItem(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: ValryzeDesign.primaryText(context).withOpacity(0.9),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentAttendance() {
    final List<dynamic> list = _hrSummary['today_attendance'] ?? [];

    return Card(
      color: ValryzeDesign.cardBackground(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.04)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kehadiran Terkini',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ValryzeDesign.primaryText(context),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TeamAttendanceScreen(),
                    ),
                  ),
                  child: const Text('Lihat semua'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    'Belum ada data presensi masuk hari ini.',
                    style: TextStyle(
                      fontSize: 12,
                      color: ValryzeDesign.secondaryText(context),
                    ),
                  ),
                ),
              )
            else
              ...list.map((emp) {
                final String name = emp['name']?.toString() ?? '';
                final String pos = emp['position']?.toString() ?? 'Karyawan';
                final String status = emp['status']?.toString() ?? 'Hadir';
                final bool isLate = emp['is_late'] ?? (status == 'Terlambat');
                final String initials = name.isNotEmpty
                    ? name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
                    : '?';

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: isLate ? Colors.amber.withOpacity(0.12) : Colors.cyan.withOpacity(0.12),
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isLate ? Colors.amber : Colors.cyan,
                      ),
                    ),
                  ),
                  title: Text(
                    name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: ValryzeDesign.primaryText(context),
                    ),
                  ),
                  subtitle: Text(
                    pos,
                    style: TextStyle(
                      fontSize: 11,
                      color: ValryzeDesign.secondaryText(context),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLate ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: isLate ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHrBottomKpi() {
    final employees = _hrSummary['total_employees'] ?? 0;
    final lateToday = _hrSummary['late_today'] ?? 0;
    final onLeaveToday = _hrSummary['on_leave_today'] ?? 0;

    return Row(
      children: [
        _buildKpiCard('$employees', 'Total Karyawan', const Color(0xFF6366F1)),
        const SizedBox(width: 12),
        _buildKpiCard('$lateToday', 'Terlambat', const Color(0xFFF59E0B)),
        const SizedBox(width: 12),
        _buildKpiCard('$onLeaveToday', 'Cuti Aktif', const Color(0xFF8B5CF6)),
      ],
    );
  }

  Widget _buildKpiCard(String value, String label, Color color) {
    return Expanded(
      child: Card(
        color: ValryzeDesign.cardBackground(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.04)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: ValryzeDesign.secondaryText(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // MANAGER SPECIFIC WIDGETS
  // ==========================================

  Widget _buildManagerTeamInsight() {
    return Card(
      color: ValryzeDesign.cardBackground(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.04)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.trending_up_rounded, color: Color(0xFF6366F1), size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Team Insight',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: ValryzeDesign.primaryText(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '🔥 Kehadiran naik 3% minggu ini',
                        style: TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const Text(
                  '83% on-time rate',
                  style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(
                value: 0.83,
                minHeight: 6,
                backgroundColor: Colors.white10,
                color: Color(0xFF6366F1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagerPerluApproval() {
    final List<dynamic> list = _managerStats['pending_approvals'] ?? [];

    return Card(
      color: ValryzeDesign.cardBackground(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.04)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.blueAccent, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Perlu Approval',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ValryzeDesign.primaryText(context),
                  ),
                ),
                if (list.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${list.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    'Tidak ada pengajuan yang memerlukan persetujuan.',
                    style: TextStyle(
                      fontSize: 12,
                      color: ValryzeDesign.secondaryText(context),
                    ),
                  ),
                ),
              )
            else
              ...list.take(3).map((item) {
                final name = item['employee_name']?.toString() ?? '';
                final title = item['title']?.toString() ?? 'Pengajuan';
                final duration = item['duration']?.toString() ?? '';
                final isNew = item['is_new'] ?? false;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      if (isNew)
                        const CircleAvatar(radius: 4, backgroundColor: Colors.redAccent)
                      else
                        const SizedBox(width: 8),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: ValryzeDesign.primaryText(context),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$title · $duration',
                              style: TextStyle(
                                fontSize: 11,
                                color: ValryzeDesign.secondaryText(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ApprovalsListScreen(),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(60, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Review', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildManagerKehadiranTim() {
    final List<dynamic> list = _managerStats['team_attendance'] ?? [];

    return Card(
      color: ValryzeDesign.cardBackground(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.04)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kehadiran Tim',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ValryzeDesign.primaryText(context),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TeamAttendanceScreen(),
                    ),
                  ),
                  child: const Text('Detail'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    'Tidak ada anggota tim yang terdaftar.',
                    style: TextStyle(
                      fontSize: 12,
                      color: ValryzeDesign.secondaryText(context),
                    ),
                  ),
                ),
              )
            else
              ...list.map((emp) {
                final name = emp['name']?.toString() ?? '';
                final pos = emp['position']?.toString() ?? 'Karyawan';
                final streak = emp['streak'] ?? 0;
                final status = emp['status']?.toString() ?? 'absent';
                final statusLabel = emp['status_label']?.toString() ?? 'Belum Absen';

                // Dynamic coloring
                Color bg = const Color(0xFFF1F5F9);
                Color color = const Color(0xFF64748B);

                if (status == 'present') {
                  bg = const Color(0xFFDCFCE7);
                  color = const Color(0xFF10B981);
                } else if (status == 'late') {
                  bg = const Color(0xFFFEF3C7);
                  color = const Color(0xFFD97706);
                } else if (status == 'leave') {
                  bg = const Color(0xFFE0E7FF);
                  color = const Color(0xFF6366F1);
                } else if (status == 'permission') {
                  bg = const Color(0xFFF3E8FF);
                  color = const Color(0xFF8B5CF6);
                } else if (status == 'absent') {
                  bg = const Color(0xFFFEE2E2);
                  color = const Color(0xFFEF4444);
                }

                final String initials = name.isNotEmpty ? name[0] : '?';

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.12),
                    child: Text(
                      initials,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: ValryzeDesign.primaryText(context),
                        ),
                      ),
                      if (streak > 0) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 14),
                        Text(
                          '$streak',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    pos,
                    style: TextStyle(
                      fontSize: 11,
                      color: ValryzeDesign.secondaryText(context),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // EMPLOYEE SPECIFIC WIDGETS
  // ==========================================

  Widget _buildEmployeeAttendanceActionCard() {
    final bool hasCheckedIn = _activeAttendance != null;
    final now = DateFormat('HH : mm').format(DateTime.now());
    final today = DateFormat('EEE, d MMM', 'id_ID').format(DateTime.now());

    return Card(
      color: ValryzeDesign.cardBackground(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.04)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              hasCheckedIn ? 'SUDAH CLOCK IN' : 'BELUM CLOCK IN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: ValryzeDesign.secondaryText(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              now,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: ValryzeDesign.primaryText(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              today,
              style: TextStyle(
                fontSize: 12,
                color: ValryzeDesign.secondaryText(context),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (hasCheckedIn) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckOutScreen(attendance: _activeAttendance!),
                    ),
                  );
                } else {
                  final assignedShiftId = _user?['shift_id'];
                  if (assignedShiftId == null && _shifts.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Anda tidak memiliki shift aktif. Hubungi Admin.')),
                    );
                    return;
                  }
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckInScreen(
                        shifts: _shifts,
                        defaultShiftId: assignedShiftId,
                      ),
                    ),
                  );
                }
                _loadDashboardData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(hasCheckedIn ? Icons.logout_rounded : Icons.login_rounded, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    hasCheckedIn ? 'Clock Out Sekarang' : 'Clock In Sekarang',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeStatsGrid() {
    return Row(
      children: [
        _buildKpiCard('30', 'Streak', const Color(0xFFF59E0B)),
        const SizedBox(width: 12),
        _buildKpiCard('4', 'Cuti terpakai', const Color(0xFF6366F1)),
        const SizedBox(width: 12),
        _buildKpiCard('8', 'Sisa cuti', const Color(0xFF10B981)),
      ],
    );
  }

  Widget _buildEmployeePerformaCard() {
    return Card(
      color: ValryzeDesign.cardBackground(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.04)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.insights_rounded, color: Color(0xFF10B981), size: 18),
                const SizedBox(width: 8),
                Text(
                  'Performa Bulan Ini',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ValryzeDesign.primaryText(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProgressBarItem('Kehadiran', 0.96, '96%', const Color(0xFF10B981)),
            const SizedBox(height: 12),
            _buildProgressBarItem('Ketepatan Waktu', 1.0, '100%', const Color(0xFF06B6D4)),
            const SizedBox(height: 12),
            _buildProgressBarItem('Produktivitas', 0.88, '88%', const Color(0xFF6366F1)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBarItem(String label, double value, String valueText, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: ValryzeDesign.secondaryText(context)),
            ),
            Text(
              valueText,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: Colors.white10,
            color: color,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SHARED UTILITIES & PENGUMUMAN
  // ==========================================

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) {
        return '${diff.inMinutes} mnt lalu';
      } else if (diff.inHours < 24) {
        return '${diff.inHours} jam lalu';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} hari lalu';
      } else {
        return DateFormat('d MMM', 'id_ID').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildPremiumAnnouncementsCard() {
    final isDark = ValryzeDesign.isDark(context);
    final canCreate = _roleName == 'hrd' || _roleName == 'manager';

    return Card(
      color: ValryzeDesign.cardBackground(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row
            Row(
              children: [
                const Icon(
                  Icons.campaign,
                  color: Colors.redAccent,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pengumuman',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: ValryzeDesign.primaryText(context),
                  ),
                ),
                const SizedBox(width: 8),
                if (_announcements.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_announcements.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const Spacer(),
                if (canCreate)
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AnnouncementsScreen(),
                        ),
                      );
                      _loadDashboardData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0F2FE),
                      foregroundColor: const Color(0xFF06B6D4),
                      elevation: 0,
                      minimumSize: const Size(60, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text(
                      'Buat',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnnouncementsScreen(),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Lihat Semua'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Announcements list
            if (_announcements.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'Belum ada pengumuman terbaru.',
                    style: TextStyle(color: ValryzeDesign.secondaryText(context), fontSize: 12),
                  ),
                ),
              )
            else
              ..._announcements.take(3).map((ann) {
                final String category = ann['category'] ?? '';
                final isPinned = ann['is_pinned'] ?? false;
                final title = ann['title']?.toString() ?? '';
                final content = ann['content']?.toString() ?? '';
                final dateStr = ann['published_at'];
                
                // Left border color
                Color leftColor = const Color(0xFF94A3B8);
                if (category == 'info') leftColor = const Color(0xFF06B6D4);
                if (category == 'meeting') leftColor = const Color(0xFF8B5CF6);
                if (category == 'holiday') leftColor = const Color(0xFFEF4444);
                if (category == 'activity') leftColor = const Color(0xFFF59E0B);

                // Dynamically assign emoji if not present
                String emoji = '📢';
                if (title.toLowerCase().contains('libur') || title.toLowerCase().contains('adha')) {
                  emoji = '🎪';
                } else if (title.toLowerCase().contains('medical') || title.toLowerCase().contains('check')) {
                  emoji = '📢';
                } else if (title.toLowerCase().contains('terbaik') || title.toLowerCase().contains('juni')) {
                  emoji = '🏆 🏆';
                } else {
                  if (category == 'meeting') emoji = '📅';
                  if (category == 'holiday') emoji = '🏖️';
                  if (category == 'activity') emoji = '🏆';
                  if (category == 'other') emoji = '✨';
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: leftColor, width: 4),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.only(left: 12, right: 4),
                    onTap: () => _showAnnouncementDetails(ann),
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$emoji ', style: const TextStyle(fontSize: 14)),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: ValryzeDesign.primaryText(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isPinned)
                          const Icon(Icons.push_pin_rounded, size: 12, color: Colors.amber),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          content,
                          style: TextStyle(
                            fontSize: 11,
                            color: ValryzeDesign.secondaryText(context),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _timeAgo(dateStr),
                          style: TextStyle(
                            fontSize: 9,
                            color: ValryzeDesign.secondaryText(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (isPinned)
                          const CircleAvatar(
                            radius: 4,
                            backgroundColor: Colors.redAccent,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRealTimeClockCard() {
    return const RealTimeClockCard();
  }

  Widget _buildDashboardShiftCard() {
    final assignedShiftId = _user?['shift_id'];
    final activeShift = _shifts.firstWhere(
      (s) => s['id'] == assignedShiftId,
      orElse: () => _shifts.isNotEmpty ? _shifts.first : null,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: ValryzeDesign.cardBackground(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.04)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'JADWAL SHIFT ANDA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (activeShift != null) ...[
              Text(
                activeShift['name'] ?? 'Shift Default',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Jam Kerja: ${activeShift['start_time']} - ${activeShift['end_time']} WIB",
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF475569),
                ),
              ),
            ] else ...[
              const Text(
                'Tidak ada shift aktif hari ini.',
                style: TextStyle(fontSize: 12, color: Color(0xFFEF4444)),
              ),
            ],
          ],
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
        Color categoryColor = const Color(0xFF94A3B8);
        if (category == 'info') categoryColor = const Color(0xFF06B6D4);
        if (category == 'meeting') categoryColor = const Color(0xFF8B5CF6);
        if (category == 'holiday') categoryColor = const Color(0xFFEF4444);
        if (category == 'activity') categoryColor = const Color(0xFFF59E0B);

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
                          color: categoryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          categoryName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: categoryColor,
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy HH:mm', 'id_ID').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _getInitials(String name) {
    List<String> nameParts = name.split(" ");
    if (nameParts.length >= 2) {
      return nameParts[0][0] + nameParts[1][0];
    }
    return name.substring(0, name.length >= 2 ? 2 : name.length).toUpperCase();
  }

  Future<void> _checkBirthdayCelebration() async {
    final birthDateStr = _user?['birth_date'];
    if (birthDateStr != null) {
      final birthDate = DateTime.tryParse(birthDateStr);
      if (birthDate != null) {
        final now = DateTime.now();
        if (birthDate.month == now.month && birthDate.day == now.day) {
          final prefs = await SharedPreferences.getInstance();
          final lastShownKey =
              'birthday_celebration_shown_${now.year}_${now.month}_${now.day}';
          final alreadyShown = prefs.getBool(lastShownKey) ?? false;
          if (!alreadyShown) {
            await prefs.setBool(lastShownKey, true);
            if (mounted) {
              _showBirthdayCelebrationDialog();
            }
          }
        }
      }
    }
  }

  void _showBirthdayCelebrationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 700),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.elasticOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Opacity(opacity: scale.clamp(0.0, 1.0), child: child),
            );
          },
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: 320,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFEC4899), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEC4899).withOpacity(0.35),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEC4899).withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFEC4899).withOpacity(0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEC4899).withOpacity(0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('🎂', style: TextStyle(fontSize: 40)),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 60,
                      left: 24,
                      right: 24,
                      bottom: 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Selamat Ulang Tahun! 🎉',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _user?['name'] ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEC4899),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Segenap manajemen & keluarga besar PT. Smart Teknologi Indonesia mengucapkan Selamat Hari Ulang Tahun! Semoga sehat selalu, panjang umur, dan sukses menyertai langkah Anda. 🌟',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFCBD5E1),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEC4899),
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: const Color(
                                0xFFEC4899,
                              ).withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Terima Kasih! ❤️',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
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
    );
  }

  String strtolower(String val) => val.toLowerCase();
}
