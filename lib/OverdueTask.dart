import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:followup/constant/conurl.dart';
import 'dart:convert';

import 'package:followup/widgets/CustomListincompleted.dart';
import 'package:followup/widgets/CustomeListOverdue.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dashboard.dart';

String? timer;
String? idd;
String? adminttype;
String? admin_type;
String? admin;
String? cmpid;
String? selectedId;

Future<List<Data>> fetchData(
    {DateTime? fromDate, DateTime? toDate, String? selectedValue}) async {
  print(selectedValue);
  print(fromDate);
  print(toDate);
  SharedPreferences preferences = await SharedPreferences.getInstance();
  var id = preferences.getString('id');
  adminttype = preferences.getString('admintype');
  cmpid = preferences.getString('cmpid');
  //var url = Uri.parse('http://testfollowup.absoftwaresolution.in/getlist.php?Type=get_completedtask');
  var url = Uri.parse(AppString.constanturl + 'get_overdeutask');
  print(id);
  final response = await http.post(url, body: {
    "id": '$id',
    "fromDate":
        fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate) : '',
    "toDate": toDate != null ? DateFormat('yyyy-MM-dd').format(toDate) : '',
    "employee": selectedValue != null ? selectedValue : '',
    "adminttype": adminttype,
    "cmpid": cmpid,
  });
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    print(jsonResponse);
    return jsonResponse.map((data) => Data.fromJson(data)).toList();
  } else {
    throw Exception('Unexpected error occured!');
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
      assignid: json['assignid'],
      status: json['status'],
    );
  }
}
class OverdueTask extends StatefulWidget {
  final String admin_type;
  const OverdueTask({Key? key, required this.admin_type}) : super(key: key);

  @override
  State<OverdueTask> createState() => _OverdueTask();
}

class _OverdueTask extends State<OverdueTask> {
  List<dynamic> dropdownItems = [];
  List<Data> data = [];
  dynamic selectedValue;
  int? selectedValueId;
  var _sateMasterList;
  List<String> stateType = [];
  List<String> stateTypeid = [];

  Timer? timer;
  ScrollController controller = ScrollController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();

  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  DateTime date = DateTime.now();
  Future<void> fetchDropdownData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userid = preferences.getString('id');
    cmpid = preferences.getString('cmpid');
    adminttype = preferences.getString('admintype');
    print("hii");
    print(userid);
    print(cmpid);
    //String apiUrl = 'http://testfollowup.absoftwaresolution.in/getlist.php?Type=get_employee';
    String apiUrl = AppString.constanturl + 'get_employee';
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {'id': userid, 'cmpid': cmpid, 'admintype': adminttype},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      _sateMasterList = jsonData;
      for (int i = 0; i < _sateMasterList.length; i++) {
        stateTypeid.add(_sateMasterList[i]["id"]);
        stateType.add(_sateMasterList[i]["firstname"]);
        setState(() {});
      }
      // print('dropdownItems');
      //_selectedValue = dropdownItems.isNotEmpty ? dropdownItems[0] : null;
      //});
    } else {
      print(
          'Error fetching dropdown data. Status code: ${response.statusCode}');
    }
  }
  File? _pickedImage;
  @override
  void initState() {
    super.initState();

    fetchDropdownData();
    selectedValue = 'Select Employee';
    fromDateController.text = DateFormat('dd-MM-yyyy').format(date);
    toDateController.text = DateFormat('dd-MM-yyyy').format(date);
    // timer = Timer.periodic(Duration(seconds: 5), (Timer t) => setState((){}));
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
        appBar: AppBar(
          backgroundColor: Colors.red,
          elevation: 0,
          title: Text(
            'Task Overdue',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: FutureBuilder(
          future: getApi(),
          builder: (context , snapshot){
            if(snapshot.hasData)
            {
              return Expanded(
                child: ListView.builder(
                  itemCount:overdueTasks.length,
                  itemBuilder: (context, index) {
                    var startDate = DateTime.parse(overdueTasks[index]["startDate"]);
                    var formattedStartDate =
                    DateFormat('yyyy-MM-dd').format(startDate);
                    var endDate = DateTime.parse(overdueTasks[index]["deadlineDate"]);
                    var formattedEndDate =
                    DateFormat('yyyy-MM-dd').format(endDate);
                    return Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(color: Colors.red, width: 2),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 50,
                              color: Colors.red,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text(
                                      "${overdueTasks[index]["status"]}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text(
                                      "Assign by ",
                                      // "${completedTasks[index]["assignTo"]}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    "${overdueTasks[index]["title"]}",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  itemBuilder: (BuildContext context) => [
                                    const PopupMenuItem<String>(
                                      value: 'view',
                                      child: Text('View'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'remark',
                                      child: Text('Remark'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Text('Update'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'complete',
                                      child: Text('Mark as Completed'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                                  onSelected: (String value) {
                                    if (value == 'view') {
                                      // Handle view action
                                    } else if (value == 'edit') {
                                      // Handle edit action
                                    } else if (value == 'delete') {
                                      // Handle delete action
                                    } else if (value == 'remark') {
                                      // Handle remark action
                                    } else if (value == 'complete') {
                                      // Handle complete action
                                      _showImagePickerOptions();
                                    }
                                  },
                                  icon: Icon(Icons.more_vert),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Divider(color: Colors.grey, thickness: 2),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Icon(Icons.calendar_today_outlined, size: 18),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(
                                          formattedStartDate,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Icon(Icons.watch_later_outlined, size: 18),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(
                                          "${overdueTasks[index]["startTime"]}",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Icon(Icons.calendar_today_outlined, size: 18),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(
                                          formattedEndDate,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Icon(Icons.watch_later_outlined, size: 18),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(
                                          "${overdueTasks[index]["endTime"]}",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            else
            {
              return Center(
                  child: CircularProgressIndicator());
            }

          },

        ),
      ),
    );
  }
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              InkWell(
                onTap: () {
                  _pickImageFromCamera();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 70),
                    SizedBox(width: 40),
                    Text("Camera"),
                  ],
                ),
              ),
              SizedBox(height: 20),
              if (_pickedImage != null)
                Image.file(
                  _pickedImage!,
                  height: 200, // Adjust height as needed
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  bool success = await markTaskAsComplete();
                  if(success)
                  {
                    markTaskAsComplete();
                    Navigator.pop(context);
                  }
                  else
                  {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Task is Not Mark as Completed'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Text('Okay'),
              ),
            ],
          ),
        );
      },
    );
  }
  void _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      File pickedImageFile = File(pickedImage.path);
      setState(() {
        _pickedImage = pickedImageFile;
      });
    }
  }
  Future<bool> markTaskAsComplete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String MarksToken = await prefs.getString("token") ?? "";
    print("Token From Pending API $MarksToken");
    String AddTaskId = await prefs.getString("id") ?? "";
    print("Id From AddTask  $AddTaskId");
    try {
      final response = await http.put(
        Uri.parse('http://103.159.85.246:4000/api/task/complete/$AddTaskId'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': MarksToken ?? '',
        },
      );

      if (response.statusCode == 200) {
        print('Task marked as complete successfully');
        return true;
      } else {
        print('Failed to mark task as complete. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception during marking task as complete: $e');
      return false;
    }
  }
  var overduedata;
  List<dynamic> overdueTasks = [];
  Future<void> getApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String EmpOverdueToken = await prefs.getString("token") ?? "";
    print("Token From Completed API $EmpOverdueToken");
    final response = await http.get(Uri.parse("http://103.159.85.246:4000/api/task/tasks/over"),
        headers: {
          "Authorization":EmpOverdueToken
        }
    );
    if(response.statusCode==200)
    {
      overduedata = jsonDecode(response.body.toString());
      setState(() {
        overdueTasks = overduedata["overdueTasks"];
      });
      print("###### Data is $overdueTasks");
      return overduedata;
    }
    else
    {
      print("#@@@@@@@@@ Data is $overduedata");
      return overduedata;
    }
  }
}

