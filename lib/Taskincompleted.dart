import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Taskincompleted extends StatefulWidget {
  const Taskincompleted({Key? key}) : super(key: key);

  @override
  _TaskincompletedState createState() => _TaskincompletedState();
}

class _TaskincompletedState extends State<Taskincompleted> {
  File? _selectedImage;
  Uint8List? _image;
  File? selectedIMage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pendingTask();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff7c81dd),
        elevation: 0,
        title: Text(
          'Task Pending',
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
        future:pendingTask(),
        builder: (context , snapshot){
          return   Expanded(
            child: ListView.builder(
              itemCount: pendingData.length,
              itemBuilder: (context, index) {
                var startDate = DateTime.parse(pendingData[index].startDate.toString());
                var formattedStartDate =
                DateFormat('yyyy-MM-dd').format(startDate);
                var endDate = DateTime.parse(pendingData[index].deadlineDate.toString());
                var formattedEndDate =
                DateFormat('yyyy-MM-dd').format(endDate);
                return Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: Color.fromARGB(255, 77, 77, 174), width: 2),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 50,
                          color: Color.fromARGB(255, 77, 77, 174),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  "${pendingData[index].status}",
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
                                  "Assign By",
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
                                "${pendingData[index].title}",
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
                                      "${pendingData[index].startTime}",
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
                                children:[
                                  Padding(
                                    padding:EdgeInsets.only(left: 10),
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
                                      "${pendingData[index].endTime}",
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
        },
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
  List<Task> pendingData =[];
  Future<List<Task>> pendingTask() async {
    final url =
    Uri.parse("http://103.159.85.246:4000/api/task/tasks/pendingByEmp");
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization':
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWJFbXBsb3llZUlkIjoiNjY1NDVlMjcyYzZmMWMxMjE1OTM5OGE0IiwiZW1haWwiOiJ0YW5heWFAZ21haWwuY29tIiwicm9sZSI6InN1Yi1lbXBsb3llZSIsImFkbWluQ29tcGFueU5hbWUiOiJBY21lIiwibmFtZSI6IlRhbmF5YSIsImlhdCI6MTcyMDA4NDQ3Mn0.k3OIKIwkGRTqIPZDZBXPnW1trisnOdACBhFkNUchc54', // Replace with your actual token
          'Content-Type': 'application/json; charset=utf-8',
        },
      );
      var pending = jsonDecode(response.body.toString());
      if (response.statusCode == 200) {
        for(var index in pending)
          {
            pendingData.add(Task.fromJson(index));
          }
        
         print("@###@@$pendingData");
        
          return pendingData;
          
      } else {
        throw Exception('Failed to fetch employees');
      }
    } catch (e) {
      throw Exception('Failed to fetch employees: $e');
    }
  }
  Future _pickImageFromCamera() async {
    final returnImage =
    await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;
    setState(() {
      selectedIMage = File(returnImage.path);
      _image = File(returnImage.path).readAsBytesSync();
    });
    Navigator.of(context).pop();
  }
}
// task_model.dart

class Task {
  String id;
  String title;
  String description;
  List<String> assignTo;
  DateTime startDate;
  DateTime deadlineDate;
  DateTime reminderDate;
  String startTime;
  String endTime;
  String reminderTime;
  String status;
  String assignedBy;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assignTo,
    required this.startDate,
    required this.deadlineDate,
    required this.reminderDate,
    required this.startTime,
    required this.endTime,
    required this.reminderTime,
    required this.status,
    required this.assignedBy,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      assignTo: List<String>.from(json['assignTo']),
      startDate: DateTime.parse(json['startDate']),
      deadlineDate: DateTime.parse(json['deadlineDate']),
      reminderDate: DateTime.parse(json['reminderDate']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      reminderTime: json['reminderTime'],
      status: json['status'],
      assignedBy: json['assignedBy'],
    );
  }
}
