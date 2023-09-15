import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

class ApiHelper {
  static Future<bool> checkInternetStatus() async {
    bool status = false;
    try {
      final result = await InternetAddress.lookup('example.com')
          .timeout(const Duration(seconds: 20));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        status = true;
      }
    } on SocketException catch (_) {
      status = false;
    } catch (e) {
      status = false;
    }
    return status;
  }

  static Future<void> postData(
      {required String url,
      required Map<String, dynamic> data,
      required bool isJsonData}) async {
    Dio dio = Dio();
    try {
      Response apiResponse = await dio.post(url,
          options: Options(
            receiveTimeout: const Duration(seconds: 30),
            headers: isJsonData ? {'Content-Type': 'application/json'} : {},
            validateStatus: (status) {
              return status! <= 400;
            },
          ),
          data: isJsonData ? json.encode(data) : FormData.fromMap(data));
      //  log(apiResponse.data.toString());
      if (apiResponse.statusCode == 200) {
      } else if (apiResponse.statusCode == 400) {}
    } catch (e) {}
  }
}
