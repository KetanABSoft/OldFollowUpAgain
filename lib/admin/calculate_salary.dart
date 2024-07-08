import 'package:flutter/material.dart';
import 'package:followup/admin/admin_dashboard.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../constant/conurl.dart';
import '../controller/calculate_salary_contoller.dart';

class CalculateSalary extends StatefulWidget {
  const CalculateSalary({Key? key}) : super(key: key);

  @override
  State<CalculateSalary> createState() => _CalculateSalaryState();
}

class _CalculateSalaryState extends State<CalculateSalary> {
  final CalculateSalaryController calculateSalaryController =
  Get.put(CalculateSalaryController());

  DateTime? startDate;
  DateTime? endDate;

  void showResponseDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (message == 'success' && calculateSalaryController.data != null) {
          return AlertDialog(
            title: Text("API Response"),
            content: Text(
                "Total Salary of Employee is ${calculateSalaryController.data["total"].toString()}"),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminDashboardScreen(),));
                },
              ),
            ],
          );
        } else {
          return AlertDialog(
            title: Text("API Response"),
            content: Text("Error: $message"),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
      },
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null && pickedDate != startDate) {
      setState(() {
        startDate = pickedDate;
        calculateSalaryController.startDateController.text =
            DateFormat('y-MM-dd').format(startDate!);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null && pickedDate != endDate) {
      setState(() {
        endDate = pickedDate;
        calculateSalaryController.endDateController.text =
            DateFormat('y-MM-dd').format(endDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFFFD700), // Set app bar background color
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(
                  30), // Add curved border radius to the bottom
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(0.3), // Set shadow color and opacity
                blurRadius: 10, // Set the blur radius of the shadow
                offset: Offset(0, 2), // Set the offset of the shadow
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors
                .transparent, // Set app bar background color to transparent
            elevation: 0, // Remove app bar shadow
            title: const Text(
              'Calculate Salary',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                color:
                AppString.appgraycolor, // Set app bar text color to white
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),

        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenSize.width * 0.04), // Responsive padding
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
                  key: calculateSalaryController.key,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email field
                      Padding(
                        padding:  EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "Email",
                          style: TextStyle(
                            fontSize: screenSize.width / 25, // Responsive font size
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),

                      TextFormField(
                        controller:
                        calculateSalaryController.emailController,
                        decoration: InputDecoration(
                            hintText: "Email",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)
                            )
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter email";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenSize.height * 0.06),

                      // Start Date field
                      Text(
                        "Start Date",
                        style: TextStyle(
                          fontSize: screenSize.width / 25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      InkWell(
                        onTap: () => _selectStartDate(context),
                        child: IgnorePointer(
                          child: TextFormField(
                            controller:
                            calculateSalaryController.startDateController,
                            decoration: InputDecoration(
                                hintText: "Start Date",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)
                                )
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter start date";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.06),

                      // End Date field
                      Text(
                        "End Date",
                        style: TextStyle(
                          fontSize: screenSize.width / 25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      InkWell(
                        onTap: () => _selectEndDate(context),
                        child: IgnorePointer(
                          child: TextFormField(
                            controller:
                            calculateSalaryController.endDateController,
                            decoration: InputDecoration(
                                hintText: "End Date",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)
                                )
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter end date";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenSize.height * 0.06),

                // Submit button
                InkWell(
                  onTap: () async {
                    if (calculateSalaryController.key.currentState!
                        .validate()) {
                      String? responseMessage =
                      await calculateSalaryController.add();
                      if (responseMessage != null) {
                        showResponseDialog(responseMessage);
                      } else {
                        showResponseDialog("Failed to calculate salary.");
                      }
                    }
                  },
                  child: Container(
                    height: screenSize.height * 0.08,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(15.0),
                      // gradient: LinearGradient(
                      //   colors: [
                      //     Color.fromRGBO(144, 149, 252, 2),
                      //     Color.fromRGBO(144, 149, 252, .7),
                      //   ],
                      // ),
                    ),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: screenSize.width / 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}