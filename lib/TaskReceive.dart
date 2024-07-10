import 'dart:async';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:followup/constant/conurl.dart';
import 'dart:convert';

import 'package:followup/widgets/CustomListReceive.dart';
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

Future<List<Data>> fetchData({DateTime? fromDate, DateTime? toDate,String? selectedValue}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var id = preferences.getString('id');
     adminttype = preferences.getString('admintype');
  //var url = Uri.parse('http://testfollowup.absoftwaresolution.in/getlist.php?Type=get_receivetask');
  var url = Uri.parse(AppString.constanturl+'get_receivetask');
  final response = await http.post(url, body: {
       "id": '$id',
       "fromDate": fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate) : '',
       "toDate": toDate != null ? DateFormat('yyyy-MM-dd').format(toDate) : '',
        "employee": selectedValue != null ? selectedValue : '',
     });
   
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    print(jsonResponse);
    return jsonResponse.map((data) => Data.fromJson(data)).toList();
  } else {
    throw Exception('Unexpected error occured!');
  }
}

TextEditingController msg=new TextEditingController();

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

  Data({required this.id, required this.title, required this.date, required this.deadline, required this.starttime, required this.endtime, required this.assign,   required this.assignid, required this.status});

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

class ReceiveTaskScreen extends StatefulWidget {
  const ReceiveTaskScreen({Key? key,}) : super(key: key);

@override
  State<ReceiveTaskScreen> createState() => _Receive();
  
}

class _Receive extends State<ReceiveTaskScreen> {
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
    //String apiUrl = 'http://testfollowup.absoftwaresolution.in/getlist.php?Type=get_employee';
    String apiUrl = AppString.constanturl+'get_employee';
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {'id': userid,'cmpid':cmpid,'admintype':adminttype},
    );

    if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        _sateMasterList = jsonData;
    for (int i = 0; i < _sateMasterList.length; i++) {
      stateTypeid.add(_sateMasterList[i]["id"]);
      stateType.add(_sateMasterList[i]["firstname"]);
    }
    } else {
      print('Error fetching dropdown data. Status code: ${response.statusCode}');
    }
  }
  @override
  void initState(){
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
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        elevation: 0,
        title: Text(
          'Task Received',
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
        future: receiveTaskApi(),
        builder: (context , snapshot){
          if(snapshot.hasData)
          {
            return ListView.builder(
              itemCount:receiveTasks.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                var startDate = DateTime.parse(receiveTasks[index]["startDate"]);
                var formattedStartDate =
                DateFormat('yyyy-MM-dd').format(startDate);
                var endDate = DateTime.parse(receiveTasks[index]["deadlineDate"]);
                var formattedEndDate =
                DateFormat('yyyy-MM-dd').format(endDate);
                return Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: Colors.pink, width: 2),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 50,
                          color:Colors.pink,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  "${receiveTasks[index]["status"]}",
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
                                "${receiveTasks[index]["title"]}",
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
                                      "${receiveTasks[index]["startTime"]}",
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
                                      "${receiveTasks[index]["endTime"]}",
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
      ),
    );
  }
  var receiveData;
  List<dynamic> receiveTasks = [];
  Future<void> receiveTaskApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String EmpSendTaskToken = await prefs.getString("token") ?? "";
    print("Token From Send Task API $EmpSendTaskToken");
    final response = await http.get(Uri.parse("http://103.159.85.246:4000/api/task/listTaskEmp"),
        headers: {
          "Authorization":EmpSendTaskToken
        }
    );
    if(response.statusCode==200)
    {
      receiveData = jsonDecode(response.body.toString());
      setState(() {
        receiveTasks = receiveData["tasks"];
      });
      print("###### Data is $receiveTasks");
      return receiveData;
    }
    else
    {
      print("#@@@@@@@@@ Data is $receiveData");
      return receiveData;
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
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    Icon(Icons.camera_alt, size: 70),
                    SizedBox(width: 10),
                    Text("Camera"),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Handle other options if needed
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? returnImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;
    setState(() {
      // Handle the selected image
    });
  }
}
