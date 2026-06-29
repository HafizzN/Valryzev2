import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class PayslipsScreen extends StatefulWidget {
  const PayslipsScreen({super.key});

  @override
  State<PayslipsScreen> createState() => _PayslipsScreenState();
}

class _PayslipsScreenState extends State<PayslipsScreen> {
  bool _isUnlocked = false;
  String _pinCode = '';
  String _errorMessage = '';
  bool _isLoadingData = true;
  Map<String, dynamic>? _user;
  
  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) {
      return double.tryParse(value)?.round() ?? int.tryParse(value) ?? 0;
    }
    return 0;
  }

  // Salary details
  String _selectedMonth = 'Juni 2026';
  final List<String> _months = ['Juni 2026', 'Mei 2026', 'April 2026', 'Maret 2026'];
  
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final result = await ApiService.getProfile();
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        _user = result['user'];
        _isLoadingData = false;
      });
    } else {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  void _handleKeyPress(String value) {
    if (_pinCode.length >= 6) return;
    
    setState(() {
      _pinCode += value;
      _errorMessage = '';
    });

    if (_pinCode.length == 6) {
      _verifyPin();
    }
  }

  void _handleBackspace() {
    if (_pinCode.isEmpty) return;
    setState(() {
      _pinCode = _pinCode.substring(0, _pinCode.length - 1);
      _errorMessage = '';
    });
  }

  void _verifyPin() {
    // Default security PIN is 123456
    if (_pinCode == '123456') {
      setState(() {
        _isUnlocked = true;
      });
    } else {
      setState(() {
        _pinCode = '';
        _errorMessage = 'PIN salah. Silakan coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF07101A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0C1A2B) : Colors.white,
        foregroundColor: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
        title: const Text(
          'SLIP GAJI SAYA',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        elevation: 0,
        actions: [
          if (_isUnlocked)
            IconButton(
              onPressed: () => setState(() { _isUnlocked = false; _pinCode = ''; }),
              icon: const Icon(Icons.lock_rounded, size: 20),
              tooltip: 'Kunci Kembali',
            ),
        ],
      ),
      body: _isUnlocked ? _buildPayslipDashboard() : _buildPinScreen(),
    );
  }

  // ==========================================
  // 1. PIN SECURE SCREEN
  // ==========================================
  Widget _buildPinScreen() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        // Shield Icon
        Center(
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFF818CF8),
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'MASUKKAN PIN KEAMANAN',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Silakan masukkan 6 digit PIN pengaman Anda\nuntuk membuka dokumen rahasia ini.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF475569),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),

        // PIN Dots Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            final isFilled = index < _pinCode.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isFilled ? const Color(0xFF6366F1) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isFilled ? const Color(0xFF6366F1) : const Color(0xFF475569),
                  width: 2,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        
        if (_errorMessage.isNotEmpty)
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),

        const Spacer(),
        
        // Help Note
        const Center(
          child: Text(
            'Tip: Gunakan PIN default 123456',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF475569),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // custom numeric keypad
        _buildNumericKeypad(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildNumericKeypad() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'backspace'],
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: keys.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              if (key.isEmpty) {
                return const SizedBox(width: 70, height: 70);
              }
              if (key == 'backspace') {
                return InkWell(
                  onTap: _handleBackspace,
                  borderRadius: BorderRadius.circular(35),
                  child: const SizedBox(
                    width: 70,
                    height: 70,
                    child: Center(
                      child: Icon(Icons.backspace_outlined, color: Color(0xFF94A3B8)),
                    ),
                  ),
                );
              }
              return InkWell(
                onTap: () => _handleKeyPress(key),
                borderRadius: BorderRadius.circular(35),
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: Center(
                    child: Text(
                      key,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // 2. PAYSLIP VIEW SCREEN (Unlocked)
  // ==========================================
  Widget _buildPayslipDashboard() {
    final customBasicSalary = _user?['basic_salary'];
    final customAllowance = _user?['allowance'];
    final customBpjs = _user?['bpjs_deduction'];
    final customTax = _user?['tax_deduction'];

    final bool hasCustom = customBasicSalary != null;

    int basicSalary;
    int allowanceJob;
    int allowanceMeal;
    int grossEarnings;
    int bpjsKes;
    int bpjsKet;
    int pph21Tax;
    int totalDeductions;
    int netTakeHomePay;

    if (hasCustom) {
      basicSalary = _parseInt(customBasicSalary);
      allowanceJob = _parseInt(customAllowance);
      allowanceMeal = 0;
      grossEarnings = basicSalary + allowanceJob;

      bpjsKes = _parseInt(customBpjs);
      bpjsKet = 0;
      pph21Tax = _parseInt(customTax);
      totalDeductions = bpjsKes + pph21Tax;
      netTakeHomePay = grossEarnings - totalDeductions;
    } else {
      // Revert/Fall back to deterministic calculation
      final posName = strtolower(_user?['position'] ?? '');
      int calculatedBasic = 6500000; // Rp 6.5M default

      if (posName.contains('director') || posName.contains('direktur')) {
        calculatedBasic = 35000000;
      } else if (posName.contains('manager') || posName.contains('lead')) {
        calculatedBasic = 22000000;
      } else if (posName.contains('senior')) {
        calculatedBasic = 15000000;
      } else if (posName.contains('engineer') || posName.contains('developer') || posName.contains('analyst')) {
        calculatedBasic = 11000000;
      } else if (posName.contains('hr') || posName.contains('recruiter')) {
        calculatedBasic = 8000000;
      }

      basicSalary = calculatedBasic;
      allowanceJob = (basicSalary * 0.08).round(); // 8% position allowance
      allowanceMeal = 600000; // transport/meal allowance
      grossEarnings = basicSalary + allowanceJob + allowanceMeal;

      bpjsKes = (basicSalary * 0.01).round(); // 1%
      bpjsKet = (basicSalary * 0.02).round(); // 2%
      pph21Tax = (basicSalary * 0.05).round(); // 5% PPh21
      totalDeductions = bpjsKes + bpjsKet + pph21Tax;
      netTakeHomePay = grossEarnings - totalDeductions;
    }

    final rpFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Month Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pilih Periode Gaji:',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF151D30),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: DropdownButton<String>(
                  value: _selectedMonth,
                  items: _months.map((String m) {
                    return DropdownMenuItem<String>(
                      value: m,
                      child: Text(m, style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedMonth = val;
                      });
                    }
                  },
                  underline: const SizedBox(),
                  dropdownColor: const Color(0xFF151D30),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Payslip Main Stub Card
          Card(
            color: const Color(0xFF132135),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withOpacity(0.06)),
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Company Name & Watermark
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'PT INDO PORTAL JAYA',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              color: Color(0xFFF1F5F9),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Kawasan Bisnis Sudirman, Jakarta',
                            style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PAID',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 32),

                  // Employee Details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Nama Karyawan', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                          const SizedBox(height: 4),
                          Text(_user?['name'] ?? '-', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('NIK / ID', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                          const SizedBox(height: 4),
                          Text(_user?['nik'] ?? '-', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Jabatan', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                          const SizedBox(height: 4),
                          Text(_user?['position'] ?? '-', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Divisi', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                          const SizedBox(height: 4),
                          Text(_user?['division'] ?? '-', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 32),

                  // 1. EARNINGS (Penerimaan)
                  Row(
                    children: const [
                      Icon(Icons.add_circle_outline_rounded, color: Color(0xFF10B981), size: 16),
                      SizedBox(width: 8),
                      Text(
                        'PENERIMAAN (EARNINGS)',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSalaryItemRow('Gaji Pokok', rpFormat.format(basicSalary)),
                  if (hasCustom) ...[
                    _buildSalaryItemRow('Tunjangan Karyawan', rpFormat.format(allowanceJob)),
                  ] else ...[
                    _buildSalaryItemRow('Tunjangan Jabatan', rpFormat.format(allowanceJob)),
                    _buildSalaryItemRow('Tunjangan Makan & Transport', rpFormat.format(allowanceMeal)),
                  ],
                  const SizedBox(height: 8),
                  const Divider(color: Colors.white10),
                  _buildSalaryItemRow('Total Penerimaan Kotor', rpFormat.format(grossEarnings), isBold: true),
                  const Divider(color: Colors.white10, height: 32),

                  // 2. DEDUCTIONS (Potongan)
                  Row(
                    children: const [
                      Icon(Icons.remove_circle_outline_rounded, color: Color(0xFFEF4444), size: 16),
                      SizedBox(width: 8),
                      Text(
                        'POTONGAN (DEDUCTIONS)',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (hasCustom) ...[
                    _buildSalaryItemRow('Potongan BPJS', rpFormat.format(bpjsKes)),
                    _buildSalaryItemRow('Potongan Pajak PPh 21', rpFormat.format(pph21Tax)),
                  ] else ...[
                    _buildSalaryItemRow('BPJS Kesehatan (1%)', rpFormat.format(bpjsKes)),
                    _buildSalaryItemRow('BPJS Ketenagakerjaan (2%)', rpFormat.format(bpjsKet)),
                    _buildSalaryItemRow('Pajak PPh 21 (5%)', rpFormat.format(pph21Tax)),
                  ],
                  const SizedBox(height: 8),
                  const Divider(color: Colors.white10),
                  _buildSalaryItemRow('Total Potongan Gaji', rpFormat.format(totalDeductions), isBold: true, isRed: true),
                  const Divider(color: Colors.white10, height: 32),

                  // 3. NET TAKE HOME PAY (Gaji Bersih)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF10B981).withOpacity(0.15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'GAJI BERSIH (NET PAY)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF1F5F9),
                          ),
                        ),
                        Text(
                          rpFormat.format(netTakeHomePay),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981), // Green
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Download PDF Action
          ElevatedButton.icon(
            onPressed: () => _handleDownloadPdf(rpFormat.format(netTakeHomePay)),
            icon: const Icon(Icons.file_download_rounded),
            label: const Text('UNDUH SLIP GAJI (PDF)'),
          ),
          const SizedBox(height: 12),
          
          // Lock again button
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _isUnlocked = false;
                _pinCode = '';
              });
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withOpacity(0.12)),
              foregroundColor: const Color(0xFF94A3B8),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.white.withOpacity(0.03),
            ),
            icon: const Icon(Icons.lock_rounded, size: 16),
            label: const Text('KUNCI KEMBALI LAYAR'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSalaryItemRow(String label, String value, {bool isBold = false, bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? const Color(0xFFE2E8F0) : const Color(0xFF94A3B8),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold
                  ? (isRed ? const Color(0xFFEF4444) : const Color(0xFF10B981))
                  : const Color(0xFFE2E8F0),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDownloadPdf(String amount) async {
    final success = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const _DownloadProgressDialog();
      },
    );

    if (success == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('Slip Gaji berhasil diunduh ke folder Dokumen.'),
            ],
          ),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  String strtolower(String val) => val.toLowerCase();
}

// Private helper widget to simulate downloading payslip PDF
class _DownloadProgressDialog extends StatefulWidget {
  const _DownloadProgressDialog();

  @override
  State<_DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<_DownloadProgressDialog> {
  double _progress = 0.0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      setState(() {
        _progress += 0.1;
      });
      if (_progress >= 1.0) {
        _timer.cancel();
        if (mounted) {
          Navigator.pop(context, true); // Close download dialog and return success
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mengunduh Slip Gaji', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.white.withOpacity(0.08),
            color: const Color(0xFF6366F1),
          ),
          const SizedBox(height: 16),
          Text(
            '${(_progress * 100).clamp(0, 100).toInt()}% Selesai...',
            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}
