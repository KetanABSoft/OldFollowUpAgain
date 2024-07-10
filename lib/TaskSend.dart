import 'dart:async';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:followup/constant/conurl.dart';
import 'dart:convert';

import 'package:followup/widgets/CustomListSend.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/customListTile.dart';

import 'package:intl/intl.dart';
import 'dashboard.dart';

String? timer;
String? id;
String? adminttype;
String? admin_type;
String? admin;
String? cmpid;
String? selectedId;

TextEditingController msg = new TextEditingController();

class EmployeeSendTask extends StatefulWidget {
  const EmployeeSendTask({Key? key,}) : super(key: key);

  @override
  State<EmployeeSendTask> createState() => _Send();
}

class _Send extends State<EmployeeSendTask> {
  List<dynamic> dropdownItems = [];
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

  @override
  void initState() {
    super.initState();
    sendTaskApi();
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
  File? _pickedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0,
        title: Text(
          'Task Send',
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
        future: sendTaskApi(),
        builder: (context , snapshot){
          if(snapshot.hasData)
          {
            return ListView.builder(
              itemCount:sendTasks.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                var startDate = DateTime.parse(sendTasks[index]["startDate"]);
                var formattedStartDate =
                DateFormat('yyyy-MM-dd').format(startDate);
                var endDate = DateTime.parse(sendTasks[index]["deadlineDate"]);
                var formattedEndDate =
                DateFormat('yyyy-MM-dd').format(endDate);
                return Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: Colors.amber, width: 2),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 50,
                          color: Colors.amber,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  "${sendTasks[index]["status"]}",
                                  style: TextStyle(
                                    color: Colors.black,
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
                                    color: Colors.black,
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
                                "${sendTasks[index]["title"]}",
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
                                      "${sendTasks[index]["startTime"]}",
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
                                      "${sendTasks[index]["endTime"]}",
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
            );
          }
          else
          {
            return Center(
                child: CircularProgressIndicator());
          }

        },

      ),
    );
  }
  var sendData;
  List<dynamic> sendTasks = [];
  Future<void> sendTaskApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String EmpSendTaskToken = await prefs.getString("token") ?? "";
    print("Token From Send Task API $EmpSendTaskToken");
    final response = await http.get(Uri.parse("http://103.159.85.246:4000/api/task/list/subemployee/sendTasks"),
        headers: {
          "Authorization":EmpSendTaskToken
        }
    );
    if(response.statusCode==200)
    {
      sendData = jsonDecode(response.body.toString());
      setState(() {
        sendTasks = sendData["tasks"];
      });
      print("###### Data is $sendTasks");
      return sendData;
    }
    else
    {
      print("#@@@@@@@@@ Data is $sendData");
      return sendData;
    }
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

}
