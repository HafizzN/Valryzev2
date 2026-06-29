import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/api_service.dart';

class CheckOutScreen extends StatefulWidget {
  final Map<String, dynamic> attendance;

  const CheckOutScreen({
    super.key,
    required this.attendance,
  });

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  // Camera variables
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  XFile? _capturedPhoto;
  
  // GPS & Geofencing variables
  Position? _currentPosition;
  bool _isGpsLoading = true;
  bool _isFakeGpsDetected = false;
  double _distanceToOffice = 999999.0;
  Map<String, dynamic>? _selectedOffice;
  bool _isWithinRadius = false;
  
  // Submit variables
  bool _isSubmitting = false;
  String? _statusMessage;

  // Office locations loaded from profile API
  List<dynamic> _officeLocations = [];

  @override
  void initState() {
    super.initState();
    _initializePermissionsAndServices();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializePermissionsAndServices() async {
    setState(() {
      _isGpsLoading = true;
      _statusMessage = 'Meminta izin lokasi dan kamera...';
    });

    // 1. Request OS Permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.locationWhenInUse,
      Permission.camera,
    ].request();

    if (statuses[Permission.locationWhenInUse]!.isGranted &&
        statuses[Permission.camera]!.isGranted) {
      
      // Load office locations first
      await _loadOfficeLocations();
      
      // Initialize Camera and GPS concurrently
      await Future.wait([
        _initCamera(),
        _initGPS(),
      ]);
    } else {
      setState(() {
        _isGpsLoading = false;
        _statusMessage = 'Izin kamera dan lokasi ditolak. Harap berikan izin di pengaturan ponsel Anda.';
      });
    }
  }

  Future<void> _loadOfficeLocations() async {
    final profile = await ApiService.getProfile();
    if (profile['success'] == true) {
      _officeLocations = profile['office_locations'] ?? [];
    }
  }

  /// Initialize front-facing camera
  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) return;

      CameraDescription? frontCamera;
      for (var camera in _cameras!) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
          break;
        }
      }

      frontCamera ??= _cameras!.first;

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Camera init error: $e');
      }
    }
  }

  /// Fetch location, check for Fake GPS, and evaluate geofence
  Future<void> _initGPS() async {
    try {
      setState(() {
        _isGpsLoading = true;
      });

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isGpsLoading = false;
          _statusMessage = 'Layanan GPS/Lokasi di ponsel Anda dinonaktifkan.';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final bool isMocked = position.isMocked;

      _currentPosition = position;
      _isFakeGpsDetected = isMocked;

      _evaluateGeofence(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          _isGpsLoading = false;
          _statusMessage = _isFakeGpsDetected 
              ? '⚠️ Terdeteksi penggunaan GPS Palsu!'
              : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGpsLoading = false;
          _statusMessage = 'Gagal mendapatkan koordinat GPS: $e';
        });
      }
    }
  }

  /// Evaluate geofencing
  void _evaluateGeofence(double userLat, double userLng) {
    if (_officeLocations.isEmpty) return;

    double nearestDistance = 99999999.0;
    Map<String, dynamic>? nearestOffice;

    for (var office in _officeLocations) {
      final double officeLat = office['latitude'];
      final double officeLng = office['longitude'];
      
      final double distance = Geolocator.distanceBetween(
        userLat,
        userLng,
        officeLat,
        officeLng,
      );

      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestOffice = office;
      }
    }

    if (nearestOffice != null) {
      final int allowedRadius = nearestOffice['radius'] ?? 100;
      
      setState(() {
        _distanceToOffice = nearestDistance;
        _selectedOffice = nearestOffice;
        _isWithinRadius = nearestDistance <= allowedRadius;
      });
    }
  }

  /// Capture photo
  Future<void> _takePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _capturedPhoto = photo;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto: $e')),
      );
    }
  }

  Future<void> _submitCheckOut() async {
    if (_capturedPhoto == null || _currentPosition == null) return;

    setState(() {
      _isSubmitting = true;
      _statusMessage = null;
    });

    try {
      // Submit to API using raw file path (binary multipart)
      final result = await ApiService.checkOut(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        accuracy: _currentPosition!.accuracy,
        photoPath: _capturedPhoto!.path,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _isSubmitting = false;
        });
        await _showSuccessDialog(result['message'] ?? 'Absen pulang berhasil! Sampai jumpa besok.');
        if (mounted) {
          Navigator.pop(context); // Return to home screen
        }
      } else {
        setState(() {
          _isSubmitting = false;
          _statusMessage = result['message'] ?? 'Gagal memproses absensi.';
        });
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _statusMessage = 'Terjadi kesalahan sistem: $e';
      });
    }
  }

  Future<void> _showSuccessDialog(String message) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
            SizedBox(width: 8),
            Text('Sukses Pulang'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali ke Dashboard', style: TextStyle(color: Color(0xFF6366F1))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canSubmit = _capturedPhoto != null &&
        _currentPosition != null &&
        !_isFakeGpsDetected &&
        _isWithinRadius &&
        !_isSubmitting;

    final String shiftName = widget.attendance['shift_name'] ?? 'Shift Aktif';
    final String checkInTime = widget.attendance['check_in_time'] ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text('ABSEN PULANG'),
      ),
      body: _isSubmitting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Mengunggah presensi & koordinat...', style: TextStyle(color: Color(0xFF94A3B8))),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Alert Messages (Error/Fake GPS/Geofence Block)
                  if (_statusMessage != null || _isFakeGpsDetected || (_currentPosition != null && !_isWithinRadius))
                    _buildAlertCard(),
                  
                  const SizedBox(height: 12),

                  // 2. Front Camera Circular Preview
                  Center(child: _buildCameraContainer()),
                  const SizedBox(height: 20),

                  // 3. Shift Information Card (from checked in record)
                  _buildShiftInfoCard(shiftName, checkInTime),
                  const SizedBox(height: 16),

                  // 4. GPS Geofencing Status Info Card
                  _buildGpsStatusCard(),
                  const SizedBox(height: 24),

                  // 5. Submit Button
                  ElevatedButton(
                    onPressed: canSubmit ? _submitCheckOut : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary, // Emerald Green
                      disabledBackgroundColor: const Color(0xFF1E293B),
                    ),
                    child: const Text('KIRIM ABSEN PULANG'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAlertCard() {
    String message = _statusMessage ?? '';
    Color color = Theme.of(context).colorScheme.error;

    if (_isFakeGpsDetected) {
      message = '⚠️ FAKE GPS TERDETEKSI!\nSistem keamanan mendeteksi Anda menggunakan lokasi palsu. Absensi ditolak otomatis.';
    } else if (_currentPosition != null && !_isWithinRadius) {
      message = '❌ DI LUAR RADIUS KANTOR!\nJarak Anda saat ini ${_distanceToOffice.toStringAsFixed(0)}m dari kantor ${_selectedOffice?['name'] ?? ''}. Anda harus berada dalam radius ${_selectedOffice?['radius'] ?? 100}m.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.25)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildCameraContainer() {
    const double size = 220.0;

    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _capturedPhoto != null 
                  ? Theme.of(context).colorScheme.secondary 
                  : Theme.of(context).colorScheme.primary.withOpacity(0.4),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              )
            ]
          ),
          child: ClipOval(
            child: _capturedPhoto != null
                ? Image.file(
                    File(_capturedPhoto!.path),
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                  )
                : _isCameraInitialized
                    ? FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: 100,
                          height: 100 * _cameraController!.value.aspectRatio,
                          child: CameraPreview(_cameraController!),
                        ),
                      )
                    : Container(
                        color: const Color(0xFF0F172A),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
          ),
        ),
        const SizedBox(height: 12),
        if (_capturedPhoto != null)
          TextButton.icon(
            onPressed: () {
              setState(() {
                _capturedPhoto = null;
              });
            },
            icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF64748B)),
            label: const Text('Foto Ulang', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          )
        else
          ElevatedButton.icon(
            onPressed: _isCameraInitialized ? _takePhoto : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(140, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              foregroundColor: Theme.of(context).colorScheme.secondary,
              side: BorderSide(color: Theme.of(context).colorScheme.secondary.withOpacity(0.4)),
            ),
            icon: const Icon(Icons.camera_front_rounded, size: 16),
            label: const Text('Ambil Selfie', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildShiftInfoCard(String shiftName, String checkInTime) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'INFORMASI SHIFT AKTIF',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Shift Kerja:', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                Text(
                  shiftName,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Jam Absen Masuk:', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                Text(
                  "$checkInTime WIB",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGpsStatusCard() {
    final bool hasLocation = _currentPosition != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'VALIDASI LOKASI (GPS)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: Color(0xFF64748B),
                  ),
                ),
                if (_isGpsLoading)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  )
                else
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF6366F1)),
                    onPressed: _initGPS,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (_isGpsLoading) ...[
              const Text('Sedang mengunci koordinat GPS...', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ] else if (hasLocation) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kantor Terdekat:', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  Text(
                    _selectedOffice?['name'] ?? '-',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Jarak Anda:', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  Text(
                    "${_distanceToOffice.toStringAsFixed(1)} meter",
                    style: TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.bold, 
                      color: _isWithinRadius ? const Color(0xFF10B981) : const Color(0xFFEF4444)
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Status Radius:', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  Text(
                    _isWithinRadius ? 'Dalam Radius Kantor' : 'Di Luar Radius Kantor',
                    style: TextStyle(
                      fontSize: 11, 
                      fontWeight: FontWeight.bold, 
                      color: _isWithinRadius ? const Color(0xFF10B981) : const Color(0xFFEF4444)
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Akurasi Sensor:', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  Text(
                    "${_currentPosition!.accuracy.toStringAsFixed(1)}m",
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ] else ...[
              const Text('Koordinat GPS belum didapatkan.', style: TextStyle(fontSize: 12, color: Color(0xFFEF4444))),
            ],
          ],
        ),
      ),
    );
  }
}
