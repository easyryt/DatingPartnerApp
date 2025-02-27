import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:gad_fly_partner/constant/api_end_point.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class MainApplicationController extends GetxController {
  var pageIdx = 0.obs;
  var authToken = ''.obs;
  var selectedStatus = 'Offline'.obs;
  var currentCallId = ''.obs;

  Future profileCreate(requestBody) async {
    Uri uri = Uri.parse('${ApiEndpoints.baseUrl}/partner/personalInfo/create');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          "x-partner-token": authToken.value,
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);

        final data = responseData['data'];
        return responseData;
      } else {
        final responseData = json.decode(response.body);
        return null;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error occurred: $error');
      }
      return null;
    }
  }

  Future<bool> checkMicrophonePermission() async {
    final status = await Permission.microphone.status;

    if (status.isGranted) {
      print("Microphone permission already granted");
      return true;
    } else {
      final requestStatus = await Permission.microphone.request();

      if (requestStatus.isGranted) {
        print("Microphone access granted");
        return true;
      } else {
        print("Microphone permission denied");
        return false;
      }
    }
  }
}
