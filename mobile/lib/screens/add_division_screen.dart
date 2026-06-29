import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddDivisionScreen extends StatefulWidget {
  const AddDivisionScreen({super.key});

  @override
  State<AddDivisionScreen> createState() => _AddDivisionScreenState();
}

class _AddDivisionScreenState extends State<AddDivisionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final response = await ApiService.createDivision(
      name: _nameController.text.trim(),
      code: _codeController.text.trim().toUpperCase(),
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Divisi baru berhasil ditambahkan!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context, true);
    } else {
      setState(() {
        _errorMessage = response['message'] ?? 'Gagal menambahkan divisi baru.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TAMBAH DIVISI BARU'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 13),
                  ),
                ),
              
              // Nama Divisi Input
              const Text(
                'Nama Divisi',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Masukkan nama divisi (misal: Finance & Accounting)',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama divisi wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Kode Divisi Input
              const Text(
                'Kode Divisi',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _codeController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Masukkan kode singkatan divisi (misal: FIN)',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kode divisi wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('SIMPAN DIVISI'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
