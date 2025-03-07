import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gad_fly_partner/constant/api_end_point.dart';
import 'package:gad_fly_partner/model/all_chat_model.dart';
import 'package:gad_fly_partner/screens/chat_screen.dart';
import 'package:gad_fly_partner/screens/history.dart';
import 'package:gad_fly_partner/screens/home/home_page.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class MainApplicationController extends GetxController {
  var pageIdx = 0.obs;
  var authToken = ''.obs;
  var selectedStatus = 'Offline'.obs;
  var currentCallId = ''.obs;
  var voiceId = ''.obs;
  var voiceUrl = ''.obs;
  AllChatModel? allChatModel;

  List<Widget> homeWidgets = [
    const HomePage(),
    //  const SizedBox(),
    const ChatScreen(),
    const HistoryScreen(),
  ];

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

  Future getAllChat() async {
    final response = await http.get(
      Uri.parse('${ApiEndpoints.baseUrl}/partner/chatHistory/getAll'),
      headers: {
        'x-partner-token': authToken.value,
      },
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      // if (data.containsKey('data')) {
      //   final List<dynamic> noteData = data['data'];
      //   List<Map<String, dynamic>> dataList =
      //   noteData.map((data) => data as Map<String, dynamic>).toList();
      //   mainApplicationController.partnerList.value = dataList;
      // } else {
      //   throw Exception('Invalid response format: "data" field not found');
      // }
      allChatModel = AllChatModel.fromJson(responseData);
      return true;
    } else {
      final responseData = json.decode(response.body);
      print(responseData);
      return false;
    }
  }

  Future voiceRecordUpload(voicePath) async {
    try {
      final Uri apiUrl =
          Uri.parse("${ApiEndpoints.baseUrl}/partner/personalInfo/voiceUpload");

      var request = http.MultipartRequest('POST', apiUrl);

      request.headers['x-partner-token'] = authToken.value;

      if (voicePath != null) {
        request.files
            .add(await http.MultipartFile.fromPath('voiceNote', voicePath));
      } else {
        if (kDebugMode) {
          print("Voice path is null. No file to upload.");
        }
        return false;
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var responseData = jsonDecode(responseBody);
        voiceId.value = responseData["voiceNote"]["public_id"];
        voiceUrl.value = responseData["voiceNote"]["url"];
        return true;
      } else {
        var responseData = jsonDecode(await response.stream.bytesToString());
        if (kDebugMode) {
          print(
              "Failed to upload: ${response.statusCode} or ${responseData["message"]}");
        }
        if (kDebugMode) {
          print("Failed to upload: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading info: $e");
      }
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
