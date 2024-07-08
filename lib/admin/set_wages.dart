import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:followup/admin/admin_dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'calculate_salary.dart'; // Import your CalculateSalary widget here

class SetWidgets extends StatefulWidget {
  const SetWidgets({Key? key}) : super(key: key);

  @override
  State<SetWidgets> createState() => _SetWidgetsState();
}

class _SetWidgetsState extends State<SetWidgets> {
  TextEditingController salaryController = TextEditingController();
  TextEditingController totalDaysController = TextEditingController();
  TextEditingController dailyShiftController = TextEditingController();
  TextEditingController employeeEmailController = TextEditingController();
  GlobalKey<FormState> wageskey = GlobalKey<FormState>();
  var data;
  var datas;

  @override
  void initState() {
    super.initState();

    // Attach listeners to text controllers
    salaryController.addListener(() => Add());
    totalDaysController.addListener(() => Add());
    dailyShiftController.addListener(() => Add());
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    salaryController.dispose();
    totalDaysController.dispose();
    dailyShiftController.dispose();
    employeeEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFFFD700),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Set Wages',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
                  key: wageskey,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.6),
                        child: Text(
                          "Total Salary",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 6),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        width: MediaQuery.of(context).size.width,
                        child: TextFormField(
                          controller: salaryController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter total salary';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Total Salary",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.6),
                        child: Text(
                          "Total Days",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 6),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        width: MediaQuery.of(context).size.width,
                        child: TextFormField(
                          controller: totalDaysController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter total days';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Total Days",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.6),
                        child: Text(
                          "Daily Shift",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 6),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        width: MediaQuery.of(context).size.width,
                        child: TextFormField(
                          controller: dailyShiftController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter daily shift';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Daily Shift",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     // ElevatedButton(
                      //     //   onPressed: () {
                      //     //     if (wageskey.currentState!.validate()) {
                      //     //       print("Calculate button tapped");
                      //     //       Add();
                      //     //     }
                      //     //   },
                      //     //   child: Text(
                      //     //     "Calculate",
                      //     //     style: TextStyle(
                      //     //       fontSize: 17,
                      //     //       fontWeight: FontWeight.w700,
                      //     //     ),
                      //     //   ),
                      //     // ),
                      //     if (data != null && data["hourlyRate"] != null)
                      //       Text(
                      //         "Hourly Rate: ${data["hourlyRate"]}",
                      //         style: TextStyle(
                      //           color: Colors.black,
                      //           fontSize: 18,
                      //           fontWeight: FontWeight.w700,
                      //         ),
                      //       ),
                      //   ],
                      // ),
                    ],
                  ),
                ),

                SizedBox(height: 30),
                Text(
                  "Employee Email Id",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Container(
                  height: MediaQuery.of(context).size.height * 0.08,
                  width: MediaQuery.of(context).size.width,
                  child: TextFormField(
                    controller: employeeEmailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter employee email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Email ID",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Hourly Rate",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                FutureBuilder<double>(
                  future: getStoredHourlyRate(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (snapshot.hasData) {
                      double storedHourlyRate = snapshot.data!;
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        width: MediaQuery.of(context).size.width,
                        child: TextFormField(
                          initialValue: storedHourlyRate.toString(),
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Hourly Rate",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Center(child: Text("No data available"));
                    }
                  },
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (wageskey.currentState!.validate()) {
                          print("Submit button tapped");
                          if (wageskey.currentState!.validate()) {
                            AddSetCard();
                          }
                        }
                      },
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.3),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     Navigator.push(context, MaterialPageRoute(builder: (context) => CalculateSalary()));
                    //   },
                    //   child: Text(
                    //     "Next",
                    //     style: TextStyle(
                    //       fontSize: 17.sp,
                    //       fontWeight: FontWeight.w700,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                navigateToSetWidgets();// Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> Add() async {
    double totalSalary = double.tryParse(salaryController.text) ?? 0.0;
    double days = double.tryParse(totalDaysController.text) ?? 0.0;
    double dailyShift = double.tryParse(dailyShiftController.text) ?? 0.0;

    Map<String, dynamic> abc = {
      "totalSalary": totalSalary,
      "days": days,
      "dailyShift": dailyShift,
    };

    try {
      final Response response = await http.post(
        Uri.parse("http://103.159.85.246:4000/api/salary/calculate-hourly-wage"),
        body: jsonEncode(abc),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          data = jsonDecode(response.body);
          if (data != null && data["hourlyRate"] != null) {
            double hourlyRate = data["hourlyRate"].toDouble();
            storeHourlyRate(hourlyRate);
          }
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<double> getStoredHourlyRate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('hourlyRate') ?? 0.0;
  }

  Future<void> storeHourlyRate(double hourlyRate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('hourlyRate', hourlyRate);
  }

  Future<void> AddSetCard() async {
    double storedHourlyRate = await getStoredHourlyRate();
    double calculatedHourlyRate = data != null && data["hourlyRate"] != null ? data["hourlyRate"].toDouble() : 0.0;

    if (storedHourlyRate == calculatedHourlyRate) {
      Map<String, dynamic> abc = {
        "email": employeeEmailController.text.toString(),
        "hourlyRate": storedHourlyRate,
      };

      try {
        final Response response = await http.post(
          Uri.parse("http://103.159.85.246:4000/api/salary/set-rate"),
          body: jsonEncode(abc),
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            datas = jsonDecode(response.body);
            _showDialog("", "Hourly rate set successfully.");
          });
        } else {
          print('Error: ${response.statusCode}');
          _showDialog("Error", "Failed to set hourly rate. Please try again later.");
        }
      } catch (e) {
        print('Error: $e');
        _showDialog("Error", "Failed to set hourly rate. Please try again later.");
      }
    } else {
      _showDialog("Error", "Hourly rates do not match. Please recalculate and try again.");
    }
  }

  void navigateToSetWidgets() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
    );
  }
}