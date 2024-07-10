import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TimeSheetController extends GetxController {
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  final GlobalKey<FormState> AdminformKey = GlobalKey<FormState>();
  var data;

  Future<bool> timesheet() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String adminstoredEmail = preferences.getString('email') ?? '';

    final requestData = {
      'email': adminstoredEmail, // Use stored email from SharedPreferences
      'startDate': startDateController.text.toString(),
      'endDate': endDateController.text.toString(),
    };

    try {
      final response = await http.post(
        Uri.parse("http://103.159.85.246:4000/api/salary/fetch-work-hours"),
        body: jsonEncode(requestData),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        data = jsonDecode(response.body);
        print('Data: $data');
        return true; // Request successful
      } else {
        print('Request failed with status: ${response.statusCode}');
        return false; // Request failed
      }
    } catch (e) {
      print('Exception during fetch operation: $e');
      return false; // Request failed due to exception
    }
  }
}
