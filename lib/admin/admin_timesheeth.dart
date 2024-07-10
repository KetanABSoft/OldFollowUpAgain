import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../controller/admin_timesheeth_controller.dart';


class AdminTimeSheetScreen extends StatefulWidget {
  const AdminTimeSheetScreen({Key? key}) : super(key: key);

  @override
  _AdminTimeSheetScreenState createState() => _AdminTimeSheetScreenState();
}
class _AdminTimeSheetScreenState extends State<AdminTimeSheetScreen> {
  final TimeSheetController timeSheetController = Get.put(TimeSheetController());

  DateTime? startDate;
  DateTime? endDate;
  bool showChart = false;
  List<FlSpot> spots = [];

  @override
  void initState() {
    super.initState();
    setCurrentDate();
  }

  void setCurrentDate() {
    // Example of setting current date
    // currentDate = DateFormat('d MMMM y').format(DateTime.now());
  }

  // void generateChartData() {
  //   var workHoursByDate = timeSheetController.data?['workHoursByDate'];
  //
  //   spots.clear();
  //
  //   if (workHoursByDate != null) {
  //     int index = 0;
  //     // Use startDate and endDate to calculate the number of days
  //     DateTime? currentDateTime = startDate;
  //     while (currentDateTime!.isBefore(endDate!.add(Duration(days: 1)))) {
  //       String currentDate = DateFormat('yyyy-MM-dd').format(currentDateTime);
  //       double hours = workHoursByDate[currentDate]?.toDouble() ?? 0.0;
  //       spots.add(FlSpot(index.toDouble(), hours));
  //       currentDateTime = currentDateTime.add(Duration(days: 1));
  //       index++;
  //     }
  //   }
  // }


  void generateChartData() {
    var workHoursByDate = timeSheetController.data?['workHoursByDate'];

    spots.clear();

    if (workHoursByDate != null) {
      int index = 0;
      // Use startDate and endDate to calculate the number of days
      DateTime? currentDateTime = startDate;
      while (currentDateTime!.isBefore(endDate!.add(Duration(days: 1)))) {
        String currentDate = DateFormat('yyyy-MM-dd').format(currentDateTime);
        double hours = workHoursByDate[currentDate]?.toDouble() ?? 0.0;
        spots.add(FlSpot(index.toDouble(), hours));
        currentDateTime = currentDateTime.add(Duration(days: 1));
        index++;
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff7c81dd),
        title: Center(
          child: Text(
            "Time Sheet",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Form(
                  key: timeSheetController.AdminformKey,
                  child: Column(
                    children: [
                      // TextFormField(
                      //   controller: timeSheetController.emailController,
                      //   decoration: InputDecoration(
                      //     labelText: 'Email',
                      //     hintText: 'Enter your email',
                      //     border: OutlineInputBorder(),
                      //   ),
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please enter your email';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      // SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: timeSheetController.startDateController,
                              decoration: InputDecoration(
                                labelText: 'Start Date',
                                hintText: 'Select Start Date',
                                border: OutlineInputBorder(),
                              ),
                              readOnly: true,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: startDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (pickedDate != null && pickedDate != startDate) {
                                  setState(() {
                                    startDate = pickedDate;
                                    timeSheetController.startDateController.text =
                                        DateFormat('yyyy-MM-dd').format(startDate!);
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select start date';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: timeSheetController.endDateController,
                              decoration: InputDecoration(
                                labelText: 'End Date',
                                hintText: 'Select End Date',
                                border: OutlineInputBorder(),
                              ),
                              readOnly: true,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: endDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (pickedDate != null && pickedDate != endDate) {
                                  setState(() {
                                    endDate = pickedDate;
                                    timeSheetController.endDateController.text =
                                        DateFormat('yyyy-MM-dd').format(endDate!);
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select end date';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          if (timeSheetController.AdminformKey.currentState!.validate()) {
                            bool success = await timeSheetController.timesheet();
                            if (success) {
                              generateChartData();
                              setState(() {
                                showChart = true;
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to fetch data. Please try again later.'),
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xff7c81dd), Color(0xff7c81dd)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text(
                              'Show Chart',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (showChart)
                        Padding(
                          padding:  EdgeInsets.only(top: 10),
                          child: Container(
                            height: 400,
                            padding: EdgeInsets.all(16),
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: true,
                                  checkToShowHorizontalLine: (value) => value % 10 == 0,
                                ),
                                titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,

                                          getTitlesWidget: (value,meta) {
                                            if (value.toInt() >= 0 && value.toInt() < spots.length) {
                                              return Text( DateFormat('dd').format(startDate!.add(Duration(days: value.toInt()))));
                                            }
                                            return Text('data');
                                          },
                                        )
                                    ),
                                    leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,

                                        )
                                    ),
                                    rightTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                            showTitles: false
                                        )
                                    ),
                                    topTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                            showTitles: false
                                        )
                                    )
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(color: Colors.grey, width: 1),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: spots,
                                    isCurved: true,
                                    color: Colors.red,
                                    barWidth: 2,
                                    belowBarData: BarAreaData(
                                      show: false,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
