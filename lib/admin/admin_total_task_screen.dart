import 'dart:async';

import 'package:flutter/material.dart';
import 'package:followup/admin/admin_dashboard.dart';
import 'package:followup/constant/conurl.dart';
import '../widgets/customListTile.dart';
import 'dart:convert';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'package:intl/intl.dart';

String? timer;
String? id;
String? adminttype;
String? admin_type;
String? admin;
String? cmpid;
String? selectedId;
Future<List<Data>> fetchData(
    {DateTime? fromDate, DateTime? toDate, String? selectedValue}) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  id = preferences.getString('id');
  cmpid = preferences.getString('cmpid');
  adminttype = preferences.getString('admintype');

  var url = Uri.parse(AppString.constanturl + 'get_list');
  final response = await http.post(url, body: {
    "id": id,
    "cmpid": cmpid,
    "admintype": adminttype,
    "fromDate":
    fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate) : '',
    "toDate": toDate != null ? DateFormat('yyyy-MM-dd').format(toDate) : '',
    "employee": selectedValue != null ? selectedValue : '',
  });

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    print(jsonResponse);
    return jsonResponse.map((data) => Data.fromJson(data)).toList();
  } else {
    throw Exception('Unexpected error occurred!');
  }
}

TextEditingController msg = new TextEditingController();

class Data {
  final String id;
  final String title;
  final String date;
  final String deadline;
  final String starttime;
  final String endtime;
  final String assign;
  final String mobile;
  final String assignedby;
  final String assignid;
  final String status;

  Data(
      {required this.id,
        required this.title,
        required this.date,
        required this.deadline,
        required this.starttime,
        required this.endtime,
        required this.assign,
        required this.mobile,
        required this.assignedby,
        required this.assignid,
        required this.status});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'],
      title: json['title'],
      date: json['date'],
      deadline: json['deadline'],
      starttime: json['starttime'],
      endtime: json['endtime'],
      assign: json['assign'],
      mobile: json['mobile'] ?? "",
      assignedby: json['assignedby'],
      assignid: json['assignid'],
      status: json['status'],
    );
  }
}
class AdminTotalTask extends StatefulWidget {
  final String admin_type;
  const AdminTotalTask({Key? key, required this.admin_type}) : super(key: key);
  @override
  State<AdminTotalTask> createState() => _DashBoard();
}
class _DashBoard extends State<AdminTotalTask> {
  List<dynamic> dropdownItems = [];
  List<Data> data = [];
  dynamic selectedValue;
  int? selectedValueId;
  Timer? timer;
  ScrollController controller = ScrollController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  var _sateMasterList;
  List<String> stateType = [];
  List<String> stateTypeid = [];
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  DateTime date = DateTime.now();

  //newdate = DateFormat('yyyy-MM-dd').format(dateTime);
  TimeOfDay time = TimeOfDay.now();

  final _formKey = GlobalKey<FormState>();
  var dropdownvalue;

  // Future<void> fetchDropdownData() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   userid = preferences.getString('id');
  //   cmpid = preferences.getString('cmpid');
  //   adminttype = preferences.getString('admintype');
  //   //String apiUrl = 'http://testfollowup.absoftwaresolution.in/getlist.php?Type=get_employee';
  //   String apiUrl = AppString.constanturl + 'get_employee';
  //   var response = await http.post(
  //     Uri.parse(apiUrl),
  //     body: {'id': userid, 'cmpid': cmpid, 'admintype': adminttype},
  //   );
  //
  //   if (response.statusCode == 200) {
  //     // final jsonData = jsonDecode(response.body);
  //     // setState(() {
  //     //   dropdownItems = jsonData;
  //     //   print(dropdownItems);
  //
  //     List<dynamic> jsonData = jsonDecode(response.body);
  //     _sateMasterList = jsonData;
  //     for (int i = 0; i < _sateMasterList.length; i++) {
  //       stateTypeid.add(_sateMasterList[i]["id"]);
  //       stateType.add(_sateMasterList[i]["firstname"]);
  //       setState(() {});
  //     }
  //     // print('dropdownItems');
  //     //_selectedValue = dropdownItems.isNotEmpty ? dropdownItems[0] : null;
  //     //});
  //   } else {
  //     print(
  //         'Error fetching dropdown data. Status code: ${response.statusCode}');
  //   }
  // }

  @override
  void initState() {
    super.initState();

    // fetchDropdownData();
    selectedValue = 'Select Employee';
    // timer = Timer.periodic(Duration(seconds: 5), (Timer t) => setState((){}));
    fromDateController.text = DateFormat('dd-MM-yyyy').format(date);
    toDateController.text = DateFormat('dd-MM-yyyy').format(date);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String adminType = '$adminttype';
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFFFD700),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
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
                'Total Task',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppString.appgraycolor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppString.appgraycolor),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>AdminDashboardScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                child: Column(
                  children: [
                    adminType == 'admin'
                        ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    icon: Icon(Icons.date_range),
                                    labelText: 'Start Date',
                                    labelStyle: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.grey,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                      BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                      BorderSide(color: Colors.blue),
                                    ),
                                  ),
                                  controller: fromDateController,
                                  readOnly: true,
                                  onTap: () async {
                                    final pickedDate =
                                    await showDatePicker(
                                      context: context,
                                      initialDate: fromDate,
                                      firstDate: DateTime(1950),
                                      lastDate: DateTime(2100),
                                    );

                                    if (pickedDate != null) {
                                      setState(() {
                                        fromDate = pickedDate;
                                        fromDateController.text =
                                            DateFormat('dd-MM-yyyy')
                                                .format(fromDate);
                                      });
                                    }
                                  },
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    icon: Icon(Icons.date_range),
                                    labelText: 'To Date',
                                    labelStyle: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.grey,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                      BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                      BorderSide(color: Colors.blue),
                                    ),
                                  ),
                                  controller: toDateController,
                                  readOnly: true,
                                  onTap: () async {
                                    final pickedDate =
                                    await showDatePicker(
                                      context: context,
                                      initialDate: toDate,
                                      firstDate: DateTime(1950),
                                      lastDate: DateTime(2100),
                                    );

                                    // if (pickedDate != null) {
                                    //     setState(() {
                                    //       toDate = pickedDate;
                                    //       toDateController.text = DateFormat('dd-MM-yyyy').format(toDate);
                                    //     });
                                    //   }

                                    if (pickedDate != null) {
                                      // Check if pickedDate is after the current date

                                      // Extract date components without time
                                      DateTime currentDateWithoutTime =
                                      DateTime(
                                          DateTime.now().year,
                                          DateTime.now().month,
                                          DateTime.now().day);
                                      DateTime pickedDateWithoutTime =
                                      DateTime(
                                          pickedDate.year,
                                          pickedDate.month,
                                          pickedDate.day);

                                      if (pickedDateWithoutTime.isAfter(
                                          currentDateWithoutTime) ||
                                          pickedDateWithoutTime
                                              .isAtSameMomentAs(
                                              currentDateWithoutTime)) {
                                        //String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                                        setState(() {
                                          String formattedDate =
                                          DateFormat('dd-MM-yyyy')
                                              .format(pickedDate);
                                          toDateController.text =
                                              formattedDate;
                                        });
                                      } else {
                                        // Display an error message or take appropriate action
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('Invalid Date',
                                                  style: TextStyle(
                                                      fontFamily:
                                                      'Poppins')),
                                              content: Text(
                                                  'Please select the correct date.',
                                                  style: TextStyle(
                                                      fontFamily:
                                                      'Poppins')),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context);
                                                  },
                                                  child: Text('OK',
                                                      style: TextStyle(
                                                          fontFamily:
                                                          'Poppins')),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    } else {}
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              SizedBox(width: 10),
                              Expanded(
                                child: DropdownSearch<String>(
                                  items: stateType,
                                  onChanged: (String? value) {
                                    if (value != null) {
                                      int selectedIndex =
                                      stateType.indexOf(value);
                                      selectedId =
                                      stateTypeid[selectedIndex];
                                      // Use selectedId and value as needed
                                      setState(() {
                                        selectedValue = value;
                                      });
                                    }
                                  },
                                  selectedItem: selectedValue,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    List<Data> dataList = await fetchData(
                                      fromDate: fromDate,
                                      toDate: toDate,
                                      selectedValue: selectedId,
                                    );
                                    setState(() {
                                      // Update the state with the new data
                                      data = dataList;
                                    });
                                  },
                                  child: Text('Search',
                                      style: TextStyle(
                                          fontFamily: 'Poppins')),
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                        ],
                      ),
                    )
                        : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                icon: Icon(Icons.date_range),
                                labelText: 'Start Date',
                                labelStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.blue),
                                ),
                              ),
                              controller: fromDateController,
                              readOnly: true,
                              onTap: () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: fromDate,
                                  firstDate: DateTime(1950),
                                  lastDate: DateTime(2100),
                                );

                                if (pickedDate != null) {
                                  setState(() {
                                    fromDate = pickedDate;
                                    fromDateController.text =
                                        DateFormat('dd-MM-yyyy')
                                            .format(fromDate);
                                  });
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                icon: Icon(Icons.date_range),
                                labelText: 'To Date',
                                labelStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.blue),
                                ),
                              ),
                              controller: toDateController,
                              readOnly: true,
                              onTap: () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: toDate,
                                  firstDate: DateTime(1950),
                                  lastDate: DateTime(2100),
                                );

                                // if (pickedDate != null) {
                                //     setState(() {
                                //       toDate = pickedDate;
                                //       toDateController.text = DateFormat('dd-MM-yyyy').format(toDate);
                                //     });
                                //   }

                                if (pickedDate != null) {
                                  // Check if pickedDate is after the current date

                                  // Extract date components without time
                                  DateTime currentDateWithoutTime =
                                  DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day);
                                  DateTime pickedDateWithoutTime =
                                  DateTime(
                                      pickedDate.year,
                                      pickedDate.month,
                                      pickedDate.day);

                                  if (pickedDateWithoutTime.isAfter(
                                      currentDateWithoutTime) ||
                                      pickedDateWithoutTime
                                          .isAtSameMomentAs(
                                          currentDateWithoutTime)) {
                                    //String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                                    setState(() {
                                      String formattedDate =
                                      DateFormat('dd-MM-yyyy')
                                          .format(pickedDate);
                                      toDateController.text =
                                          formattedDate;
                                    });
                                  } else {
                                    // Display an error message or take appropriate action
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('Invalid Date',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins')),
                                          content: Text(
                                              'Please select the correct date.',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins')),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('OK',
                                                  style: TextStyle(
                                                      fontFamily:
                                                      'Poppins')),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                } else {}
                              },
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              List<Data> dataList = await fetchData(
                                  fromDate: fromDate,
                                  toDate: toDate,
                                  selectedValue: selectedId);
                              setState(() {
                                // Update the state with the new data
                                data = dataList;
                              });
                            },
                            child: Text('Search'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: data.isEmpty // Check if the data list is empty
                          ? FutureBuilder<List<Data>>(
                        future: fetchData(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                                shrinkWrap: true,
                                controller: controller,
                                itemCount: snapshot.data!.length,
                                padding: EdgeInsets.only(
                                    top: 10,
                                    bottom: 80,
                                    left: 15,
                                    right: 15),
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    child: CustomListAll(
                                      trailingButtonOnTap: null,
                                      id: snapshot.data![index].id,
                                      title: snapshot.data![index].title,
                                      date: snapshot.data![index].date,
                                      deadline:
                                      snapshot.data![index].deadline,
                                      starttime:
                                      snapshot.data![index].starttime,
                                      endtime:
                                      snapshot.data![index].endtime,
                                      assign:
                                      snapshot.data![index].assign,
                                      mobile:
                                      snapshot.data![index].mobile,
                                      assignedby: snapshot
                                          .data![index].assignedby,
                                      assignid:
                                      snapshot.data![index].assignid,
                                      status:
                                      snapshot.data![index].status,
                                      admintype: '$adminttype',
                                      mainid: '$id',
                                      opacity: 1,
                                    ),
                                  );
                                });
                          } else if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          }
                          // By default show a loading spinner.

                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      )
                          : FutureBuilder<List<Data>>(
                        future:
                        fetchData(fromDate: fromDate, toDate: toDate),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                                shrinkWrap: true,
                                controller: controller,
                                itemCount: data.length,
                                padding: EdgeInsets.only(
                                    top: 10,
                                    bottom: 80,
                                    left: 15,
                                    right: 15),
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    child: CustomListAll(
                                      trailingButtonOnTap: null,
                                      id: data[index].id,
                                      title: data[index].title,
                                      date: data[index].date,
                                      deadline: data[index].deadline,
                                      starttime: data[index].starttime,
                                      endtime: data[index].endtime,
                                      assign: data[index].assign,
                                      mobile: data[index].mobile,
                                      assignedby: data[index].assignedby,
                                      assignid: data[index].assignid,
                                      status: data[index].status,
                                      admintype: '$adminttype',
                                      mainid: '$id',
                                      opacity: 1,
                                    ),
                                  );
                                });
                          } else if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          }
                          // By default show a loading spinner.

                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
