// controllers/student_archive_controller.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ohud/models/ArchiveModel.dart';
import 'package:ohud/utils/EndPoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentArchiveController extends GetxController {
  // Rx lists / objects
  var notes = <NoteModel>[].obs;
  var attendance = Rxn<AttendanceModel>();
  var recitations = <RecitationHistoryRecord>[].obs;
  var sabrs = <SabrHistoryRecord>[].obs;
  var isLoading = false.obs;

  // helper to get token + headers
  Future<Map<String, String>> _buildHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> fetchNotes() async {
    isLoading.value = true;
    final headers = await _buildHeaders();
    final res = await http.get(
      Uri.parse('${APIEndpoints.baseUrl}student/notes'),
      headers: headers,
    );
    print(res.request);
    print(res.body);
    if (res.statusCode == 200) {
      final list = json.decode(res.body) as List;
      notes.value =
          list
              .map((e) => NoteModel.fromJson(e as Map<String, dynamic>))
              .toList();
    } else {
      Get.snackbar('خطأ', 'فشل في جلب الملاحظات (${res.statusCode})');
    }
    isLoading.value = false;
  }

  Future<void> fetchAttendance() async {
    isLoading.value = true;
    final headers = await _buildHeaders();
    final res = await http.get(
      Uri.parse('${APIEndpoints.baseUrl}student/attendance'),
      headers: headers,
    );
    if (res.statusCode == 200) {
      final jsonMap = json.decode(res.body) as Map<String, dynamic>;
      attendance.value = AttendanceModel.fromJson(jsonMap);
    } else {
      Get.snackbar('خطأ', 'فشل في جلب الحضور (${res.statusCode})');
    }
    isLoading.value = false;
  }

  Future<void> fetchRecitations() async {
    recitations.value = [];
    isLoading.value = true;
    final headers = await _buildHeaders();
    final res = await http.get(
      Uri.parse('${APIEndpoints.baseUrl}student/recitations'),
      headers: headers,
    );

    if (res.statusCode == 200) {
      List<Map<String, dynamic>> items = jsonDecode(res.body)["items"].cast<Map<String,dynamic>>();
      for (var item in items) {
        recitations.add(RecitationHistoryRecord.fromJson(item));
      }
    } else {
      Get.snackbar('خطأ', 'فشل في جلب سجل التسميع (${res.statusCode})');
    }
    isLoading.value = false;
  }

  Future<void> fetchSabrs() async {
    sabrs.value=[];
    isLoading.value = true;
    final headers = await _buildHeaders();
    final res = await http.get(
      Uri.parse('${APIEndpoints.baseUrl}student/sabrs'),
      headers: headers,
    );
    if (res.statusCode == 200) {
      List<Map<String, dynamic>> items = jsonDecode(res.body)["items"].cast<Map<String,dynamic>>();
      for (var item in items) {
        sabrs.add(SabrHistoryRecord.fromJson(item));
      }

    } else {
      Get.snackbar('خطأ', 'فشل في جلب سجل السبر (${res.statusCode})');
    }
    isLoading.value = false;
  }
}
