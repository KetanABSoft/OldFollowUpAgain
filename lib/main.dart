import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'AddTask.dart';
import 'TaskCompleted.dart';
import 'Taskincompleted.dart';
import 'create_lead.dart';
import 'dashboard.dart';
import 'demo.dart';
import 'firebase_options.dart';
import 'loginscreen.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:followup/notification_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
  FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  SharedPreferences preferences = await SharedPreferences.getInstance();

  String? previoustime = preferences.getString('currentTime');
  DateTime previousDateTime;
  if (previoustime != null && previoustime.isNotEmpty) {
    previousDateTime = DateTime.parse(previoustime);
    // previousDateTime = DateTime.now();
  } else {
    previousDateTime = DateTime.now();
  }
  preferences.setString('preferencetime', previousDateTime.toString());

  DateTime currentTime = DateTime.now();
  preferences.setString('currentTime', currentTime.toString());
  var id = preferences.getString('id');
  runApp(Sizer(
    builder:
        (BuildContext context, Orientation orientation, DeviceType deviceType) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
                  // home: id == null ? CameraScreen() : CameraScreen(),
                  //   home: id == null ? EmployeeAddTask(audioPath: '',): EmployeeAddTask(audioPath: '',),
                     home: id == null ? loginScreen(): loginScreen(),
      );
    },
  ));
}

@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  try {
    Map<String, dynamic> data = message.data;
    notificationServices.showNotification(data);
    //notificationServices.showNotification(message);
  } catch (e) {
    print('Exception: $e');
  }
}

NotificationServices notificationServices = NotificationServices();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: textmyapp(),
    );
  }
}

class textmyapp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => textmyappnew();
}

class textmyappnew extends State<textmyapp> {
  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    try {
      Map<String, dynamic> data = message.data;
      notificationServices.showNotification(data);
      //notificationServices.showNotification(message);
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Notification',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const loginScreen(),
    );
  }
}
