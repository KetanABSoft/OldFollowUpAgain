import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:followup/OverdueTask.dart';
import 'package:followup/Taskincompleted.dart';
import 'package:followup/constant/conurl.dart';
import 'package:followup/create_lead.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:followup/notification_services.dart';
import 'package:http/http.dart' as http;
import 'AddTask.dart';
import 'ListAll.dart';
import 'Profile.dart';
import 'TaskCompleted.dart';
import 'TaskReceive.dart';
import 'TaskSend.dart';

import 'package:flutter/services.dart';
import 'package:followup/Notifications_screen.dart';

String? id;
var mainid;
String? userid;
String? cmpid;
String? admintype;
String? listall;
String? completed;
String? receive;
String? send;
String? token;
int notificationCount = 0;
bool _isExitConfirmed = false;
bool isClockedIn = false;
DateTime? clockInTime;
DateTime? clockOutTime;
late String currentDate;
late String userLocation = '';



Future fcmtoken() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  //token = preferences.getString('token');
  admintype = preferences.getString('admintype');
  String? token = await FirebaseMessaging.instance.getToken();

  id = preferences.getString('id');
  var urlString = AppString.constanturl + 'update_fcm';

  Uri uri = Uri.parse(urlString);
  var response = await http.post(uri,
      body: {"fcm_token": '$token', "admintype": '$admintype', "id": '$id'});
}


Future<bool> onWillPopnew(BuildContext context) async {
  print("hiiii");
  if (_isExitConfirmed) {
    return true;
  } else {
    final confirmExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Exit App', style: TextStyle(fontFamily: 'Poppins')),
          content: Text('Do you want to exit the app?',
              style: TextStyle(fontFamily: 'Poppins')),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No', style: TextStyle(fontFamily: 'Poppins')),
            ),
            TextButton(
              onPressed: () {
                _isExitConfirmed = true;
                Navigator.of(context).pop(true);
              },
              child: Text('Yes', style: TextStyle(fontFamily: 'Poppins')),
            ),
          ],
        );
      },
    );

    if (confirmExit == true) {
      // User confirmed their intention to exit the app
      return true;
    } else {
      // User canceled the exit, so prevent it
      return false;
    }
  }
}

NotificationServices notificationServices = NotificationServices();

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin {
  Timer? timer;
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    super.initState();
    fetchlist();
    Firebase.initializeApp();
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit();
    fetchcount();
    print(notificationCount);
    fetchlist();
    fcmtoken();
    decodeToken();
  }

  dynamic jsonData;

  void fetchcount() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString('id');
    cmpid = preferences.getString('cmpid');
    admintype = preferences.getString('admintype');
    String currentTime = preferences.getString('preferencetime') ?? "";
    var url = Uri.parse(AppString.constanturl + 'getnotificationscount');
    final response = await http.post(url, body: {
      "id": id,
      "cmpid": cmpid,
      "admintype": admintype,
      "date": currentTime,
    });
    var jsondata = jsonDecode(response.body);
    setState(() {
      notificationCount = int.parse(jsondata['count']);
    });
  }

  Future<void> fetchlist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String empTaskCountToken = prefs.getString("token") ?? "";
    print("Token From Pending API $empTaskCountToken");
    try {
      final response = await http.get(
        Uri.parse("http://103.159.85.246:4000/api/task/taskCounts"),
        headers: {
          'Authorization': empTaskCountToken,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          Map<String, dynamic> jsonData = jsonDecode(response.body);
          print("Ketan ########### $jsonData");
          String list = jsonData['todayAddedTasks'].toString();
          String incompleted = jsonData['pendingTasks'].toString();
          String completed = jsonData['completedTasks'].toString();
          String receive = jsonData['receivedTasks'].toString();
          String send = jsonData['sendTasks'].toString();
          double overdue = double.parse(jsonData['overdueTasks'].toString());
          try {
            double doubleValue1 = double.tryParse(list) ?? 0.0;
            double doubleValue2 = double.tryParse(completed) ?? 0.0;
            double doubleValue3 = double.tryParse(receive) ?? 0.0;
            double doubleValue4 = double.tryParse(send) ?? 0.0;
            double doubleValue5 = double.tryParse(incompleted) ?? 0.0;
            double doubleValue6 = overdue;
            print("######### Pending Task Value are $doubleValue5");
            taskData[0] = TaskData(
              taskName: 'Task',
              taskValue: doubleValue1.isFinite ? doubleValue1 : 0.0,
              taskColor: Colors.purple,
            );
            taskData[1] = TaskData(
              taskName: 'Pending',
              taskValue: doubleValue5.isFinite ? doubleValue5 : 0.0,
              taskColor: Color(0xff7c81dd),
            );
            taskData[2] = TaskData(
              taskName: 'Overdue',
              taskValue: doubleValue6.isFinite ? doubleValue6 : 0.0,
              taskColor: Color.fromARGB(255, 194, 24, 7),
            );
            taskData[3] = TaskData(
              taskName: 'Completed',
              taskValue: doubleValue2.isFinite ? doubleValue2 : 0.0,
              taskColor: Color.fromARGB(255, 96, 175, 96),
            );
            taskData[4] = TaskData(
              taskName: 'Send',
              taskValue: doubleValue4.isFinite ? doubleValue4 : 0.0,
              taskColor: Colors.amber,
            );
            taskData[5] = TaskData(
              taskName: 'Receive',
              taskValue: doubleValue3.isFinite ? doubleValue3 : 0.0,
              taskColor: Colors.pink,
            );
          } catch (e) {
            print('Error parsing data: $e');
            // Handle parsing error as needed
          }
        });
      } else {
        print('Error fetching data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      // Handle HTTP request error
    }

    timer?.cancel();
    timer = null;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  int _currentIndex = 0;
  @override
  bool get wantKeepAlive => true;
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (_currentIndex == 1) {
        // Profile tab is pressed
        _handleAddTask(context);
      } else if (_currentIndex == 2) {
        _handleAddLead(context);
      } else if (_currentIndex == 3) {
        _handleNotifications(context);
      } else if (_currentIndex == 4) {
        _handleProfile(context);
      } else {
        _handleDashboard(context);
      }
    });
  }

  final List<TaskData> taskData = [
    TaskData(
      taskName: 'Task',
      taskValue: 0, // Use a placeholder or default value
      taskColor: Colors.purple,
    ),
    TaskData(
      taskName: 'Pending',
      taskValue: 0, // Use a placeholder or default value
      taskColor: Color.fromARGB(255, 77, 77, 174),
    ),
    TaskData(
      taskName: 'Overdue',
      taskValue: 0, // Use a placeholder or default value
      taskColor: Color.fromARGB(
        255, // Alpha component (fully opaque)
        194, // Red component
        24, // Green component
        7, // Blue component
      ),
    ),
    TaskData(
      taskName: 'Completed',
      taskValue: 0, // Use a placeholder or default value
      taskColor: Color.fromARGB(255, 96, 175, 96),
    ),
    TaskData(
      taskName: 'Send',
      taskValue: 0, // Use a placeholder or default value
      taskColor: Color.fromARGB(255, 230, 200, 32),
    ),
    TaskData(
      taskName: 'Receive',
      taskValue: 0, // Use a placeholder or default value
      taskColor: Colors.orange,
    ),
  ];

  final List<String> items = [
    'Todays Added Task',
    'Task Pending',
    'Task Overdue',
    'Task Completed',
    'Task Send',
    'Task Receive'
  ];

  final List<String> icons = [
    'assets/totaltask.png',
    'assets/Pendingtask.png',
    'assets/Overduetask.png',
    'assets/Completedtask.png',
    'assets/Taskreceived.png',
    'assets/Tasksend.png',
  ];
  final List<Color> colors = [
    Colors.purple,
    Color.fromARGB(255, 77, 77, 174),
    Color.fromARGB(
      255, // Alpha component (fully opaque)
      194, // Red component
      24, // Green component
      7, // Blue component
    ),
    Color.fromARGB(255, 96, 175, 96),
    Color.fromARGB(255, 230, 200, 32),
    Colors.orange,
  ];
  void _handleDashboard(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(),
      ),
    );
  }

  void _handleProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => profilemanagement(),
      ),
    );
  }

  void _handleAddTask(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove('titleaudio');
    preferences.remove('startdateaudio');
    preferences.remove('deadlinedateaudio');
    preferences.remove('starttimeaudio');
    preferences.remove('endtimeaudio');
    preferences.remove('picaudio');
    preferences.remove('selectedValues');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeAddTask(audioPath: AppString.audiourl),
      ),
   );
  }

  void _handleAddLead(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LeadForm(id: '0', task: '')),
    );
  }

  void _handleCard1Tap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListScreen(admin_type: admintype.toString()),
      ),
   );
  }

  void _handleNotifications(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NotificationScreen(admin_type: admintype.toString()),
      ),
   );
  }

  void _handleCardincompltedTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        Taskincompleted()
            // Taskincompletednew(admin_type: admintype.toString()),
      ),
   );
  }

  void handleoverduetask() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OverdueTask(admin_type: admintype.toString()),
      ),
    );
  }

  void _handleCard2Tap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskCompletedScreen(),
      ),
   );
  }

  void _handleCard3Tap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiveTaskScreen(),
      ),
   );
  }

  void _handleCard4Tap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeSendTask(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onWillPopnew(context),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: BoxDecoration(
              color:Color(0xff7c81dd), // Set app bar background color
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
              automaticallyImplyLeading: false,
              backgroundColor: Colors
                  .transparent, // Set app bar background color to transparent
              elevation: 0, // Remove app bar shadow
              title: Row(
                children: [
                  Padding(
                    padding:  EdgeInsets.only(bottom: 17),
                    child: const Text(
                      'Task Management',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:Colors.white, // Set app bar text color to white
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 15, left: 13),  // Adjust padding here
                    child: GestureDetector(
                      onTap: (){
                        clockInOut();
                      },
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                isClockedIn ? 'Clock Out' : 'Clock In',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          // Display clock-in time below clock-in button if clocked in
                          if (isClockedIn && clockInTime != null)
                            Text(
                              'Clock In Time: ${DateFormat.jm().format(clockInTime!)}',
                              style: TextStyle(fontSize: 14, color: Colors.white),
                            ),
                          // Display clock-out time below clock-out button if clocked out
                          if (!isClockedIn && clockOutTime != null)
                            Text(
                              'Clock Out Time: ${DateFormat.jm().format(clockOutTime!)}',
                              style: TextStyle(fontSize: 14, color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  )

                ],
              ),
            ),
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Expanded(
              //   flex: 1,
              //   child: TaskManagementChart(data: taskData),
              // ),
              Container(
                height: 300, // Set the desired height for the chart
                child: TaskManagementChart(data: taskData),
              ),
              SizedBox(height: 15.0),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(items.length, (index) {
                      return Card(
                        child: ListTile(
                          leading: Container(
                            width: 40, // Adjust the width as needed
                            height: 30, // Adjust the height as needed
                            decoration: BoxDecoration(
                              //color: Color.fromARGB(255, 238, 232, 232),
                              borderRadius: BorderRadius.circular(
                                  10.0), // Adjust the border radius as needed
                            ),
                            child: Image.asset(
                              icons[index], // Use the icon path from the list
                              width: 20, // Adjust the icon width as needed
                              height: 20, // Adjust the icon height as needed
                            ),
                          ),
                          title: Text(
                            '${items[index]}',
                            style: TextStyle(
                              fontSize: 14, // Font size
                              fontWeight: FontWeight.bold, // Font weight
                              color: Colors.black, // Text color
                            ),
                          ),
                          trailing: Text(
                            '${taskData[index].taskValue.toInt()}',
                            style: TextStyle(
                              fontSize: 16, // Font size
                              color: Colors.grey, // Text color
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          onTap: () {
                            switch (index) {
                              case 0:
                                _handleCard1Tap(context);
                                break;
                              case 1:
                                _handleCardincompltedTap();
                                break;
                              case 2:
                                handleoverduetask();
                              case 3:
                                _handleCard2Tap();
                                break;
                              case 4:
                                _handleCard4Tap();
                                break;
                              case 5:
                                _handleCard3Tap();
                                break;
                            }
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Color(0xFFFFD700),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: Color(0xFFFFD700),
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            selectedItemColor: AppString.appgraycolor,
            unselectedItemColor: AppString.appgraycolor,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add),
                label: 'Add Task',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add),
                label: 'New lead',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    Icon(Icons.notifications),
                    Positioned(
                      right: 0,
                      top: -1,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: Text(
                          notificationCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                label: 'Notifications',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
  void showResponseDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color(0xff7c81dd),
        content: Text(message),
        duration: Duration(seconds: 3), // Adjust the duration as needed
      ),
    );
  }


  Future<String> postClockIn() async {
    Map<String, dynamic> data = {
      'email': 'tanaya@gmail.com',
      'role': 'sub-employee',
      'ip': '103.17.159.50',
      'lat': '37.4219983',
      'long': '-122.084',
    };

    try {
      final response = await http.post(
        Uri.parse("http://103.159.85.246:4000/api/salary/clock-ins"),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print('Clock In Response: $responseData');
        return 'Clock in successful'; // Return success message
      } else {
        print('Clock In Error: ${response.statusCode}');
        return 'Failed to clock in'; // Return specific error message for failed response
      }
    } catch (e) {
      print('Exception during clock in: $e');
      return 'Failed to clock in'; // Return specific error message for exception
    }
  }


  Future<String> postClockOut() async {
    Map<String, dynamic> data = {
      'email': 'tanaya@gmail.com',
      'role': 'sub-employee',
      'ip': '103.17.159.50',
      'lat': '37.4219983',
      'long': '-122.084',
    };

    try {
      final response = await http.post(
        Uri.parse("http://103.159.85.246:4000/api/salary/clock-outs"),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print('Clock Out Response: $responseData');
        return 'Clock out successful'; // Return success message
      } else {
        print('Clock Out Error: ${response.statusCode}');
        return 'Failed to clock out'; // Return specific error message for failed response
      }
    } catch (e) {
      print('Exception during clock out: $e');
      return 'Failed to clock out'; // Return specific error message for exception
    }
  }


  TextEditingController emailController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  final GlobalKey<FormState> Key = GlobalKey<FormState>();


  String jwtToken = '';
  String deviceId = ''; // RxString to hold device ID
  String publicIp = '';
  String Email = ''; // RxString to hold user's email
  String Role = '';
  // var workHoursByDate = {}.obs;// RxString to hold user's role

  void setToken(String newToken) {
    jwtToken = newToken;
    decodeToken();
  }
  void decodeToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String EmpDecodeToken = await prefs.getString("token") ?? "";
      print("Token From Decode API $EmpDecodeToken");
      String? tokenValue = EmpDecodeToken; // Get the token value
      if (tokenValue == null || tokenValue.isEmpty) {
        throw Exception('Token is null or empty');
      }

      // Split the token into its parts: header, payload, and signature
      List<String> parts = tokenValue.split('.');

      // Ensure that the token has the expected number of parts (header, payload, signature)
      if (parts.length != 3) {
        throw Exception('Invalid token format');
      }

      // Decode the payload from base64Url encoding
      String payload = parts[1];
      String decodedPayload = utf8.decode(base64Url.decode(base64Url.normalize(payload)));

      // Parse the JSON data in the payload
      Map<String, dynamic> payloadData = jsonDecode(decodedPayload);

      // Example of accessing data from the payload
      String userId = payloadData['subEmployeeId'] ?? ''; // User ID
      String email = payloadData['email'] ?? '';
      String role = payloadData['role'] ?? '';
      String fullName = payloadData['name'] ?? '';
      String username = payloadData['username'] ?? '';
      int issuedAt = payloadData['iat'] ?? 0; // Issued at (timestamp)


      await prefs.setString('subEmployeeId', userId);
      await prefs.setString('role', role);
      await prefs.setString('email', email);

      // Print or use the decoded data
      print('User ID: $userId');
      print('Email: $email');
      print('Role: $role');
      print('Full Name: $fullName');
      print('Username: $username');
      print('Issued At: $issuedAt');

      // Print SharedPreferences values
      String savedUserId = prefs.getString('subEmployeeId') ?? '';
      String savedEmail = prefs.getString('email') ?? '';
      String savedRole = prefs.getString('role') ?? '';

      print('SharedPreferences - User ID: $savedUserId');
      print('SharedPreferences - Email: $savedEmail');
      print('SharedPreferences - Role: $savedRole');

      // Update RxString values
      Email = savedEmail;
      Role = savedRole;

      // Optionally, store the decoded data in variables or use them further in your application
    } catch (e) {
      print('Error decoding token: $e');
      // Optionally handle errors or re-throw as needed
    }
  }


  void clockInOut() async {
    setState(() {
      if (isClockedIn) {
        clockOutTime = DateTime.now();
        postClockOut().then((message) {
          showResponseDialog(message);
        }).catchError((error) {
          print('Error during clock out: $error');
          showResponseDialog('Failed to clock out');
        });
      } else {
        clockInTime = DateTime.now();
        postClockIn().then((message) {
          showResponseDialog(message);
        }).catchError((error) {
          print('Error during clock in: $error');
          showResponseDialog('Failed to clock in');
        });
      }
      isClockedIn = !isClockedIn;
    });
  }

  void getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        print('Device ID: ${deviceId}');
      } else if (Platform.isIOS) {
        // Handle iOS device info retrieval
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '';
        print('Device ID: ${deviceId}');
      }
    } catch (e) {
      print('Error retrieving device info: $e');
    }
  }

  Future<void> postData(double latitude, double longitude) async {
    try {
      // Example of using Email or Role values in the POST data
      Map<String, dynamic> data = {
        'email': Email,
        'role': Role,
        'latitude': 37.4219983,
        'longitude': -122.084,
        'ip_addresses': ['103.17.159.50', '103.17.159.51'], // List of IP addresses
      };

      final response = await http.post(
        Uri.parse("http://103.159.85.246:4000/api/salary/clock-ins"),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print('Data Added: $responseData');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending data: $e');
    }
  }
  var datas;
  Future<void> timeshit() async {
    final requestData = {
      'email': emailController.text.trim(),
      'startDate': startDateController.text.toString(),
      'endDate': endDateController.text.toString(),
    };
    try {
      final response = await http.post(
        Uri.parse("http://localhost:5000/api/salary/fetch-work-hours"),
        body: jsonEncode(requestData),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      if(response.statusCode==200)
      {
        datas=jsonDecode(response.body.toString());
        print('Data:${datas}');
      }

    } catch (e) {
      print('Exception during fetch operation: $e');
    }
  }



}

class TaskData {
  final String taskName;
  final double taskValue;
  final Color taskColor;

  TaskData({
    required this.taskName,
    required this.taskValue,
    required this.taskColor,
  });
}

class TaskManagementChart extends StatelessWidget {
  final List<TaskData> data;

  TaskManagementChart({required this.data});

  @override
  Widget build(BuildContext context) {
    List<charts.Series<TaskData, String>> series = [
      charts.Series<TaskData, String>(
        id: 'Tasks',
        data: data,
        domainFn: (TaskData task, _) => task.taskName,
        measureFn: (TaskData task, _) => task.taskValue,
        colorFn: (TaskData task, _) =>
            charts.ColorUtil.fromDartColor(task.taskColor),
        labelAccessorFn: (TaskData task, _) => '${task.taskValue.toInt()}',
      ),
    ];

    bool allValuesZero = data.every((task) => task.taskValue == 0);

    if (allValuesZero) {
      // If all values are zero, display a gray pie chart
      return Container(
        width: 200, // Adjust the width as needed
        height: 200, // Adjust the height as needed
        decoration: BoxDecoration(
          shape: BoxShape.circle, // Create a circular shape
          color: Colors.grey, // Set the background color to gray
        ),
        child: Center(
          child: Text(
            '0',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    } else {
      try {
        return charts.PieChart(
          series,
          animate: true,
          defaultRenderer: charts.ArcRendererConfig<String>(
            arcWidth: 60,
            arcRendererDecorators: [charts.ArcLabelDecorator()],
          ),
        );
      } catch (e, stackTrace) {
        print('PieChart rendering error: $e\n$stackTrace');
        return Container();
      }
    }
  }
}
