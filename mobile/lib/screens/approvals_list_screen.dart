import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/valryze_design.dart';

class ApprovalsListScreen extends StatefulWidget {
  const ApprovalsListScreen({super.key});

  @override
  State<ApprovalsListScreen> createState() => _ApprovalsListScreenState();
}

class _ApprovalsListScreenState extends State<ApprovalsListScreen> {
  bool _isLoading = true;
  String _roleName = 'manager';
  List<dynamic> _approvals = [];
  String _activeFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final profile = await ApiService.getProfile();
    if (!mounted) return;

    if (profile['success'] == true) {
      _roleName = profile['user']['role_name'] ?? 'manager';
    }

    await _fetchApprovals();
  }

  Future<void> _fetchApprovals() async {
    final response = _roleName == 'hrd'
        ? await ApiService.getHrApprovals()
        : await ApiService.getManagerApprovals();

    if (!mounted) return;

    setState(() {
      if (response['success'] == true) {
        _approvals = response['approvals'] ?? [];
      }
      _isLoading = false;
    });
  }

  Future<void> _processApproval({
    required String type,
    required int id,
    required String action,
    String? rejectionReason,
  }) async {
    setState(() => _isLoading = true);

    final response = _roleName == 'hrd'
        ? await ApiService.processHrApproval(
            type: type,
            id: id,
            action: action,
            rejectionReason: rejectionReason,
          )
        : await ApiService.processManagerApproval(
            type: type,
            id: id,
            action: action,
            rejectionReason: rejectionReason,
          );

    if (!mounted) return;

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  action == 'approve'
                      ? 'Pengajuan berhasil disetujui.'
                      : 'Pengajuan berhasil ditolak.',
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      _fetchApprovals();
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Gagal memproses pengajuan.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showApprovalConfirmDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setujui Pengajuan'),
        content: Text(
          'Apakah Anda yakin ingin menyetujui pengajuan ${item['type_label']} dari ${item['employee_name']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _processApproval(
                type: item['type'],
                id: item['id'],
                action: 'approve',
              );
            },
            child: const Text(
              'Setujui',
              style: TextStyle(
                color: Color(0xFF10B981),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(Map<String, dynamic> item) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Pengajuan'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Berikan alasan penolakan pengajuan ${item['type_label']} untuk ${item['employee_name']}:',
                style: TextStyle(
                  fontSize: 12,
                  color: ValryzeDesign.secondaryText(context),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Tulis alasan penolakan di sini...',
                  contentPadding: EdgeInsets.all(12),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Alasan penolakan wajib diisi.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final reason = reasonController.text.trim();
                Navigator.pop(context);
                _processApproval(
                  type: item['type'],
                  id: item['id'],
                  action: 'reject',
                  rejectionReason: reason,
                );
              }
            },
            child: const Text(
              'Tolak',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = ValryzeDesign.roleStyle(_roleName);
    final filteredApprovals = _approvals.where((item) {
      if (_activeFilter == 'all') return true;
      return item['type'] == _activeFilter;
    }).toList();

    final leaveCount = _approvals
        .where((item) => item['type'] == 'leave')
        .length;
    final permissionCount = _approvals
        .where((item) => item['type'] == 'permission')
        .length;
    final overtimeCount = _approvals
        .where((item) => item['type'] == 'overtime')
        .length;

    return Scaffold(
      backgroundColor: ValryzeDesign.pageBackground(context),
      appBar: AppBar(
        backgroundColor: style.navBg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _roleName == 'hrd' ? 'APPROVAL HR' : 'PERSETUJUAN TIM',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: _fetchApprovals,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchApprovals,
              child: Column(
                children: [
                  _buildFilterHeader(
                    leaveCount,
                    permissionCount,
                    overtimeCount,
                    style,
                  ),
                  Expanded(
                    child: filteredApprovals.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
                            itemCount: filteredApprovals.length,
                            itemBuilder: (context, index) {
                              return _buildApprovalCard(
                                filteredApprovals[index],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterHeader(
    int leaves,
    int permissions,
    int overtimes,
    ValryzeRoleStyle style,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      color: ValryzeDesign.pageBackground(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ValryzeHeroCard(
            style: style,
            eyebrow: _roleName == 'hrd'
                ? 'HR APPROVAL CENTER'
                : 'MANAGER APPROVAL',
            title: '${_approvals.length} pengajuan menunggu',
            subtitle: 'Pantau cuti, izin, dan lembur dari satu layar.',
            stats: [
              ValryzeStatData(label: 'Cuti', value: '$leaves'),
              ValryzeStatData(label: 'Izin', value: '$permissions'),
              ValryzeStatData(label: 'Lembur', value: '$overtimes'),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'all',
                  'Semua',
                  _approvals.length,
                  color: style.accent,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'leave',
                  'Cuti',
                  leaves,
                  color: const Color(0xFFF59E0B),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'permission',
                  'Izin',
                  permissions,
                  color: const Color(0xFF8B5CF6),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'overtime',
                  'Lembur',
                  overtimes,
                  color: const Color(0xFFEF4444),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String filterType,
    String label,
    int count, {
    Color color = const Color(0xFF6366F1),
  }) {
    final isActive = _activeFilter == filterType;
    final textColor = ValryzeDesign.secondaryText(context);

    return GestureDetector(
      onTap: () => setState(() => _activeFilter = filterType),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isActive
              ? color.withOpacity(ValryzeDesign.isDark(context) ? 0.2 : 0.13)
              : ValryzeDesign.cardBackground(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive
                ? color.withOpacity(0.4)
                : ValryzeDesign.divider(context),
          ),
          boxShadow: isActive ? ValryzeDesign.cardShadow(context) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isActive ? color : textColor,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 7),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? color : const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalCard(Map<String, dynamic> item) {
    final type = item['type'] ?? 'leave';
    final duration = item['duration'] ?? '-';
    final reason = item['reason'] ?? '-';
    final dateRange = type == 'overtime'
        ? item['start_date']
        : "${item['start_date']} - ${item['end_date'] ?? ''}";

    Color typeColor = const Color(0xFFF59E0B);
    if (type == 'permission') {
      typeColor = const Color(0xFF8B5CF6);
    } else if (type == 'overtime') {
      typeColor = const Color(0xFFEF4444);
    }

    final division = item['division'];
    final positionText =
        '${division != null ? "$division - " : ""}${item['position'] ?? '-'}';

    return ValryzeCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ValryzeAvatar(
                name: item['employee_name'] ?? '??',
                color: typeColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['employee_name'] ?? '-',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: ValryzeDesign.primaryText(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      positionText,
                      style: TextStyle(
                        fontSize: 10,
                        color: ValryzeDesign.secondaryText(context),
                      ),
                    ),
                  ],
                ),
              ),
              ValryzeStatusBadge(
                label: (item['type_label'] ?? type).toString().toUpperCase(),
                color: typeColor,
              ),
            ],
          ),
          Divider(color: ValryzeDesign.divider(context), height: 28),
          Text(
            item['title'] ?? '-',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: ValryzeDesign.primaryText(context),
            ),
          ),
          const SizedBox(height: 12),
          _buildCardDetailRow(
            Icons.calendar_today_rounded,
            'Tanggal',
            dateRange,
          ),
          const SizedBox(height: 8),
          _buildCardDetailRow(Icons.timer_rounded, 'Durasi / Jam', duration),
          const SizedBox(height: 8),
          _buildCardDetailRow(Icons.description_outlined, 'Alasan', reason),
          if (item['attachment_url'] != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showAttachment(item['attachment_url']),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.attach_file_rounded,
                    color: Color(0xFF6366F1),
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Lihat Dokumen Lampiran',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w900,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
          Divider(color: ValryzeDesign.divider(context), height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showRejectDialog(item),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: const Color(0xFFEF4444).withOpacity(0.45),
                    ),
                    foregroundColor: const Color(0xFFEF4444),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  child: const Text(
                    'TOLAK',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showApprovalConfirmDialog(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    minimumSize: Size.zero,
                  ),
                  child: const Text(
                    'SETUJUI',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAttachment(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Lampiran Dokumen',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              Image.network(
                imageUrl,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Gagal memuat dokumen lampiran.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: ValryzeDesign.secondaryText(context), size: 14),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 11,
            color: ValryzeDesign.secondaryText(context),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: ValryzeDesign.primaryText(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 70, 28, 96),
      children: [
        const Icon(Icons.done_all_rounded, size: 48, color: Color(0xFF10B981)),
        const SizedBox(height: 16),
        Text(
          'Semua Pengajuan Selesai!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: ValryzeDesign.primaryText(context),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tidak ada pengajuan persetujuan baru yang menunggu tindakan Anda.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: ValryzeDesign.secondaryText(context),
          ),
        ),
      ],
    );
  }
}
