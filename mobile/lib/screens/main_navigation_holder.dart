import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'check_in_screen.dart';
import 'check_out_screen.dart';
import 'leave_requests_screen.dart';
import 'permission_requests_screen.dart';
import 'overtime_requests_screen.dart';
import 'payslips_screen.dart';
import 'team_attendance_screen.dart';
import 'approvals_list_screen.dart';
import 'payroll_management_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../widgets/valryze_design.dart';

class MainNavigationHolder extends StatefulWidget {
  final int initialIndex;
  const MainNavigationHolder({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationHolder> createState() => _MainNavigationHolderState();
}

class _MainNavigationHolderState extends State<MainNavigationHolder> {
  int _currentIndex = 0;
  bool _isLoading = true;
  String _roleName = 'karyawan';
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _checkSessionAndRole();
  }

  Future<void> _checkSessionAndRole() async {
    final userData = await ApiService.getUserData();
    final profileData = await ApiService.getProfile();

    if (!mounted) return;

    if (profileData['success'] == true) {
      final user = profileData['user'];
      final role = profileData['user']['role_name'] ?? 'karyawan';
      setState(() {
        _user = user;
        _roleName = role;
        _isLoading = false;
      });
      NotificationService.syncFcmToken();
    } else if (userData != null) {
      setState(() {
        _user = userData;
        _roleName = userData['role_name'] ?? 'karyawan';
        _isLoading = false;
      });
      NotificationService.syncFcmToken();
    } else {
      // Session invalid, return to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _changeProfilePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Ambil Foto (Kamera)'),
                onTap: () async {
                  final XFile? file = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 80,
                  );
                  if (mounted) Navigator.pop(context, file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Pilih dari Galeri'),
                onTap: () async {
                  final XFile? file = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 80,
                  );
                  if (mounted) Navigator.pop(context, file);
                },
              ),
            ],
          ),
        );
      },
    );

    if (image != null) {
      setState(() {
        _isLoading = true;
      });

      final result = await ApiService.updateProfilePhoto(image.path);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        _checkSessionAndRole();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil diperbarui!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Gagal memperbarui foto profil.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Handle Super Admin redirect screen immediately
    if (_roleName == 'super_admin') {
      return _buildSuperAdminScreen();
    }

    final pages = _getPagesForRole();
    final items = _getNavBarItemsForRole();
    final roleStyle = ValryzeDesign.roleStyle(_roleName);

    return Scaffold(
      backgroundColor: ValryzeDesign.pageBackground(context),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: _buildValryzeBottomNav(items, roleStyle),
    );
  }

  Widget _buildValryzeBottomNav(
    List<BottomNavigationBarItem> items,
    ValryzeRoleStyle style,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      decoration: BoxDecoration(
        color: ValryzeDesign.cardBackground(context),
        border: Border(top: BorderSide(color: ValryzeDesign.divider(context))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.24 : 0.07,
            ),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final active = index == _currentIndex;
            final iconWidget = active ? item.activeIcon : item.icon;

            return Expanded(
              child: InkWell(
                onTap: () => setState(() => _currentIndex = index),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    vertical: 7,
                    horizontal: 2,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? style.accent.withOpacity(0.14)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconTheme(
                        data: IconThemeData(
                          color: active
                              ? style.accent
                              : ValryzeDesign.secondaryText(
                                  context,
                                ).withOpacity(0.55),
                          size: active ? 22 : 20,
                        ),
                        child: iconWidget,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: active
                              ? style.accent
                              : ValryzeDesign.secondaryText(
                                  context,
                                ).withOpacity(0.55),
                          fontSize: 9,
                          fontWeight: active
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSuperAdminScreen() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Premium warning icon
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 55,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'AKSES WEB DIALIKKAN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Color(0xFFF1F5F9),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Peran Anda adalah Super Admin. Aplikasi mobile ini dirancang khusus untuk operasional Karyawan, Manager, dan HRD.\n\nUntuk mengelola pengaturan sistem, data divisi, hak akses, dan database, silakan gunakan Dashboard Web Admin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF94A3B8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  // Standard redirect information or dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Buka Web Admin'),
                      content: const Text(
                        'Silakan buka browser di komputer Anda dan akses:\n\nhttp://localhost:8000\n\nGunakan kredensial Super Admin Anda untuk masuk.',
                        style: TextStyle(fontSize: 13, height: 1.4),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Tutup',
                            style: TextStyle(color: Color(0xFF6366F1)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.open_in_browser_rounded),
                label: const Text('BUKA DASHBOARD WEB'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _handleLogout,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  foregroundColor: const Color(0xFFEF4444),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('KELUAR APLIKASI'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Define screens for each role
  List<Widget> _getPagesForRole() {
    switch (_roleName) {
      case 'manager':
        return [
          const HomeScreen(),
          const QuickAttendanceScreen(), // Absen tab
          const TeamAttendanceScreen(), // Team List and status
          const ApprovalsListScreen(), // Approvals list for Manager
          _buildPersonalProfileScreen(),
        ];
      case 'hrd':
        return [
          const HomeScreen(),
          const QuickAttendanceScreen(), // Absen tab
          const TeamAttendanceScreen(), // Full Employee Directory + Live Attendance
          const PayrollManagementScreen(roleName: 'hrd'),
          const ApprovalsListScreen(), // HR approvals (all divisions)
          _buildPersonalProfileScreen(),
        ];
      case 'karyawan':
      default:
        return [
          const HomeScreen(),
          const QuickAttendanceScreen(),
          const PersonalRequestsScreen(), // Karyawan Personal Request Screen (Leaves/Permits/Overtimes list)
          const PayslipsScreen(),
          _buildPersonalProfileScreen(),
        ];
    }
  }

  // Define BottomNavigationBarItems for each role
  List<BottomNavigationBarItem> _getNavBarItemsForRole() {
    switch (_roleName) {
      case 'manager':
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month_rounded),
            label: 'Absen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            activeIcon: Icon(Icons.people_alt_rounded),
            label: 'Tim Saya',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in_outlined),
            activeIcon: Icon(Icons.assignment_turned_in_rounded),
            label: 'Approval',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            activeIcon: Icon(Icons.account_circle_rounded),
            label: 'Saya',
          ),
        ];
      case 'hrd':
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month_rounded),
            label: 'Absen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.badge_outlined),
            activeIcon: Icon(Icons.badge_rounded),
            label: 'Karyawan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Payroll',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.done_all_outlined),
            activeIcon: Icon(Icons.done_all_rounded),
            label: 'Approval',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            activeIcon: Icon(Icons.account_circle_rounded),
            label: 'Saya',
          ),
        ];
      case 'karyawan':
      default:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month_rounded),
            label: 'Absen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt_outlined),
            activeIcon: Icon(Icons.note_alt_rounded),
            label: 'Cuti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Gaji',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            activeIcon: Icon(Icons.account_circle_rounded),
            label: 'Saya',
          ),
        ];
    }
  }

  Widget _buildPersonalProfileScreen() {
    if (_user == null) {
      return const Scaffold(body: Center(child: Text('Data tidak ditemukan.')));
    }

    final style = ValryzeDesign.roleStyle(_roleName);

    return Scaffold(
      backgroundColor: ValryzeDesign.pageBackground(context),
      appBar: AppBar(
        backgroundColor: style.navBg,
        foregroundColor: Colors.white,
        title: const Text('PROFIL SAYA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFF87171)),
            tooltip: 'Keluar',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ValryzeCard(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _changeProfilePhoto,
                    child: Stack(
                      children: [
                        ValryzeAvatar(
                          name: _user!['name']?.toString() ?? 'Valryze',
                          photoUrl: _user!['photo_url']?.toString(),
                          color: style.accent,
                          size: 86,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: style.accent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: ValryzeDesign.cardBackground(context),
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user!['name'] ?? '-',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: ValryzeDesign.primaryText(context),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'NIK: ${_user!['nik'] ?? '-'}',
                    style: TextStyle(
                      fontSize: 13,
                      color: ValryzeDesign.secondaryText(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ValryzeStatusBadge(
                    label: _user!['role'] ?? style.roleLabel,
                    color: style.accent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Work Details Card
            Text(
              'INFORMASI PEKERJAAN & PENGATURAN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: ValryzeDesign.secondaryText(context),
              ),
            ),
            const SizedBox(height: 8),
            ValryzeCard(
              child: Padding(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildProfileInfoRow(
                      Icons.business_rounded,
                      'Divisi',
                      _user!['division'] ?? '-',
                    ),
                    Divider(color: ValryzeDesign.divider(context), height: 24),
                    _buildProfileInfoRow(
                      Icons.work_outline_rounded,
                      'Jabatan',
                      _user!['position'] ?? '-',
                    ),
                    Divider(color: ValryzeDesign.divider(context), height: 24),
                    _buildProfileInfoRow(
                      Icons.email_outlined,
                      'Email Resmi',
                      _user!['email'] ?? '-',
                    ),
                    Divider(color: ValryzeDesign.divider(context), height: 24),
                    _buildProfileInfoRow(
                      Icons.lock_person_rounded,
                      'Slip Gaji Saya',
                      'Buka Slip Gaji',
                      isAction: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PayslipsScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(color: ValryzeDesign.divider(context), height: 24),
                    ValueListenableBuilder<ThemeMode>(
                      valueListenable: themeNotifier,
                      builder: (context, currentMode, _) {
                        final bool isDark = currentMode == ThemeMode.dark;
                        return _buildProfileInfoRow(
                          isDark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          'Mode Tampilan',
                          isDark ? 'Ubah ke Terang' : 'Ubah ke Gelap',
                          isAction: true,
                          onTap: () {
                            themeNotifier.value = isDark
                                ? ThemeMode.light
                                : ThemeMode.dark;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // App Settings/Logout
            ElevatedButton.icon(
              onPressed: _handleLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('KELUAR DARI AKUN'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isAction = false,
    VoidCallback? onTap,
  }) {
    return Row(
      children: [
        Icon(icon, color: ValryzeDesign.secondaryText(context), size: 20),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: ValryzeDesign.secondaryText(context),
              ),
            ),
            const SizedBox(height: 2),
            if (isAction)
              GestureDetector(
                onTap: onTap,
                child: Row(
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6366F1), // Indigo action color
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: Color(0xFF6366F1),
                    ),
                  ],
                ),
              )
            else
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ValryzeDesign.primaryText(context),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ==========================================
// 1. QUICK ATTENDANCE SCREEN (Tab 1)
// ==========================================
class QuickAttendanceScreen extends StatefulWidget {
  const QuickAttendanceScreen({super.key});

  @override
  State<QuickAttendanceScreen> createState() => _QuickAttendanceScreenState();
}

class _QuickAttendanceScreenState extends State<QuickAttendanceScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _activeAttendance;
  List<dynamic> _shifts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    final result = await ApiService.getProfile();
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        _user = result['user'];
        _activeAttendance = result['active_attendance'];
        _shifts = result['shifts'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openCheckIn() async {
    final assignedShiftId = _user?['shift_id'];
    if (assignedShiftId == null && _shifts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda tidak memiliki shift aktif. Hubungi Admin.'),
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CheckInScreen(shifts: _shifts, defaultShiftId: assignedShiftId),
      ),
    );
    _loadData();
  }

  Future<void> _openCheckOut() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckOutScreen(attendance: _activeAttendance!),
      ),
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool hasCheckedIn = _activeAttendance != null;
    final style = ValryzeDesign.roleStyle(
      _user?['role_name']?.toString() ?? 'karyawan',
    );
    final now = DateFormat('HH:mm').format(DateTime.now());
    final today = DateFormat('EEE, d MMM', 'id_ID').format(DateTime.now());
    final shiftName = _user?['shift'] is Map
        ? (_user!['shift']['name']?.toString() ?? 'Shift aktif')
        : 'Shift aktif';

    return Scaffold(
      backgroundColor: ValryzeDesign.pageBackground(context),
      appBar: AppBar(
        backgroundColor: style.navBg,
        foregroundColor: Colors.white,
        title: const Text('PRESENSI MANDIRI'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ValryzeHeroCard(
                style: style,
                title: hasCheckedIn ? 'Sesi Aktif' : 'Belum Clock In',
                name: _user?['name']?.toString() ?? 'Karyawan',
                subtitle: '$shiftName · $today',
                stats: [
                  ValryzeStatData(
                    value: hasCheckedIn ? 'Aktif' : 'Siap',
                    label: 'Status',
                    color: style.accent,
                  ),
                  const ValryzeStatData(
                    value: 'GPS',
                    label: 'Validasi',
                    color: ValryzeDesign.green,
                  ),
                  const ValryzeStatData(
                    value: 'Selfie',
                    label: 'Bukti',
                    color: ValryzeDesign.amber,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ValryzeCard(
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        hasCheckedIn ? 'SUDAH CLOCK IN' : 'BELUM CLOCK IN',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ValryzeDesign.secondaryText(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hasCheckedIn
                            ? (_activeAttendance!['check_in_time']
                                      ?.toString() ??
                                  now)
                            : now,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ValryzeDesign.primaryText(context),
                          fontSize: 42,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        today,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ValryzeDesign.secondaryText(context),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        hasCheckedIn
                            ? 'Sesi absensi Anda aktif. Check-out dibuka sesuai aturan shift dan lokasi kantor.'
                            : 'Clock-in memakai validasi lokasi kantor, kamera selfie, dan watermark otomatis.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: ValryzeDesign.secondaryText(context),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 22),
                      ElevatedButton.icon(
                        onPressed: hasCheckedIn ? _openCheckOut : _openCheckIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: style.accent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: Icon(
                          hasCheckedIn
                              ? Icons.logout_rounded
                              : Icons.login_rounded,
                        ),
                        label: Text(
                          hasCheckedIn
                              ? 'Clock Out Sekarang'
                              : 'Clock In Sekarang',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _MiniAttendanceMetric(
                      value: '30',
                      label: 'Streak',
                      color: ValryzeDesign.amber,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniAttendanceMetric(
                      value: 'GPS',
                      label: 'Anti Fake',
                      color: style.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: _MiniAttendanceMetric(
                      value: 'WM',
                      label: 'Watermark',
                      color: ValryzeDesign.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: style.accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: style.accent.withOpacity(0.16)),
                ),
                child: Text(
                  'Catatan: absensi dilindungi validasi GPS, kamera resmi, dan watermark. Manipulasi lokasi akan direkam oleh sistem.',
                  style: TextStyle(
                    fontSize: 11,
                    color: ValryzeDesign.secondaryText(context),
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniAttendanceMetric extends StatelessWidget {
  const _MiniAttendanceMetric({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: ValryzeDesign.cardBackground(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ValryzeDesign.divider(context)),
        boxShadow: ValryzeDesign.cardShadow(context),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: ValryzeDesign.secondaryText(context),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. PERSONAL REQUESTS HISTORY SCREEN (Tab 2 Karyawan)
// ==========================================
class PersonalRequestsScreen extends StatefulWidget {
  const PersonalRequestsScreen({super.key});

  @override
  State<PersonalRequestsScreen> createState() => _PersonalRequestsScreenState();
}

class _PersonalRequestsScreenState extends State<PersonalRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PENGAJUAN SAYA'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6366F1),
          labelColor: const Color(0xFF6366F1),
          unselectedLabelColor: const Color(0xFF94A3B8),
          tabs: const [
            Tab(text: 'Cuti'),
            Tab(text: 'Izin'),
            Tab(text: 'Lembur'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const LeaveRequestsScreen(),
          const PermissionRequestsScreen(),
          const OvertimeRequestsScreen(),
        ],
      ),
    );
  }
}
