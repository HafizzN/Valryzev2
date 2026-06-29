import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator to connect to localhost on host machine.
  // Change this to your computer's local IP (e.g. 192.168.1.X) when testing on a physical device.
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static const String _tokenKey = 'api_token';
  static const String _userKey = 'user_data';

  /// Save API token to SharedPreferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Get API token from SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Save User data to SharedPreferences
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  /// Get User data from SharedPreferences
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      return jsonDecode(userStr) as Map<String, dynamic>;
    }
    return null;
  }

  /// Check if user is currently logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear session on logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  /// Standard Headers helper
  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// POST /login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final token = data['token'] as String;
        final userData = data['user'] as Map<String, dynamic>;
        await saveToken(token);
        await saveUserData(userData);
      }

      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal menghubungkan ke server: $e',
      };
    }
  }

  /// GET /profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: headers,
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengambil profil: $e',
      };
    }
  }

  /// POST /attendance/check-in (Multipart)
  static Future<Map<String, dynamic>> checkIn({
    required double latitude,
    required double longitude,
    required double accuracy,
    required String photoPath,
    required int shiftId,
    String? address,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/attendance/check-in');
      var request = http.MultipartRequest('POST', uri);

      final headers = await _getHeaders();
      request.headers.addAll(headers);

      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      request.fields['accuracy'] = accuracy.toString();
      request.fields['shift_id'] = shiftId.toString();
      request.fields['address'] = address ?? '';

      request.files.add(await http.MultipartFile.fromPath('photo', photoPath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengirim absen masuk: $e',
      };
    }
  }

  /// POST /attendance/check-out (Multipart)
  static Future<Map<String, dynamic>> checkOut({
    required double latitude,
    required double longitude,
    required double accuracy,
    required String photoPath,
    String? address,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/attendance/check-out');
      var request = http.MultipartRequest('POST', uri);

      final headers = await _getHeaders();
      request.headers.addAll(headers);

      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      request.fields['accuracy'] = accuracy.toString();
      request.fields['address'] = address ?? '';

      request.files.add(await http.MultipartFile.fromPath('photo', photoPath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengirim absen pulang: $e',
      };
    }
  }

  /// GET /attendance/history
  static Future<Map<String, dynamic>> getHistory(String month) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/attendance/history?month=$month'),
        headers: headers,
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memuat riwayat absensi: $e',
      };
    }
  }

  /// GET /announcements
  static Future<Map<String, dynamic>> getAnnouncements() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/announcements'),
        headers: headers,
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memuat pengumuman: $e',
      };
    }
  }

  /// POST /announcements
  static Future<Map<String, dynamic>> createAnnouncement({
    required String title,
    required String content,
    required String category,
    required bool isPinned,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/announcements'),
        headers: headers,
        body: jsonEncode({
          'title': title,
          'content': content,
          'category': category,
          'is_pinned': isPinned,
        }),
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal membuat pengumuman: $e',
      };
    }
  }

  /// GET /leave-requests
  static Future<Map<String, dynamic>> getLeaveRequests() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/leave-requests'),
        headers: headers,
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memuat riwayat cuti: $e',
      };
    }
  }

  /// POST /leave-requests (Multipart)
  static Future<Map<String, dynamic>> createLeaveRequest({
    required String leaveType,
    required String startDate,
    required String endDate,
    required String reason,
    String? attachmentPath,
    String? attachmentName,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/leave-requests');
      var request = http.MultipartRequest('POST', uri);

      final headers = await _getHeaders();
      request.headers.addAll(headers);

      request.fields['leave_type'] = leaveType;
      request.fields['start_date'] = startDate;
      request.fields['end_date'] = endDate;
      request.fields['reason'] = reason;

      if (attachmentPath != null) {
        request.files.add(await http.MultipartFile.fromPath('attachment', attachmentPath));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengirim pengajuan cuti: $e',
      };
    }
  }

  /// GET /permission-requests
  static Future<Map<String, dynamic>> getPermissionRequests() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/permission-requests'),
        headers: headers,
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memuat riwayat izin: $e',
      };
    }
  }

  /// POST /permission-requests (Multipart)
  static Future<Map<String, dynamic>> createPermissionRequest({
    required String permissionType,
    required String date,
    String? endDate,
    String? startTime,
    String? endTime,
    required String reason,
    String? attachmentPath,
    String? attachmentName,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/permission-requests');
      var request = http.MultipartRequest('POST', uri);

      final headers = await _getHeaders();
      request.headers.addAll(headers);

      request.fields['permission_type'] = permissionType;
      request.fields['date'] = date;
      if (endDate != null) request.fields['end_date'] = endDate;
      if (startTime != null) request.fields['start_time'] = startTime;
      if (endTime != null) request.fields['end_time'] = endTime;
      request.fields['reason'] = reason;

      if (attachmentPath != null) {
        request.files.add(await http.MultipartFile.fromPath('attachment', attachmentPath));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengirim pengajuan izin: $e',
      };
    }
  }

  /// GET /overtime-requests
  static Future<Map<String, dynamic>> getOvertimeRequests() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/overtime-requests'),
        headers: headers,
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memuat riwayat lembur: $e',
      };
    }
  }

  /// POST /overtime-requests
  static Future<Map<String, dynamic>> createOvertimeRequest({
    required String date,
    required String startTime,
    required String endTime,
    required String reason,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/overtime-requests'),
        headers: headers,
        body: jsonEncode({
          'date': date,
          'start_time': startTime,
          'end_time': endTime,
          'reason': reason,
        }),
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengirim pengajuan lembur: $e',
      };
    }
  }

  // ==========================================
  // MANAGER API METHODS
  // ==========================================

  /// GET /manager/dashboard-stats
  static Future<Map<String, dynamic>> getManagerStats() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/manager/dashboard-stats'),
        headers: headers,
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memuat statistik manager: $e',
      };
    }
  }

  /// GET /manager/my-team
  static Future<Map<String, dynamic>> getManagerTeam() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/manager/my-team'),
        headers: headers,
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memuat daftar tim: $e',
      };
    }
  }

  /// GET /manager/team-attendance
  static Future<Map<String, dynamic>> getManagerTeamAttendance() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/manager/team-attendance'),
        headers: headers,
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memuat kehadiran tim: $e',
      };
    }
  }

  /// GET /manager/approvals
  static Future<Map<String, dynamic>> getManagerApprovals() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/manager/approvals'),
        headers: headers,
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memuat data persetujuan: $e',
      };
    }
  }

  /// POST /manager/approvals/{type}/{id}
  static Future<Map<String, dynamic>> processManagerApproval({
    required String type,
    required int id,
    required String action,
    String? rejectionReason,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/manager/approvals/$type/$id'),
        headers: headers,
        body: jsonEncode({
          'action': action,
          'rejection_reason': ?rejectionReason,
        }),
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memproses persetujuan: $e',
      };
    }
  }

  // ==========================================
  // HRD API METHODS
  // ==========================================

  /// GET /hr/employees
  static Future<Map<String, dynamic>> getHrEmployees() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/hr/employees'),
        headers: headers,
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memuat direktori karyawan: $e',
      };
    }
  }

  /// GET /hr/recruitment-onboarding
  static Future<Map<String, dynamic>> getHrRecruitmentOnboarding() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/hr/recruitment-onboarding'),
        headers: headers,
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memuat rekrutmen & onboarding: $e',
      };
    }
  }

  /// GET /hr/payroll-summary
  static Future<Map<String, dynamic>> getHrPayrollSummary() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/hr/payroll-summary'),
        headers: headers,
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memuat ringkasan payroll: $e',
      };
    }
  }

  /// GET /manager/payroll-summary
  static Future<Map<String, dynamic>> getManagerPayrollSummary() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/manager/payroll-summary'),
        headers: headers,
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memuat ringkasan payroll tim: $e',
      };
    }
  }

  /// PUT /hr/payroll/{id}
  static Future<Map<String, dynamic>> updateHrEmployeePayroll({
    required int id,
    required double basicSalary,
    required double allowance,
    required double bpjsDeduction,
    required double taxDeduction,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/hr/payroll/$id'),
        headers: headers,
        body: jsonEncode({
          'basic_salary': basicSalary,
          'allowance': allowance,
          'bpjs_deduction': bpjsDeduction,
          'tax_deduction': taxDeduction,
        }),
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memperbarui pengaturan gaji: $e',
      };
    }
  }

  /// GET /hr/approvals
  static Future<Map<String, dynamic>> getHrApprovals() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/hr/approvals'),
        headers: headers,
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memuat persetujuan HR: $e',
      };
    }
  }

  /// POST /hr/approvals/{type}/{id}
  static Future<Map<String, dynamic>> processHrApproval({
    required String type,
    required int id,
    required String action,
    String? rejectionReason,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/hr/approvals/$type/$id'),
        headers: headers,
        body: jsonEncode({
          'action': action,
          'rejection_reason': ?rejectionReason,
        }),
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memproses persetujuan HR: $e',
      };
    }
  }

  /// GET /hr/form-meta
  static Future<Map<String, dynamic>> getHrFormMeta() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/hr/form-meta'),
        headers: headers,
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengambil pilihan departemen/jabatan: $e',
      };
    }
  }

  /// POST /hr/employees
  static Future<Map<String, dynamic>> createEmployee({
    required String nik,
    required String name,
    required String email,
    required String password,
    required int divisionId,
    required int positionId,
    required int shiftId,
    required String employmentType,
    required String joinDate,
    String? phone,
    String? gender,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/hr/employees'),
        headers: headers,
        body: jsonEncode({
          'nik': nik,
          'name': name,
          'email': email,
          'password': password,
          'division_id': divisionId,
          'position_id': positionId,
          'shift_id': shiftId,
          'employment_type': employmentType,
          'join_date': joinDate,
          'phone': ?phone,
          'gender': ?gender,
        }),
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mendaftarkan karyawan baru: $e',
      };
    }
  }

  /// GET /hr/divisions
  static Future<Map<String, dynamic>> getHrDivisions() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/hr/divisions'),
        headers: headers,
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengambil data divisi: $e',
      };
    }
  }

  /// POST /hr/divisions
  static Future<Map<String, dynamic>> createDivision({
    required String name,
    required String code,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/hr/divisions'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'code': code,
        }),
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal menambahkan divisi baru: $e',
      };
    }
  }

  /// GET /notifications
  static Future<Map<String, dynamic>> getNotifications() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: headers,
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengambil data notifikasi: $e',
      };
    }
  }

  /// POST /notifications/{id}/read
  static Future<Map<String, dynamic>> readNotification(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/$id/read'),
        headers: headers,
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal menandai notifikasi dibaca: $e',
      };
    }
  }

  /// POST /notifications/read-all
  static Future<Map<String, dynamic>> readAllNotifications() async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: headers,
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal menandai semua notifikasi: $e',
      };
    }
  }

  /// POST /profile/photo (Multipart)
  static Future<Map<String, dynamic>> updateProfilePhoto(String photoPath) async {
    try {
      var uri = Uri.parse('$baseUrl/profile/photo');
      var request = http.MultipartRequest('POST', uri);

      final headers = await _getHeaders();
      request.headers.addAll(headers);

      request.files.add(await http.MultipartFile.fromPath('photo', photoPath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memperbarui foto profil: $e',
      };
    }
  }

  /// POST /profile/fcm-token
  static Future<Map<String, dynamic>> updateFcmToken(String token) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/profile/fcm-token'),
        headers: headers,
        body: jsonEncode({'fcm_token': token}),
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memperbarui token FCM: $e',
      };
    }
  }
}


