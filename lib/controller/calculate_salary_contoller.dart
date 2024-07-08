import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CalculateSalaryController extends GetxController {
  final GlobalKey<FormState> key = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  var data;

  Future<String?> add() async {
    Map<String, dynamic> abc = {
      'email': emailController.text.trim(),
      'startDate': startDateController.text.trim(),
      'endDate': endDateController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse("http://103.159.85.246:4000/api/salary/calculate-salary"),
        body: jsonEncode(abc),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        data = jsonDecode(response.body);
        print('Data Added: $data');
        return 'success'; // Return 'success' if data is successfully added
      } else {
        print('Error: ${response.statusCode}');
        return 'Failed to calculate salary'; // Return specific error message for failed response
      }
    } catch (e) {
      print('Exception during add operation: $e');
      return 'Failed to calculate salary'; // Return specific error message for exception
    }
  }


  @override
  void onClose() {
    // Dispose text editing controllers when the controller is disposed
    emailController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.onClose();
  }
}