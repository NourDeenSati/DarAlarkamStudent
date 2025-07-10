import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../themes/custom_exception.dart';
import '../../themes/error_codes.dart';
import '../../utils/EndPoints.dart';
import '../modules/note.dart';

class ApiService {
  static Future<List> getOneDetails({
    required int pageNumber,
    required String studentId,
  }) async {
    if (pageNumber > 604 || pageNumber < 1 ) {
      throw CustomException(ErrorCodes.outOfRange);
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("token") == null) {
      throw CustomException(ErrorCodes.userIsNotRegestired);
    }
    String token = prefs.getString("token")!;

    var response = await http.get(
      Uri.parse(APIEndpoints.baseUrl + APIEndpoints.mushafEndPoints.getDetailsRec(int.parse(studentId))),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      Map body = jsonDecode(response.body);

        return body["mistakes"]??[];

    } else {
      Map body = jsonDecode(response.body);
        throw CustomException(body["message"]??ErrorCodes.noInternetConnection);

    }
  }

  static getMultiDetails({required int startPage, required int endPage, required String saberId}) async {
    if (startPage > 604 || startPage < 1||endPage > 604 || endPage < 1 ) {
      throw CustomException(ErrorCodes.outOfRange);
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("token") == null) {
      throw CustomException(ErrorCodes.userIsNotRegestired);
    }
    String token = prefs.getString("token")!;

    var response = await http.get(
      Uri.parse(APIEndpoints.baseUrl + APIEndpoints.mushafEndPoints.getDetailsSaber(int.parse(saberId))),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      Map body = jsonDecode(response.body);

      return body["mistakes"]??[];

    } else {
      Map body = jsonDecode(response.body);
      throw CustomException(body["message"]??ErrorCodes.noInternetConnection);

    }
  }

}
