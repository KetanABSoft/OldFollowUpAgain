import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:followup/OverdueTask.dart';
import 'package:followup/Taskincompleted.dart';
import 'package:followup/constant/conurl.dart';
import 'package:followup/create_lead.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:followup/notification_services.dart';
import 'package:http/http.dart' as http;
import '../AddTask.dart';
import '../ListAll.dart';
import '../Profile.dart';


import 'package:flutter/services.dart';
import 'package:followup/Notifications_screen.dart';

import '../TaskCompleted.dart';
import '../TaskReceive.dart';
import '../TaskSend.dart';
import 'admin_add_employee.dart';
import 'admin_add_lead.dart';
import 'admin_add_task.dart';
import 'admin_overdue_task.dart';
import 'admin_pending_task.dart';
import 'admin_profile_screen.dart';
import 'admin_total_task_screen.dart';
import 'calculate_salary.dart';


// import 'package:followupnew/ListAll.dart';

// import 'AddTask.dart';
// import 'TaskCompleted.dart';
// import 'TaskReceive.dart';
// import 'TaskSend.dart';

// void main() {
//   runApp(TaskManagementApp());
// }
String? id1;
var mainid;
String? userid1;
String? cmpid1;
String? admintype1;
String? listall1;
String? completed1;
String? receive1;
String? send1;
String? token1;
int notificationCount1 = 0;
bool _isExitConfirmed1 = false;

Future fcmtoken() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  //token = preferences.getString('token');
  admintype1 = preferences.getString('admintype');
  String? token = await FirebaseMessaging.instance.getToken();

  id1 = preferences.getString('id');
  var urlString = AppString.constanturl + 'update_fcm';

  Uri uri = Uri.parse(urlString);
  var response = await http.post(uri,
      body: {"fcm_token": '$token', "admintype": '$admintype1', "id": '$id1'});
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //       print(message.toString());
  //         try {
  //   Map<String, dynamic> data = message.data;
  //        notificationServices.showNotification(data);
  //        print(data);
  // } catch (e) {
  //   print('Exception: $e');
  // }
  //    });
  // notificationServices.showNotification();
  runApp(AdminDashboardScreen());
  //runApp(const MyApp());
}

Future<bool> onWillPopnew(BuildContext context) async {
  print("hiiii");
  if (_isExitConfirmed1) {
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
                _isExitConfirmed1 = true;
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

// class TaskManagementApp extends StatelessWidget {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   bool _isExitConfirmed = false;

//   @override
//   Widget build(BuildContext context) {
//     final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//     // Navigator.pop(context, 'true');
//     _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     // });
//     _firebaseMessaging.getToken().then((token) async {
//       SharedPreferences preferences = await SharedPreferences.getInstance();

//       preferences.setString("token", '$token');
//       //print(token);
//     });
//     return WillPopScope(
//       onWillPop: () => _onWillPop(context),
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: DashboardScreen(),
//       ),
//     );
//   }

//   Future<bool> _onWillPop(BuildContext context) async {
//     if (_isExitConfirmed) {
//       return true; // Allow the app to exit
//     } else {
//       final confirmExit = await showDialog<bool>(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text('Exit App', style: TextStyle(fontFamily: 'Poppins')),
//             content: Text('Do you want to exit the app?',
//                 style: TextStyle(fontFamily: 'Poppins')),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(false),
//                 child: Text('No', style: TextStyle(fontFamily: 'Poppins')),
//               ),
//               TextButton(
//                 onPressed: () {
//                   _isExitConfirmed = true;
//                   Navigator.of(context).pop(true);
//                 },
//                 child: Text('Yes', style: TextStyle(fontFamily: 'Poppins')),
//               ),
//             ],
//           );
//         },
//       );

//       if (confirmExit == true) {
//         return true; // Allow the app to exit
//       } else {
//         return false; // Stay on the dashboard page
//       }
//     }
//   }
// }

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with AutomaticKeepAliveClientMixin {
  Timer? timer;
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit();
    fetchcount();
    print(notificationCount1);
    //Navigator.pop(context);

    setState(() {
      // Navigator.of(context).pop();
    });
    fetchlist();
    fcmtoken();

    // onWillPop(context);
    //timer = Timer.periodic(Duration(minutes: 11111), (_) => fetchlist());
  }

  dynamic jsonData;

  void fetchcount() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id1 = preferences.getString('id');
    cmpid1= preferences.getString('cmpid');
    admintype1 = preferences.getString('admintype');
    String currentTime = preferences.getString('preferencetime') ?? "";

    var url = Uri.parse(AppString.constanturl + 'getnotificationscount');
    final response = await http.post(url, body: {
      "id": id1,
      "cmpid": cmpid1,
      "admintype": admintype1,
      "date": currentTime,
    });

    var jsondata = jsonDecode(response.body);

    setState(() {
      notificationCount1 = int.parse(jsondata['count']);
    });
  }

  Future<void> fetchlist() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userid1 = preferences.getString('id');
    cmpid1 = preferences.getString('cmpid');
    admintype1 = preferences.getString('admintype');
    //String apiUrl = 'http://testfollowup.absoftwaresolution.in/getlist.php?Type=gettaskcount';
    String apiUrl = AppString.constanturl + 'gettaskcount';
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {'id': userid1, 'cmpid': cmpid1, 'admintype': admintype1},
    );
    if (response.statusCode == 200) {
      setState(() {
        jsonData = jsonDecode(response.body);
        String list = jsonData['alllist'];
        String incompleted = jsonData['incompleted'];
        String completed = jsonData['completed'];
        String receive = jsonData['receive'];
        String send = jsonData['send'];
        double overdue = double.parse(jsonData['overdue'].toString());

        try {
          double doubleValue1 = double.parse(list);
          double doubleValue2 = double.parse(completed);
          double doubleValue3 = double.parse(receive);
          double doubleValue4 = double.parse(send);
          double doubleValue5 = double.parse(incompleted);
          double doubleValue6 = overdue;

          taskData[0] = TaskData(
            taskName: 'Task',
            taskValue: doubleValue1.isFinite ? doubleValue1 : 0,
            taskColor: Colors.purple,
          );
          taskData[1] = TaskData(
            taskName: 'Pending',
            taskValue: doubleValue5.isFinite ? doubleValue5 : 0,
            taskColor: Color.fromARGB(255, 77, 77, 174),
          );
          taskData[2] = TaskData(
            taskName: 'Overdue',
            taskValue: doubleValue6.isFinite ? doubleValue6 : 0,
            taskColor: Color.fromARGB(
              255, // Alpha component (fully opaque)
              194, // Red component
              24, // Green component
              7, // Blue component
            ),
          );
          taskData[3] = TaskData(
            taskName: 'Completed',
            taskValue: doubleValue2.isFinite ? doubleValue2 : 0,
            taskColor: Color.fromARGB(255, 96, 175, 96),
          );
          taskData[4] = TaskData(
            taskName: 'Send',
            taskValue: doubleValue4.isFinite ? doubleValue4 : 0,
            taskColor: Color.fromARGB(255, 230, 200, 32),
          );
          taskData[5] = TaskData(
            taskName: 'Receive',
            taskValue: doubleValue3.isFinite ? doubleValue3 : 0,
            taskColor: Colors.orange,
          );
        } catch (e) {
          print('Error parsing data: $e');
          // Assign default values or handle the error as per your app's requirements
        }
      });
    } else {
      print('Error fetching data. Status code: ${response.statusCode}');
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
        _handleAddEmployee(context);
      }
      else if(_currentIndex==2)
      {
        _handleAddTask(context);
      }

      else if (_currentIndex == 3) {
        _handleAddLead(context);
      } else if (_currentIndex == 4) {
        _handleNotifications(context);
      } else if (_currentIndex == 5) {
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
      taskValue: 5, // Use a placeholder or default value
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
      taskValue: 5, // Use a placeholder or default value
      taskColor: Color.fromARGB(255, 96, 175, 96),
    ),
    TaskData(
      taskName: 'Send',
      taskValue: 5, // Use a placeholder or default value
      taskColor: Color.fromARGB(255, 230, 200, 32),
    ),
    TaskData(
      taskName: 'Receive',
      taskValue: 5, // Use a placeholder or default value
      taskColor: Colors.orange,
    ),
  ];

  final List<String> items = [
    'Total Task',
    'Task Pending',
    'Task Overdue',
    'Task Completed',
    'Task Send',
    'Task Receive'
  ];
  // final List<IconData> icons = [
  //   Icons.task, // Total tasks icon
  //   Icons.incomplete_circle, // Completed tasks icon
  //   Icons.expand_more_outlined,
  //   Icons.check, // Completed tasks icon
  //   Icons.arrow_upward,
  //   Icons.arrow_downward, // Received tasks icon
  //   // Sent tasks icon
  // ];
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
        builder: (context) => AdminDashboardScreen(),
      ),
    );
  }

  void _handleProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminProfileScreen(),
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
        builder: (context) => AdminAddTask(audioPath: ''),
      ),
    );
  }

  void _handleAddLead(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddLead(id: '0', task: '')),
    );
  }

  void _handleCard1Tap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminTotalTask(admin_type: admintype1.toString()),
      ),
    );
  }

  void _handleNotifications(BuildContext context) async {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) =>
    //         NotificationScreen(admin_type: admintype1.toString()),
    //   ),
    // );
  }

  void _handleCardincompltedTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AdminTaskincompleted(),
      ),
    );
  }

  void handleoverduetask() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminOverdueTask(admin_type: admintype1.toString()),
      ),
    );
  }

  void _handleCard2Tap() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => CompletedTask(admin_type: admintype1.toString()),
    //   ),
    // );
  }

  void _handleCard3Tap() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ReceiveTask(admin_type: admintype1.toString()),
    //   ),
    // );
  }

  void _handleCard4Tap() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => SendTask(admin_type: admintype1.toString()),
    //   ),
    // );
  }
  void _handleAddEmployee(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEmployeeScreen()),
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
                'Task Management',
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
        endDrawer: Container(
          width: MediaQuery.of(context).size.width * 0.7, // Set 70% of screen width
          child: Drawer(
            // Wrap Drawer with a Container to set width
            child: Container(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: DrawerHeader(
                      decoration: BoxDecoration(
                        color: Color(0xFFFFD700),
                      ),
                      child: Text(
                        'Drawer Header',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.monetization_on), // Use Icons.monetization_on for salary calculation
                    title: Text('Calculate Salary',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.grey.shade800),),
                    onTap: () {
                      // Navigate or perform action
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>CalculateSalary()));
                      // Add your navigation code here
                    },
                  ),
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
                              fontFamily: 'Poppins',
                              fontSize: 14, // Font size
                              fontWeight: FontWeight.bold, // Font weight
                              color: Colors.black, // Text color
                            ),
                          ),
                          trailing: Text(
                            '${taskData[index].taskValue.toInt()}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
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
                              case 6:
                                _handleAddEmployee(context);
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
                icon: Icon(Icons.person_add), // Change the icon to an appropriate icon for adding an employee
                label: 'Add Employee', // Label for the tab
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
                          notificationCount1.toString(),
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