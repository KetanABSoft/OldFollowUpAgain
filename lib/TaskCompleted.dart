import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TaskCompletedScreen extends StatefulWidget {
  const TaskCompletedScreen({Key? key}) : super(key: key);

  @override
  State<TaskCompletedScreen> createState() => _TaskCompletedScreenState();
}

class _TaskCompletedScreenState extends State<TaskCompletedScreen> {


  @override
  void initState() {
    super.initState();
    //completeTaskApi();
    taskCompleteApi();
    getApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff7c81dd),
        elevation: 0,
        title: Text(
          'Task Complete',
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
      body: Expanded(
        child: ListView.builder(
          itemCount:5,
          itemBuilder: (context, index) {
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
                              "Status",
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
                            "Title",
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
                                  "22-92-22",
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
                                  "Start Time",
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
                                  "22-05-2024",
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
                                  "EndTime",
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

  Future<void> _pickImageFromCamera() async {
    final XFile? returnImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;
    setState(() {
      // Handle the selected image
    });
  }


//   var datas;
// List<CompletedTask> tasks = [];
//   Future<List<CompletedTask>> completeTaskApi() async {
//     final response = await http.get(
//       Uri.parse("http://localhost:5000/api/task/tasks/completedByEmp"),
//       headers: {
//         "Content-Type": "application/json; charset=utf-8",
//         "Authorization":
//         "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWJFbXBsb3llZUlkIjoiNjY1NDVlMjcyYzZmMWMxMjE1OTM5OGE0IiwiZW1haWwiOiJ0YW5heWFAZ21haWwuY29tIiwicm9sZSI6InN1Yi1lbXBsb3llZSIsImFkbWluQ29tcGFueU5hbWUiOiJBY21lIiwibmFtZSI6IlRhbmF5YSIsImlhdCI6MTcyMDA4NDQ3Mn0.k3OIKIwkGRTqIPZDZBXPnW1trisnOdACBhFkNUchc54",
//       },
//     );
//     datas = jsonDecode(response.body.toString());
//     if (response.statusCode == 200) {
//      for(var index in datas)
//        {
//          tasks.add(CompletedTask.fromJson(index));
//        }
//       return tasks;
//     } else {
//       throw Exception('Failed to load completed tasks');
//     }
//   }
var completeData;
  Future<bool> taskCompleteApi() async{
    final response = await http.get(Uri.parse("http://localhost:5000/api/task/tasks/completedByEmp"));
    if(response.statusCode==200)
      {
        completeData=jsonDecode(response.body.toString());
        print("### Data Decode $completeData");
        return true;
      }
        return false;
  }
  var data;
  Future <void> getApi()async{
    print('#####1');
    final responce =await http.get(Uri.parse("http://localhost:5000/api/task/tasks/completedByEmp"));
    print('#####2');
    if(responce.statusCode==200)
    {
      data=jsonDecode(responce.body.toString());
      print('#####3');
      print("data:$data");
    }
    else{}
    print('#####4');
  }
}

// class CompletedTask {
//   final String id;
//   final String title;
//   final String description;
//   final List<String> assignTo;
//   final DateTime startDate;
//   final DateTime deadlineDate;
//   final String startTime;
//   final String endTime;
//   final String phoneNumber;
//   final String status;
//   final String imagePath;
//
//   CompletedTask({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.assignTo,
//     required this.startDate,
//     required this.deadlineDate,
//     required this.startTime,
//     required this.endTime,
//     required this.phoneNumber,
//     required this.status,
//     required this.imagePath,
//   });
//
//   factory CompletedTask.fromJson(Map<String, dynamic> json) {
//     return CompletedTask(
//       id: json['_id'],
//       title: json['title'],
//       description: json['description'],
//       assignTo: List<String>.from(json['assignTo']),
//       startDate: DateTime.parse(json['startDate']),
//       deadlineDate: DateTime.parse(json['deadlineDate']),
//       startTime: json['startTime'],
//       endTime: json['endTime'],
//       phoneNumber: json['phoneNumber'],
//       status: json['status'],
//       imagePath: json['imagePath'],
//     );
//   }
// }
