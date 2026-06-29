import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../widgets/valryze_design.dart';

class PayrollManagementScreen extends StatefulWidget {
  final String roleName;

  const PayrollManagementScreen({super.key, required this.roleName});

  @override
  State<PayrollManagementScreen> createState() =>
      _PayrollManagementScreenState();
}

class _PayrollManagementScreenState extends State<PayrollManagementScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _summary;
  List<dynamic> _payrollList = [];
  List<dynamic> _filteredList = [];
  final TextEditingController _searchController = TextEditingController();

  final _rpFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadPayrollData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String _compactRupiah(double value) {
    if (value >= 1000000000) {
      return 'Rp ${(value / 1000000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000000) return 'Rp ${(value / 1000000).toStringAsFixed(1)}jt';
    if (value >= 1000) return 'Rp ${(value / 1000).toStringAsFixed(0)}rb';
    return _rpFormat.format(value);
  }

  String _payrollSubtitle() {
    if (widget.roleName == 'hrd') {
      return 'Total payroll bersih seluruh karyawan.';
    }

    final scope = _summary?['scope_label']?.toString();
    final division = _summary?['division']?.toString();

    if (scope == 'Data Manager') {
      return 'Data payroll Anda untuk bulan ini.';
    }

    if (scope != null && scope.isNotEmpty) {
      if (division != null &&
          division.isNotEmpty &&
          division != 'Belum diatur') {
        return '$scope - $division';
      }
      return scope;
    }

    return 'Ringkasan payroll anggota tim Anda.';
  }

  bool _isSelfPayroll(Map<String, dynamic> emp) {
    final value = emp['is_self'];
    return value == true || value == 1 || value == '1' || value == 'true';
  }

  Future<void> _loadPayrollData() async {
    setState(() => _isLoading = true);

    final result = widget.roleName == 'hrd'
        ? await ApiService.getHrPayrollSummary()
        : await ApiService.getManagerPayrollSummary();

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _summary = result['summary'];
        _payrollList = result['payroll_list'] ?? [];
        _filteredList = _payrollList;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal memuat data payroll.'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  void _filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredList = _payrollList;
      } else {
        _filteredList = _payrollList.where((emp) {
          final name = emp['name'].toString().toLowerCase();
          final nik = emp['nik'].toString().toLowerCase();
          final needle = query.toLowerCase();
          return name.contains(needle) || nik.contains(needle);
        }).toList();
      }
    });
  }

  void _openEditSalaryDialog(Map<String, dynamic> employee) {
    if (widget.roleName != 'hrd') return;

    final basicController = TextEditingController(
      text: employee['basic_salary'].toString(),
    );
    final allowanceController = TextEditingController(
      text: (employee['allowance'] ?? 0).toString(),
    );
    final basic = _parseDouble(employee['basic_salary']);
    final bpjsController = TextEditingController(
      text: (employee['bpjs_deduction'] ?? (basic * 0.03).round()).toString(),
    );
    final taxController = TextEditingController(
      text: (employee['tax_deduction'] ?? (basic * 0.05).round()).toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ValryzeDesign.cardBackground(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
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
                Row(
                  children: [
                    ValryzeAvatar(
                      name: employee['name'] ?? '??',
                      color: ValryzeDesign.hrd.accent,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PENGATURAN GAJI',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF06B6D4),
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            employee['name'] ?? '-',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: ValryzeDesign.primaryText(context),
                            ),
                          ),
                          Text(
                            'NIK: ${employee['nik'] ?? '-'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: ValryzeDesign.secondaryText(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: ValryzeDesign.secondaryText(context),
                      ),
                    ),
                  ],
                ),
                Divider(color: ValryzeDesign.divider(context), height: 32),
                _buildFieldLabel('Gaji Pokok (Rp)'),
                _buildTextField(basicController, 'Masukkan gaji pokok'),
                const SizedBox(height: 16),
                _buildFieldLabel('Tunjangan (Rp)'),
                _buildTextField(allowanceController, 'Masukkan tunjangan'),
                const SizedBox(height: 16),
                _buildFieldLabel('Potongan BPJS (Rp)'),
                _buildTextField(bpjsController, 'Masukkan potongan BPJS'),
                const SizedBox(height: 16),
                _buildFieldLabel('Potongan Pajak PPh 21 (Rp)'),
                _buildTextField(taxController, 'Masukkan potongan pajak'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    final basic = double.tryParse(basicController.text) ?? 0.0;
                    final allowance =
                        double.tryParse(allowanceController.text) ?? 0.0;
                    final bpjs = double.tryParse(bpjsController.text) ?? 0.0;
                    final tax = double.tryParse(taxController.text) ?? 0.0;
                    final messenger = ScaffoldMessenger.of(this.context);

                    Navigator.pop(context);
                    setState(() => _isLoading = true);

                    final res = await ApiService.updateHrEmployeePayroll(
                      id: employee['user_id'] ?? employee['id'],
                      basicSalary: basic,
                      allowance: allowance,
                      bpjsDeduction: bpjs,
                      taxDeduction: tax,
                    );

                    if (!mounted) return;

                    if (res['success'] == true) {
                      _loadPayrollData();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            res['message'] ?? 'Berhasil memperbarui gaji.',
                          ),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    } else {
                      setState(() => _isLoading = false);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            res['message'] ?? 'Gagal memperbarui gaji.',
                          ),
                          backgroundColor: const Color(0xFFEF4444),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ValryzeDesign.hrd.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'SIMPAN PERUBAHAN GAJI',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: ValryzeDesign.secondaryText(context),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String placeholder) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(
        color: ValryzeDesign.primaryText(context),
        fontFamily: 'JetBrains Mono',
        fontSize: 13,
      ),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(color: ValryzeDesign.secondaryText(context)),
        filled: true,
        fillColor: ValryzeDesign.quietSurface(context),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: ValryzeDesign.divider(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF06B6D4)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = ValryzeDesign.roleStyle(widget.roleName);

    return Scaffold(
      backgroundColor: ValryzeDesign.pageBackground(context),
      appBar: AppBar(
        backgroundColor: style.navBg,
        foregroundColor: Colors.white,
        title: Text(
          widget.roleName == 'hrd' ? 'MANAJEMEN PAYROLL' : 'PAYROLL TIM SAYA',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadPayrollData,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_summary != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: ValryzeHeroCard(
                      style: style,
                      eyebrow: 'PERIODE ${_summary!['month'] ?? '-'}',
                      title: _rpFormat.format(
                        _parseDouble(_summary!['total_payout']),
                      ),
                      subtitle: _payrollSubtitle(),
                      stats: [
                        ValryzeStatData(
                          label: 'Karyawan',
                          value: '${_summary!['total_employees'] ?? 0}',
                        ),
                        ValryzeStatData(
                          label: 'Tunjangan',
                          value: _compactRupiah(
                            _parseDouble(_summary!['total_benefits']),
                          ),
                        ),
                        ValryzeStatData(
                          label: 'Potongan',
                          value: _compactRupiah(
                            _parseDouble(_summary!['total_deductions']),
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterSearch,
                    style: TextStyle(
                      color: ValryzeDesign.primaryText(context),
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari nama atau NIK karyawan...',
                      hintStyle: TextStyle(
                        color: ValryzeDesign.secondaryText(context),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: ValryzeDesign.secondaryText(context),
                        size: 20,
                      ),
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
                        borderSide: BorderSide(
                          color: ValryzeDesign.divider(context),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredList.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada data karyawan ditemukan.',
                            style: TextStyle(
                              color: ValryzeDesign.secondaryText(context),
                              fontSize: 13,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                          itemCount: _filteredList.length,
                          itemBuilder: (context, index) {
                            final emp = _filteredList[index];
                            final basic = _parseDouble(emp['basic_salary']);
                            final allowance = _parseDouble(emp['allowance']);
                            final deductions = _parseDouble(emp['deductions']);
                            final net = _parseDouble(emp['net_salary']);
                            return _buildPayrollCard(
                              emp,
                              basic,
                              allowance,
                              deductions,
                              net,
                              style,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildPayrollCard(
    Map<String, dynamic> emp,
    double basic,
    double allowance,
    double deductions,
    double net,
    ValryzeRoleStyle style,
  ) {
    return ValryzeCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: widget.roleName == 'hrd'
            ? () => _openEditSalaryDialog(emp)
            : null,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ValryzeAvatar(
                  name: emp['name'] ?? '??',
                  color: style.accent,
                  radius: 21,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        emp['name'] ?? '-',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: ValryzeDesign.primaryText(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${emp['nik']} - ${emp['position']}',
                        style: TextStyle(
                          fontSize: 11,
                          color: ValryzeDesign.secondaryText(context),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.roleName == 'hrd')
                  const Icon(
                    Icons.edit_note_rounded,
                    color: Color(0xFF06B6D4),
                    size: 24,
                  )
                else if (_isSelfPayroll(emp))
                  ValryzeStatusBadge(
                    label: 'Data Saya',
                    color: style.accent,
                    icon: Icons.account_circle_rounded,
                  ),
              ],
            ),
            Divider(color: ValryzeDesign.divider(context), height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildItemBreakdown(
                    'Gaji Pokok',
                    _rpFormat.format(basic),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _buildItemBreakdown(
                      'Tunjangan',
                      _rpFormat.format(allowance),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _buildItemBreakdown(
                      'Potongan',
                      _rpFormat.format(deductions),
                      isRed: true,
                    ),
                  ),
                ),
              ],
            ),
            Divider(color: ValryzeDesign.divider(context), height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Take Home Pay',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: ValryzeDesign.primaryText(context),
                  ),
                ),
                Text(
                  _rpFormat.format(net),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: style.accent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemBreakdown(String label, String val, {bool isRed = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: ValryzeDesign.secondaryText(context),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: TextStyle(
            fontSize: 11,
            fontFamily: 'JetBrains Mono',
            fontWeight: FontWeight.w900,
            color: isRed
                ? const Color(0xFFEF4444)
                : ValryzeDesign.primaryText(context),
          ),
        ),
      ],
    );
  }
}
