import 'package:flutter/material.dart';
import 'package:followup/constant/conurl.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:validators/validators.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;

import 'package:firebase_core/firebase_core.dart';
import 'package:followup/notification_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin/admin_dashboard.dart';
import 'dashboard.dart';

String? token;

class loginScreen extends StatefulWidget {
  const loginScreen({Key? key}) : super(key: key);

  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {

  TextEditingController _textEditingController = TextEditingController();


  TextEditingController usernamecontroller =TextEditingController();
  TextEditingController passwordcontroller =TextEditingController();

  var dataa;

  Future<bool> AdminLogin() async {
    Map<String, dynamic> abc = {
      'email': usernamecontroller.text.trim(),
      'password': passwordcontroller.text.trim(),
    };
    try {
      final response = await http.post(
        Uri.parse("http://103.159.85.246:4000/api/employee/login"),
        body: jsonEncode(abc),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        // Parse the response JSON
        var responseData = jsonDecode(response.body);
        dataa = responseData;
        print('Data Added: $dataa');

        // Store token and email in SharedPreferences
        SharedPreferences preferences = await SharedPreferences.getInstance();
        String token = responseData['token'];
        String email = abc['email']; // Retrieve email from the form data
        await preferences.setString('token', token);
        await preferences.setString('email', email); // Store email

        print("Token stored admin: $token");
        print("Email stored admin: $email");

        return true; // Return 'success' if login is successful
      } else {
        print('Error: ${response.statusCode}');
        return false; // Return specific error message for failed response
      }
    } catch (e) {
      print('Exception during login operation: $e');
      return false; // Return specific error message for exception
    }
  }

  var data;
  Future<bool> EmployeeLoginApi() async {
    Map<String, dynamic> abc = {
      'email': usernamecontroller.text.trim(),
      'password': passwordcontroller.text.trim(),
    };
    try {
      final response = await http.post(
        Uri.parse("http://103.159.85.246:4000/api/subemployee/login"),
        body: jsonEncode(abc),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      );
      if (response.statusCode == 200) {
        data = jsonDecode(response.body);
        String token = data['token'];
        print('Data Added: $data');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        String EmpToken = await prefs.getString("token") ?? "";
        print("Token From API $EmpToken");
        return true; // Return 'success' if data is successfully added
      } else {
        print('Error: ${response.statusCode}');
        return false; // Return specific error message for failed response
      }
    } catch (e) {
      print('Exception during add operation: $e');
      return false; // Return specific error message for exception
    }
  }

  Future login(String username, String password) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    //var urlString = 'http://testfollowup.absoftwaresolution.in/getlist.php?Type=login';
    var urlString = AppString.constanturl + 'login';

    Uri uri = Uri.parse(urlString);
    var response = await http.post(uri, body: {
      "username": username,
      "password": password,
    });

    final jsondata = json.decode(response.body);
    print(jsondata);
    if (jsondata['result'] == "failure") {
      Fluttertoast.showToast(
        backgroundColor: Color.fromARGB(255, 255, 94, 0),
        textColor: Colors.white,
        msg: jsondata['message'],
        toastLength: Toast.LENGTH_SHORT,
      );
    } else if (jsondata['result'] == "success") {
      Fluttertoast.showToast(
        backgroundColor: Colors.green,
        textColor: Colors.white,
        msg: jsondata['message'],
        toastLength: Toast.LENGTH_SHORT,
      );
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('id', jsondata['userdata']['id']);
      preferences.setString('cmpid', jsondata['userdata']['company_id']);
      preferences.setString('admintype', jsondata['userdata']['admin_type']);
      preferences.setString('idemp', jsondata['userdata']['id_emp']);

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => DashboardScreen()));
    }
  }

  @override
  void dispose() {
    _textEditingController.clear();
    super.dispose();
  }

  bool isEmailCorrect = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            // color: Colors.red.withOpacity(0.1),
            image: DecorationImage(
                image: NetworkImage(
                    // 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShp2T_UoR8vXNZXfMhtxXPFvmDWmkUbVv3A40TYjcunag0pHFS_NMblOClDVvKLox4Atw&usqp=CAU',
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx7IBkCtYd6ulSfLfDL-aSF3rv6UfmWYxbSE823q36sPiQNVFFLatTFdGeUSnmJ4tUzlo&usqp=CAU'),
                fit: BoxFit.cover,
                opacity: 0.3)),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/loginlogo.jpeg',
                    height: 120,
                    width: 120,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Log In Now',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text('Please login to continue using our app',
                      style: TextStyle(fontFamily: 'Poppins')
                      ),

                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    height: isEmailCorrect! ? 280 : 200,
                    // _formKey!.currentState!.validate() ? 200 : 600,
                    // height: isEmailCorrect ? 260 : 182,
                    width: MediaQuery.of(context).size.width / 1.1,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 20, top: 20),
                          child: TextFormField(
                            controller: usernamecontroller,
                            onChanged: (val) {
                              setState(() {
                                isEmailCorrect = isEmail(val);
                              });
                            },
                            decoration: const InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              prefixIcon: Icon(
                                Icons.person,
                                color: AppString.appgraycolor,
                              ),
                              filled: true,
                              fillColor: Color(0xFFFFD700),
                              labelText: "Email",
                              //hintText: 'your-email@domain.com',
                              labelStyle: TextStyle(
                                color: (AppString.appgraycolor),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Form(
                            key: _formKey,
                            child: TextFormField(
                              controller: passwordcontroller,
                              obscuringCharacter: '*',
                              obscureText: true,
                              decoration: const InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: AppString.appgraycolor,
                                ),
                                filled: true,
                                fillColor: Color(0xFFFFD700),
                                labelText: "Password",
                                // hintText: '*********',
                                labelStyle:
                                    TextStyle(color: AppString.appgraycolor),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          bool success = await AdminLogin();
                          if(success)
                          {
                            AdminLogin();
                            usernamecontroller.clear();
                            passwordcontroller.clear();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => AdminDashboardScreen()));
                          }
                          else
                          {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Usenname or password are incorrect"),
                                duration: Duration(seconds: 2),),
                            );
                          }
                        },
                        child: Text(
                          ' Admin Login',
                          style: TextStyle(
                              color: AppString.appgraycolor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              fontFamily: 'poppins'),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 36, vertical: 18),
                          backgroundColor: Color(0xFFFFD700),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          print("hii");
                          final SharedPreferences sharedPreferences =
                          await SharedPreferences.getInstance();
                          sharedPreferences.setString(
                              'username', usernamecontroller.text);
                          bool success = await EmployeeLoginApi();
                          if(success)
                            {
                              EmployeeLoginApi();
                              usernamecontroller.clear();
                              passwordcontroller.clear();
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => DashboardScreen()));
                            }
                            else
                              {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Username or password are incorrect'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                        },
                        child: Text(
                          'Employee Login',
                          style: TextStyle(
                              color: AppString.appgraycolor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              fontFamily: 'poppins'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFD700),
                          padding: EdgeInsets.symmetric(
                              horizontal: 36, vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  String jwtToken = '';
  String deviceId = ''; // RxString to hold device ID
  String publicIp = '';
  String Email = ''; // RxString to hold user's email
  String Role = '';
  void decodeToken() async {
    try {
      String? tokenValue = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWJFbXBsb3llZUlkIjoiNjY1NDVlMjcyYzZmMWMxMjE1OTM5OGE0IiwiZW1haWwiOiJ0YW5heWFAZ21haWwuY29tIiwicm9sZSI6InN1Yi1lbXBsb3llZSIsImFkbWluQ29tcGFueU5hbWUiOiJBY21lIiwibmFtZSI6IlRhbmF5YSIsImlhdCI6MTcyMDUwNzk0Mn0.TF-3O8qHeA2lr0JaCyDt-uBw6-a4u8O9FihrAESwk7k"; // Get the token value
      if (tokenValue == null || tokenValue.isEmpty) {
        throw Exception('Token is null or empty');
      }
      // Split the token into its parts: header, payload, and signature
      List<String> parts = tokenValue.split('.');

      // Ensure that the token has the expected number of parts (header, payload, signature)
      if (parts.length != 3) {
        throw Exception('Invalid token format');
      }

      // Decode the payload from base64Url encoding
      String payload = parts[1];
      String decodedPayload = utf8.decode(base64Url.decode(base64Url.normalize(payload)));

      // Parse the JSON data in the payload
      Map<String, dynamic> payloadData = jsonDecode(decodedPayload);

      // Example of accessing data from the payload
      String userId = payloadData['subEmployeeId'] ?? ''; // User ID
      String email = payloadData['email'] ?? '';
      String role = payloadData['role'] ?? '';
      String fullName = payloadData['name'] ?? '';
      String username = payloadData['username'] ?? '';
      int issuedAt = payloadData['iat'] ?? 0; // Issued at (timestamp)

      // Accessing 'id' from the payload data
      String id = payloadData['id'] ?? '';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('id', id);
      await prefs.setString('role', role);
      await prefs.setString('email', email);

      // Print or use the decoded data
      print('User ID: $userId');
      print('Email: $email');
      print('Role: $role');
      print('Full Name: $fullName');
      print('Username: $username');
      print('Issued At: $issuedAt');
      print('ID: $id'); // Printing the 'id' field from the payload

      // Update RxString values
      Email = email;
      Role = role;

      // Optionally, store the decoded data in variables or use them further in your application
    } catch (e) {
      print('Error decoding token: $e');
      // Optionally handle errors or re-throw as needed
    }
  }
}
