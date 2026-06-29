import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nikController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _joinDateController = TextEditingController();

  // Selected dropdown values
  int? _selectedDivisionId;
  int? _selectedPositionId;
  int? _selectedShiftId;
  String? _selectedEmploymentType;
  String? _selectedGender;

  // Metadata lists from API
  List<dynamic> _divisions = [];
  List<dynamic> _positions = [];
  List<dynamic> _shifts = [];
  
  final List<Map<String, String>> _employmentTypes = [
    {'value': 'permanent', 'label': 'Permanen'},
    {'value': 'contract', 'label': 'Kontrak'},
    {'value': 'internship', 'label': 'Magang'},
    {'value': 'freelance', 'label': 'Pekerja Lepas'},
  ];

  final List<String> _genders = ['Laki-laki', 'Perempuan'];

  bool _isLoadingMeta = true;
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFormMeta();
  }

  @override
  void dispose() {
    _nikController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _joinDateController.dispose();
    super.dispose();
  }

  Future<void> _loadFormMeta() async {
    final response = await ApiService.getHrFormMeta();

    if (!mounted) return;

    if (response['success'] == true) {
      setState(() {
        _divisions = response['divisions'] ?? [];
        _positions = response['positions'] ?? [];
        _shifts = response['shifts'] ?? [];
        _isLoadingMeta = false;
      });
    } else {
      setState(() {
        _isLoadingMeta = false;
        _errorMessage = response['message'] ?? 'Gagal memuat pilihan departemen/jabatan.';
      });
    }
  }

  Future<void> _selectJoinDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              surface: Color(0xFF151D30),
              onSurface: Color(0xFFF1F5F9),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _joinDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDivisionId == null ||
        _selectedPositionId == null ||
        _selectedShiftId == null ||
        _selectedEmploymentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua pilihan dropdown (Divisi, Jabatan, Shift, Tipe Kontrak).'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await ApiService.createEmployee(
      nik: _nikController.text.trim(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      divisionId: _selectedDivisionId!,
      positionId: _selectedPositionId!,
      shiftId: _selectedShiftId!,
      employmentType: _selectedEmploymentType!,
      joinDate: _joinDateController.text,
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      gender: _selectedGender,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('Karyawan baru berhasil terdaftar!'),
            ],
          ),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context, true); // Return true to trigger refresh!
    } else {
      setState(() {
        _errorMessage = result['message'] ?? 'Gagal mendaftarkan karyawan baru.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DAFTAR KARYAWAN BARU'),
      ),
      body: _isLoadingMeta
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.1),
                          border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // 1. Kredensial Akun
                    const Text('KREDENSIAL LOGIN & AKUN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nikController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'NIK (Nomor Induk Karyawan)',
                        prefixIcon: Icon(Icons.badge_outlined, size: 20),
                        hintText: 'Contoh: 202606001',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'NIK wajib diisi.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap Karyawan',
                        prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                        hintText: 'Contoh: John Doe',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Nama Lengkap wajib diisi.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Alamat Email',
                        prefixIcon: Icon(Icons.email_outlined, size: 20),
                        hintText: 'nama@perusahaan.com',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Email wajib diisi.';
                        final emailRegExp = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                        if (!emailRegExp.hasMatch(value.trim())) return 'Format email tidak valid.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Kata Sandi Awal',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Kata sandi wajib diisi.';
                        if (value.length < 6) return 'Kata sandi minimal 6 karakter.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // 2. Data Pekerjaan
                    const Text('DETAIL PEKERJAAN & KONTRAK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    const SizedBox(height: 12),
                    
                    // Division Dropdown
                    DropdownButtonFormField<int>(
                      value: _selectedDivisionId,
                      decoration: const InputDecoration(
                        labelText: 'Pilih Divisi / Departemen',
                        prefixIcon: Icon(Icons.business_rounded, size: 20),
                      ),
                      dropdownColor: const Color(0xFF151D30),
                      items: _divisions.map((d) {
                        return DropdownMenuItem<int>(
                          value: d['id'] as int,
                          child: Text(d['name'] as String, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedDivisionId = val),
                    ),
                    const SizedBox(height: 16),

                    // Position Dropdown
                    DropdownButtonFormField<int>(
                      value: _selectedPositionId,
                      decoration: const InputDecoration(
                        labelText: 'Pilih Jabatan',
                        prefixIcon: Icon(Icons.work_outline_rounded, size: 20),
                      ),
                      dropdownColor: const Color(0xFF151D30),
                      items: _positions.map((p) {
                        return DropdownMenuItem<int>(
                          value: p['id'] as int,
                          child: Text(p['name'] as String, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedPositionId = val),
                    ),
                    const SizedBox(height: 16),

                    // Shift Dropdown
                    DropdownButtonFormField<int>(
                      value: _selectedShiftId,
                      decoration: const InputDecoration(
                        labelText: 'Pilih Shift Kerja Utama',
                        prefixIcon: Icon(Icons.timer_outlined, size: 20),
                      ),
                      dropdownColor: const Color(0xFF151D30),
                      items: _shifts.map((s) {
                        return DropdownMenuItem<int>(
                          value: s['id'] as int,
                          child: Text('${s['name']} (${s['start_time']} - ${s['end_time']})', style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedShiftId = val),
                    ),
                    const SizedBox(height: 16),

                    // Employment Type Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedEmploymentType,
                      decoration: const InputDecoration(
                        labelText: 'Pilih Tipe Kontrak Kerja',
                        prefixIcon: Icon(Icons.assignment_ind_outlined, size: 20),
                      ),
                      dropdownColor: const Color(0xFF151D30),
                      items: _employmentTypes.map((t) {
                        return DropdownMenuItem<String>(
                          value: t['value'],
                          child: Text(t['label']!, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedEmploymentType = val),
                    ),
                    const SizedBox(height: 16),

                    // Join Date DatePicker
                    TextFormField(
                      controller: _joinDateController,
                      readOnly: true,
                      onTap: _selectJoinDate,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Masuk Kerja',
                        prefixIcon: Icon(Icons.calendar_today_rounded, size: 20),
                        hintText: 'Pilih Tanggal...',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Tanggal Masuk Kerja wajib diisi.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // 3. Data Opsional
                    const Text('INFORMASI TAMBAHAN (OPSIONAL)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Telepon Seluler',
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                        hintText: 'Contoh: 0812XXXXXXXX',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Kelamin',
                        prefixIcon: Icon(Icons.wc_rounded, size: 20),
                      ),
                      dropdownColor: const Color(0xFF151D30),
                      items: _genders.map((g) {
                        return DropdownMenuItem<String>(
                          value: g,
                          child: Text(g, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedGender = val),
                    ),
                    const SizedBox(height: 40),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text('DAFTARKAN KARYAWAN'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
