import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddEmployeeController extends GetxController {
  TextEditingController usernameController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController companyController = TextEditingController(); // corrected variable name
  final GlobalKey<FormState> employeeKey = GlobalKey<FormState>(); // corrected variable name
  var data;

  Future<bool> addEmployee(String s) async {
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String company = companyController.text.trim();
    String mobileNo = mobileNoController.text.trim();

    // Retrieve token from SharedPreferences
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    Map<String, dynamic> abc = {
      'name': username,
      'email': email,
      'password': password,
      'adminCompanyName': 'Acme',
      'phoneNumber': mobileNo,
    };

    try {
      final response = await http.post(
        Uri.parse("http://103.159.85.246:4000/api/employee/registersub"),
        body: jsonEncode(abc),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': ' $token', // Include token in Authorization header
        },
      );

      if (response.statusCode == 201) {
        data = jsonDecode(response.body);
        print('#### Data Added: $data');
        return true; // Return true on successful response
      } else {
        print('Error: ${response.statusCode}');
        print('Error Body: ${response.body}');
        return false; // Return false on error response
      }
    } catch (e) {
      print('Exception during add operation: $e');
      return false; // Return false on exception
    }
  }

  var data1;

  Future<bool> addSeller(String s) async {
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String company = companyController.text.trim();
    String mobileNo = mobileNoController.text.trim();

    // Retrieve token from SharedPreferences
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    Map<String, dynamic> abc = {
      'name': username,
      'email': email,
      'password': password,
      'shiftHours':'8',
      'adminCompanyName': 'Acme',
      'phoneNumber': mobileNo,
    };

    try {
      final response = await http.post(
        Uri.parse("http://103.159.85.246:4000/api/employee/registersales"),
        body: jsonEncode(abc),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': ' $token', // Include token in Authorization header
        },
      );

      if (response.statusCode == 201) {
        data1 = jsonDecode(response.body);
        print('#### Data Added: $data1');
        return true; // Return true on successful response
      } else {
        print('Error: ${response.statusCode}');
        print('Error Body: ${response.body}');
        return false; // Return false on error response
      }
    } catch (e) {
      print('Exception during add operation: $e');
      return false; // Return false on exception
    }
  }
}
