import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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
    getApi();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
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
      body: FutureBuilder(
        future: getApi(),
        builder: (context , snapshot){
          if(snapshot.hasData)
            {
              return Expanded(
                child: ListView.builder(
                  itemCount:completedTasks.length,
                  itemBuilder: (context, index) {
                    var startDate = DateTime.parse(completedTasks[index]["startDate"]);
                    var formattedStartDate =
                    DateFormat('yyyy-MM-dd').format(startDate);
                    var endDate = DateTime.parse(completedTasks[index]["deadlineDate"]);
                    var formattedEndDate =
                    DateFormat('yyyy-MM-dd').format(endDate);
                    return Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 50,
                              color:Colors.green,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text(
                                      "${completedTasks[index]["status"]}",
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
                                    "${completedTasks[index]["title"]}",
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
                                          "${completedTasks[index]["startTime"]}",
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
                                          "${completedTasks[index]["endTime"]}",
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
  var data;
  List<dynamic> completedTasks = [];
  Future<void> getApi() async {
    final response = await http.get(Uri.parse("http://103.159.85.246:4000/api/task/tasks/completedByEmp"),
    headers: {
      "Authorization":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWJFbXBsb3llZUlkIjoiNjY1NDVlMjcyYzZmMWMxMjE1OTM5OGE0IiwiZW1haWwiOiJ0YW5heWFAZ21haWwuY29tIiwicm9sZSI6InN1Yi1lbXBsb3llZSIsImFkbWluQ29tcGFueU5hbWUiOiJBY21lIiwibmFtZSI6IlRhbmF5YSIsImlhdCI6MTcyMDA4NDQ3Mn0.k3OIKIwkGRTqIPZDZBXPnW1trisnOdACBhFkNUchc54"
    }
    );
    if(response.statusCode==200)
      {
        data = jsonDecode(response.body.toString());
        setState(() {
          completedTasks = data["completedTasks"];
        });
        print("###### Data is $completedTasks");
        return data;
      }
    else
      {
        print("#@@@@@@@@@ Data is $data");
        return data;
      }
  }
}

