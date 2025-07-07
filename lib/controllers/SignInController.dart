import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ohud/controllers/HomeController.dart';
import 'package:ohud/screens/HomeScreen.dart';
import 'package:ohud/utils/EndPoints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SigninController extends GetxController {
  var obscure = true.obs;
  var isLoading = false.obs;

  void toggleObscure() => obscure.value = !obscure.value;

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar("تنبيه", "يرجى ملء جميع الحقول", colorText: Colors.black);
      return;
    }

    if (password.length < 8) {
      Get.snackbar(
        "تنبيه",
        "كلمة المرور يجب أن تكون 8 أحرف على الأقل",
        colorText: Colors.black,
      );
      return;
    }

    isLoading.value = true;

    var headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    try {
      var url = Uri.parse(
        APIEndpoints.baseUrl + APIEndpoints.authEndPoint.login,
      );
      Map body = {'name': username, 'password': password};

      http.Response response = await http
          .post(url, body: jsonEncode(body), headers: headers)
          .timeout(const Duration(seconds: 10));

      print("Response: ${response.body}");
      print(response.request);
      print(body);
      final json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // ✅ إذا كانت الاستجابة ناجحة
        if (json['token'] != null && json['user'] != null) {
          var token = json['token'];
          var user = json['user'];
          var userId = user['id'];
          var userName = user['name'];
          var circleId = user['circle_id'];

          // حفظ البيانات في SharedPreferences
          final SharedPreferences prefs = await _prefs;
          await prefs.setString('token', token);
          await prefs.setInt('user_id', userId);
          await prefs.setString('user_name', userName);
          await prefs.setInt('circle_id', circleId);
          await prefs.setBool('isLoggedIn', true); // ✅ هذا هو السطر المفقود

          usernameController.clear();
          passwordController.clear();
          Get.lazyPut(() => HomeController());
          Get.offAll(() => HomeScreen());
        } else {
          // إذا لم يكن هناك توكن أو مستخدم في الاستجابة
          Get.snackbar(
            "فشل",
            json["message"] ?? "فشل تسجيل الدخول",
            colorText: Colors.black,
          );
        }
      } else if (response.statusCode == 401) {
        // ✅ إذا كانت الاستجابة تحتوي على خطأ في التحقق من البيانات
        if (json["message"] == "the pasword is not correct") {
          // هنا يجب معالجة رسالة خطأ كلمة المرور غير الصحيحة
          Get.snackbar("خطأ", "كلمة المرور غير صحيحة", colorText: Colors.black);
        } else if (json["message"] == "Validation error.") {
          if (json["errors"] != null) {
            if (json["errors"]["name"] != null) {
              Get.snackbar(
                "خطأ",
                "خطأ في اسم المستخدم",
                colorText: Colors.black,
              );
            } else if (json["errors"]["password"] != null) {
              // إذا كان الخطأ في كلمة المرور فقط
              Get.snackbar(
                "خطأ",
                "كلمة المرور غير صحيحة",
                colorText: Colors.black,
              );
            } else {
              Get.snackbar(
                "خطأ",
                "حدث خطأ في البيانات المدخلة",
                colorText: Colors.black,
              );
            }
          }
        } else {
          Get.snackbar("خطأ", json["message"], colorText: Colors.black);
        }
      } else {
        // ✅ إذا كان هناك خطأ غير متوقع
        Get.snackbar(
          "خطأ",
          "حدث خطأ في الاتصال بالخادم",
          colorText: Colors.black,
        );
      }
    } on http.ClientException {
      Get.snackbar(
        "خطأ في الشبكة",
        "تحقق من اتصال الإنترنت",
        colorText: Colors.black,
      );
    } on TimeoutException {
      Get.snackbar(
        "مهلة الاتصال",
        "الخادم لا يستجيب، حاول مرة أخرى",
        colorText: Colors.black,
      );
    } catch (e) {
      // ✅ إذا كانت هناك مشكلة غير متوقعة
      Get.snackbar("خطأ", e.toString(), colorText: Colors.black);
    } finally {
      isLoading.value = false;
    }
  }
}
