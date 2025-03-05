import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:gad_fly_partner/constant/api_end_point.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class MainApplicationController extends GetxController {
  var pageIdx = 0.obs;
  var authToken = ''.obs;
  var selectedStatus = 'Offline'.obs;
  var currentCallId = ''.obs;

  var transactionList = [].obs;
  Future getAllTransaction() async {
    final response = await http.get(
      Uri.parse('${ApiEndpoints.baseUrl}/partner/callHistory/getAll'),
      headers: {
        'x-partner-token': authToken.value,
      },
    );
    if (response.statusCode == 200) {
      transactionList.clear();
      final responseData = json.decode(response.body);
      // if (data.containsKey('data')) {
      //   final List<dynamic> noteData = data['data'];
      //   List<Map<String, dynamic>> dataList =
      //   noteData.map((data) => data as Map<String, dynamic>).toList();
      //   mainApplicationController.partnerList.value = dataList;
      // } else {
      //   throw Exception('Invalid response format: "data" field not found');
      // }
      transactionList.value = responseData["data"];
      return true;
    } else {
      final responseData = json.decode(response.body);
      print(responseData);
      return false;
    }
  }

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

  String formatDate(String inputDate) {
    try {
      DateTime dateTime = DateTime.parse(inputDate);
      DateTime now = DateTime.now();
      // String outputDate = DateFormat('dd-MMM   hh:mm a').format(dateTime);
      // return outputDate;
      if (dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day) {
        return 'Today ${DateFormat('hh:mm a').format(dateTime)}'; // "Today hh:mm a"
      } else {
        return DateFormat('dd-MMM  hh:mm a').format(dateTime);
      }
    } catch (e) {
      print('Invalid date format: $e');
      return 'Invalid Date';
    }
  }
}
