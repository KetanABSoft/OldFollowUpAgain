import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:followup/EditTask.dart';
import 'package:followup/Recorder.dart';
import 'package:followup/constant/conurl.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'ListAll.dart';
import 'Taskincompleted.dart';
import 'dashboard.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:followup/notification_services.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

bool isButtonEnabled = false;
var pic;
String? id;
var mainid;
String? userid;
String? cmpid;
String? admintype;
String? titleaudio;
String? startdateaudio;
String? deadlinedateaudio;
String? starttimeaudio;
String? endtimeaudio;
List<dynamic>? assigntoaudio;
String? picaudio;
//String ?formattedEndDate;
String dropdowntext = 'Please select at least one assign';
Timer? _toastTimer;
var uuid = Uuid();
var uniqueId = uuid.v1();

class EmployeeAddTask extends StatefulWidget {
  final String audioPath;
  const EmployeeAddTask({
    Key? key,
    required this.audioPath,
  }) : super(key: key);

  @override
  _EmployeeAddTaskState createState() =>
      _EmployeeAddTaskState(audioPath: audioPath);
}

class _EmployeeAddTaskState extends State<EmployeeAddTask> {
  String audioPath;

  _EmployeeAddTaskState({required this.audioPath});
  ScrollController controller = ScrollController();
  int? randomNumber;

  GlobalKey<FormFieldState<dynamic>> dropdown1Key =
      GlobalKey<FormFieldState<dynamic>>();
  XFile? image;
  final ImagePicker picker = ImagePicker();
  dynamic selectedValue;
  dynamic dynamicValues;
  File? _selectedAudio = null;
  bool isLoading = false;
  List<dynamic> dropdownData = [];
  List<dynamic> selectedData = [];
  // List<Employee>? employees;
  List<Employee> selectedEmployees = [];
  // Generate a version 4 UUID

  void getdata() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    title.text = preferences.getString('titleaudio') ?? '';
    startdate.text = preferences.getString('startdateaudio') ?? '';
    deadlinedate.text = preferences.getString('deadlinedateaudio') ?? '';
    starttime.text = preferences.getString('starttimeaudio') ?? '';
    endtime.text = preferences.getString('endtimeaudio') ?? '';
    pic = preferences.getString('picaudio');
    String currentTime =
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}";

    if (starttime.text == '') {
      setState(() {
        starttime.text = currentTime;
      });
    }
    if (endtime.text == '') {
      setState(() {
        endtime.text = currentTime;
      });
    }
    if (startdate.text == '') {
      setState(() {
        DateTime date = DateTime.now();
        startdate.text = DateFormat('dd-MM-yyyy').format(date);
      });
    }
    if (deadlinedate.text == '') {
      setState(() {
        DateTime date = DateTime.now();
        deadlinedate.text = DateFormat('dd-MM-yyyy').format(date);
      });
    }
  }

  Future<void> saveSelectedValuesToPrefs(List<dynamic> values) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> stringValues =
        values.map((value) => value.toString()).toList();
    await preferences.setStringList('selectedValues', stringValues);
  }
  Future<List<dynamic>> getSelectedValuesFromPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String>? stringValues = preferences.getStringList('selectedValues');
    dynamicValues = stringValues?.map((value) => value).toList() ?? [];
    return dynamicValues;
  }

  void startContinuousToast() {
    // Create a Timer that will repeatedly call showContinuousToast every 5 seconds
    _toastTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      showContinuousToast();
    });
  }

  void stopContinuousToast() {
    _toastTimer?.cancel();
  }

  void showContinuousToast() {
    // Display the toast message
    Fluttertoast.showToast(
      msg: 'Please wait while task is adding',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void initState()  {
    super.initState();
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String savedUserId = prefs.getString('subEmployeeId') ?? '';
    // print('SharedPreferences From Init  - User ID: $savedUserId');

    getdata();
    fetchEmployees();
    //generateRandomNumber();
    getSelectedValuesFromPrefs().then((values) {
      setState(() {
        selectedData = values;
      });
    });
    WidgetsBinding.instance!.addPostFrameCallback((_) {});
    fetchDropdownData();
    fetchEmployees().then((fetchedEmployees) {
      setState(() {
        employeess = fetchedEmployees;
      });
    });
  }
//void notification

  var xyz;

  Future<bool> addTask(String titleText, String startdateText, String descroptionText, String deadlinedateText, String reminderDateText, String starttimeText, String endtimeText, String remindertimeText) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? storedId = prefs.getString('subEmployeeId');
    String getEmpId = await prefs.getString("_id") ?? "";
    print("###############%%%%%%%%%%%%%%%%%%%%$getEmpId");
    print("#### Ketan  ID $storedId");

    Map<String, dynamic> abc = {
      "title": title.text,
      "description": description.text,
      "assignTo": [getEmpId.toString()],
      "startDate": startdate.text,
      "deadlineDate": deadlinedate.text,
      "reminderDate": reminderDate.text,
      "startTime": starttime.text,
      "endTime": endtime.text,
      "reminderTime": remindertime.text,
      "status": "pending",
      "assignedBy": storedId.toString()
    };
    print("## Ketan Map ${abc}");
    try {
      String EmpAddTaskToken = await prefs.getString("token") ?? "";
      print("Token From Add Task API $EmpAddTaskToken");
      final response = await http.post(
        Uri.parse("http://103.159.85.246:4000/api/task/createSubemployeeTask"),
        body: jsonEncode(abc),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization':EmpAddTaskToken, // Replace with your actual JWT token
        },
      );
      if (response.statusCode == 201) {
        var xyz = jsonDecode(response.body);
        print("###### decode $xyz");
        String id = xyz["tasks"][0]["_id"].toString();
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Id is $id");
        await prefs.setString('id', id);
        String AddTaskId = await prefs.getString("id") ?? "";
        print("Id From AddTask  $AddTaskId");
        return true;
      } else {
        print('### Error: ${response.statusCode}');
        return false; // Return specific error message for failed response
      }
    } catch (e) {
      print('#### Exception during add operation: $e');
      return false; // Return specific error message for exception
    }
  }


  Future<void> requestStoragePermission() async {
    PermissionStatus status = await Permission.manageExternalStorage.request();

    if (status.isGranted) {
      print(' 1st denied');
      // Permission granted, you can proceed with accessing both external and internal storage
      _selectAudio();
    } else if (status.isDenied) {
      print(' 2nd denied');
      // Permission denied by the user, handle accordingly
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Permission Denied',
              style: TextStyle(fontFamily: 'Poppins')),
          content: Text('Please grant permission to access external storage.',
              style: TextStyle()),
          actions: <Widget>[
            ElevatedButton(
              child: Text('OK', style:TextStyle(fontFamily: 'Poppins')),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } else if (status.isPermanentlyDenied || status.isRestricted) {
      // Permission permanently denied or restricted, open app settings to enable the permission
      _selectAudio();
    }
  }

  Future<void> sendimage(List<String> ids) async {
    if (image != null) {
      print(image!.path);
      // var uri = Uri.parse("http://testfollowup.absoftwaresolution.in/getlist.php?Type=addimage");
      var uri = Uri.parse(AppString.constanturl + "addimage");

      for (var id in ids) {
        // print('iddddd: $id');
        print(uniqueId);
        var newuniq = uuid.v1();
        var request = http.MultipartRequest('POST', uri);

        var multipartFile = await http.MultipartFile.fromPath(
            'image', image!.path,
            filename: '${newuniq}_image.jpg');

        request.files.add(multipartFile);
        request.fields['id'] = id;

        await request.send().then((result) {
          http.Response.fromStream(result).then((response) async {
            final jsonData = jsonDecode(response.body);
            // Handle the response data as needed
          });
        });
      }
    } else {
      print('No Image selected.');
    }
  }

  //we can upload image from camera or from gallery based on parameter
  Future sendImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);
    if (img != null) {
      XFile? compressedImage = await compressImage(XFile(img.path));

      setState(() {
        image = compressedImage;
      });

      if (compressedImage != null) {
        pic = await http.MultipartFile.fromPath("image", compressedImage.path);
      }
    }
  }

  Future<XFile?> compressImage(XFile file) async {
    final filePath = file.path;

    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, lastIndex);
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";

    XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      minWidth: 1000,
      minHeight: 1000,
      quality: 70,
    );

    return compressedFile;
  }

  Future<void> _selectAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      setState(() {
        _selectedAudio = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadAudio(String id) async {
    print('_selectedAudio' + audioPath);
    String filePath = audioPath; // Replace with the actual file path
    File file = File(filePath);

    if (file.existsSync()) {
      int fileSizeInBytes = file.lengthSync();
      double fileSizeInKB = fileSizeInBytes / 1024; // Convert bytes to KB

      print('File Size: ${fileSizeInKB.toStringAsFixed(2)} KB');
    } else {
      print('File does not exist.');
    }
    if (_selectedAudio != null) {
      id = id;
      final url = Uri.parse(AppString.constanturl + 'addaudio');
      var request = http.MultipartRequest('POST', url);
      request.files.add(
          await http.MultipartFile.fromPath('audio', _selectedAudio!.path));
      request.fields['id'] = id;
      var response = await request.send();
      if (response.statusCode == 200) {
        print('Audio uploaded successfully.');
      } else {
        print('Failed to upload audio. Error: ${response.reasonPhrase}');
      }
    } else if (audioPath != null) {
      final url = Uri.parse(AppString.constanturl + 'addaudio');
      var request = http.MultipartRequest('POST', url);

      // Open the audio file
      var file = File(audioPath);
      if (await file.exists()) {
        // Create a new MultipartFile from the audio file
        var audio = await http.MultipartFile.fromPath('audio', file.path);

        // Add the audio file to the request
        request.files.add(audio);

        // Add other request fields as needed
        request.fields['id'] = id;

        try {
          // Send the request and get the response
          var response = await request.send();

          if (response.statusCode == 200) {
            // Audio uploaded successfully
            print('Audio uploaded successfully.');
          } else {
            // Failed to upload audio
            print('Failed to upload audio. Error: ${response.reasonPhrase}');
          }
        } catch (e) {
          // Exception occurred during the upload process
          print('Failed to upload audio. Error: $e');
        }
      } else {
        // Audio file does not exist
        print('Audio file not found.');
      }
    } else {
      print('No audio file selected.');
    }
  }

  void myAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text('Please choose media to select',
                style: TextStyle(fontFamily: 'Poppins')),
            content: Container(
              height: MediaQuery.of(context).size.height / 6,
              child: Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color(0xFFFFD700), // Set the button color to purple
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      sendImage(ImageSource.camera);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.camera, color: AppString.appgraycolor),
                        Text('From Camera',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                color: AppString.appgraycolor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void myAudio() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text('Please choose media to select',
              style: TextStyle(fontFamily: 'Poppins')),
          content: Container(
            height: MediaQuery.of(context).size.height / 6,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle audio recording
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyApp(
                          title: title.text,
                          startdate: startdate.text,
                          deadlinedate: deadlinedate.text,
                          starttime: starttime.text,
                          endtime: endtime.text,
                          image: image.toString(),
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.record_voice_over),
                      Text('Recorder', style: TextStyle(fontFamily: 'Poppins')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  DateTime date = DateTime.now();
  //newdate = DateFormat('yyyy-MM-dd').format(dateTime);
  TimeOfDay time = TimeOfDay.now();

  TextEditingController startdate = TextEditingController();
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController deadlinedate = TextEditingController();
  TextEditingController starttime = TextEditingController();
  TextEditingController endtime = TextEditingController();
  TextEditingController remindertime = TextEditingController();
  TextEditingController reminderDate = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var dropdownvalue;
  @override
  void dispose() {
    // _timer?.cancel();

    super.dispose();
  }

  Future<void> fetchDropdownData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userid = preferences.getString('id');
    cmpid = preferences.getString('cmpid');
    admintype = preferences.getString('admintype');
    //String apiUrl = 'http://testfollowup.absoftwaresolution.in/getlist.php?Type=get_employee';
    String apiUrl = AppString.constanturl + 'get_employee';
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {'id': userid, 'cmpid': cmpid, 'admintype': admintype},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        dropdownData = json.decode(response.body);
      });
    } else {
      print(
          'Error fetching dropdown data. Status code: ${response.statusCode}');
    }
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Widget MyLoaderWidget() {
    return Center(
      child: CircularProgressIndicator(), // or your preferred loader widget
    );
  }

  @override
  Widget build(BuildContext context) {
    String audioPath = widget.audioPath;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff7c81dd),
        elevation: 0,
        title: Text(
          'Add Task',
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
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardScreen(),
                ));
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: title,
                  maxLines: null,
                  decoration: const InputDecoration(
                      labelText: 'Title',
                      helperText: "",
                      labelStyle: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      )),
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: description,
                  maxLines: null,
                  decoration: const InputDecoration(
                      labelText: 'Description',
                      helperText: "",
                      labelStyle: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      )),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        height: 40,
                        child: TextFormField(
                          decoration: const InputDecoration(
                              icon: Icon(Icons.date_range),
                              labelText: 'Start Date',
                              labelStyle: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(7))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(7))),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(7)))),
                          controller: startdate,
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1950),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              DateTime currentDateWithoutTime = DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day);
                              DateTime pickedDateWithoutTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day);

                              if (pickedDateWithoutTime
                                      .isAfter(currentDateWithoutTime) ||
                                  pickedDateWithoutTime.isAtSameMomentAs(
                                      currentDateWithoutTime)) {
                                DateTime pickedStartDate = pickedDate;

                                DateTime pickedEndDate = pickedStartDate;

                                String formattedStartDate =
                                    DateFormat('yyyy-MM-dd')
                                        .format(pickedStartDate);

                                String formattedEndDate =
                                    DateFormat('yyyy-MM-dd')
                                        .format(pickedEndDate);

                                DateTime pickedEndDate2 =
                                    DateFormat('yyyy-MM-dd')
                                        .parse(deadlinedate.text);

                                if (pickedEndDate2.isAfter(pickedStartDate)) {
                                  setState(() {
                                    startdate.text = DateFormat('yyyy-MM-dd')
                                        .format(pickedStartDate);
                                    deadlinedate.text = DateFormat('yyyy-MM-dd')
                                        .format(pickedEndDate2);
                                  });
                                } else {
                                  setState(() {
                                    startdate.text = formattedStartDate;
                                    deadlinedate.text =
                                        formattedEndDate.toString();
                                  });
                                }
                              } else {
                                // Display an error message or take appropriate action
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Invalid Date',
                                          style:
                                              TextStyle(fontFamily: 'Poppins')),
                                      content: Text(
                                          'Please select the correct date.',
                                          style:
                                              TextStyle(fontFamily: 'Poppins')),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('OK',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins')),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Flexible(
                      child: Container(
                        height: 40,
                        child: TextField(
                          controller: starttime,
                          decoration: const InputDecoration(
                              icon: Icon(Icons.timer),
                              labelText: 'Start Time',
                              labelStyle: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(7))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(7))),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(7)))),
                          readOnly: true,
                          onTap: () async {
                            DateTime now = DateTime.now();
                            print("iwontcorrecttime");
                            DateFormat dateFormat = DateFormat(
                                'dd-MM-yyyy'); // Format for the start date
                            DateTime selectedStartDate =
                                startdate.text.isNotEmpty
                                    ? dateFormat.parse(startdate.text)
                                    : DateTime(0);
                            print(selectedStartDate);
                            print(DateTime(now.year, now.month, now.day));
                            if (selectedStartDate.isAfter(
                                DateTime(now.year, now.month, now.day))) {
                              TimeOfDay? pickedTime = await showTimePicker(
                                initialTime: TimeOfDay.now(),
                                context: context,
                              );
                              if (pickedTime != null) {
                                DateTime now = DateTime.now();
                                String formattedTime =
                                    DateFormat('HH:mm:ss').format(
                                   DateTime(now.year, now.month, now.day,
                                      pickedTime.hour, pickedTime.minute),
                                );
                                String endTimenew =
                                    DateFormat('HH:mm:ss').format(
                                  DateTime(now.year, now.month, now.day,
                                      pickedTime.hour + 1, pickedTime.minute),
                                );
                                // Delay the execution of setState
                                Future.delayed(Duration.zero, () {
                                  setState(() {
                                    starttime.text = formattedTime;
                                    endtime.text = endTimenew;
                                  });
                                });
                              } else {
                                print("Time is not selected");
                              }
                            } else {
                              TimeOfDay? pickedTime = await showTimePicker(
                                initialTime: TimeOfDay.now(),
                                context: context,

                              );
                              if (pickedTime != null) {
                                DateTime now = DateTime.now();
                                TimeOfDay currentTimeOfDay =
                                    TimeOfDay.fromDateTime(now);
                                if (pickedTime.hour < currentTimeOfDay.hour ||
                                    (pickedTime.hour == currentTimeOfDay.hour &&
                                        pickedTime.minute <
                                            currentTimeOfDay.minute)) {
                                  // Show error dialog
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Invalid Time',
                                            style: TextStyle(
                                                fontFamily: 'Poppins')),
                                        content: Text(
                                            'Please select the correct time.',
                                            style: TextStyle(
                                                fontFamily: 'Poppins')),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('OK',
                                                style: TextStyle(
                                                    fontFamily: 'Poppins')),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  // Update the UI with the picked time
                                  String formattedTime =
                                      DateFormat('HH:mm:ss').format(
                                    DateTime(now.year, now.month, now.day,
                                        pickedTime.hour, pickedTime.minute),
                                  );

                                  String endTimenew =
                                      DateFormat('HH:mm:ss').format(
                                    DateTime(now.year, now.month, now.day,
                                        pickedTime.hour + 1, pickedTime.minute),
                                  );
                                  // Delay the execution of setState
                                  Future.delayed(Duration.zero, () {
                                    setState(() {
                                      starttime.text = formattedTime;
                                      endtime.text = endTimenew;
                                    });
                                  });
                                }
                              } else {
                                print("Time is not selected");
                              }
                            }
                          },
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 30.0),
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        height: 40,
                        child: TextFormField(
                          decoration: const InputDecoration(
                              icon: Icon(Icons.date_range),
                              labelText: 'End Date',
                              labelStyle: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(7))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(7))),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(7)))),
                          controller: deadlinedate,
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1950),
                              lastDate: DateTime(2100),
                            );

                            if (pickedDate != null) {
                              DateTime currentDateWithoutTime = DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day);
                              DateTime pickedDateWithoutTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day);
                              DateTime startDate = DateFormat('yyyy-MM-dd')
                                  .parse(startdate.text);
                              print(DateFormat('HH:mm:ss')
                                  .format(DateTime.now()));

                              // Check if pickedDate is after the curformattedTimerent date
                              if (pickedDateWithoutTime
                                      .isAfter(currentDateWithoutTime) ||
                                  pickedDateWithoutTime.isAtSameMomentAs(
                                      currentDateWithoutTime)) {
                                // DateTime starttimenew=DateTime(int.parse(starttime.text));
                                int starttimenew = int.parse(
                                    starttime.text.split(":")[0] +
                                        starttime.text.split(":")[1]);
                                int endtimenew = int.parse(
                                    endtime.text.split(":")[0] +
                                        endtime.text.split(":")[1]);

                                // DateTime endtimenew=DateTime(int.parse(endtime.text));

                                DateTime now = DateTime.now();

                                // Check if picked end date is after or equal to start date
                                if (pickedDateWithoutTime.isAfter(startDate) ||
                                    (pickedDateWithoutTime
                                            .isAtSameMomentAs(startDate) &&
                                        starttimenew <= endtimenew)) {
                                  setState(() {
                                    String formattedDate =
                                        DateFormat('yyyy-MM-dd')
                                            .format(pickedDate);
                                    deadlinedate.text = formattedDate;
                                  });
                                } else {
                                  // Display an error message for invalid end date
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Invalid End Date',
                                            style: TextStyle(
                                                fontFamily: 'Poppins')),
                                        content: Text(
                                            'End date time should be grater than start date time. Please select the correct date.',
                                            style: TextStyle(
                                                fontFamily: 'Poppins')),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('OK',
                                                style: TextStyle(
                                                    fontFamily: 'Poppins')),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              } else {
                                print("helllo666");
                                // Display an error message for invalid date
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Invalid Date',
                                          style:
                                              TextStyle(fontFamily: 'Poppins')),
                                      content: Text(
                                          'Please select the correct date.',
                                          style:
                                              TextStyle(fontFamily: 'Poppins')),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('OK',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins')),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Flexible(
                      child: Container(
                        height: 40,
                        child: TextField(
                          controller: endtime,
                          decoration: const InputDecoration(
                              icon: Icon(Icons.timer),
                              labelText: 'End Time',
                              labelStyle: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(7))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(7))),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(7)))),
                          readOnly: true,
                          onTap: () async {
                            // TimeOfDay? pickedTime = await showTimePicker(
                            //   initialTime: TimeOfDay.now(),
                            //   context: context,
                            // );

                            DateTime now = DateTime.now();
                            DateFormat dateFormat = DateFormat(
                                'dd-MM-yyyy'); // Format for the start date

                            DateTime selectedStartDate =
                                startdate.text.isNotEmpty
                                    ? dateFormat.parse(startdate.text)
                                    : DateTime(0);
                            DateTime selectedendtDate =
                                deadlinedate.text.isNotEmpty
                                    ? dateFormat.parse(deadlinedate.text)
                                    : DateTime(0);
                            print("justcheck");
                            print(selectedStartDate);
                            print(selectedendtDate);
                            if (selectedendtDate.isAfter(selectedStartDate)) {
                              TimeOfDay? pickedTime = await showTimePicker(
                                initialTime: TimeOfDay.now(),
                                context: context,
                              );
                              if (pickedTime != null) {
                                DateTime now = DateTime.now();

                                String formattedTime =
                                    DateFormat('HH:mm:ss').format(
                                  DateTime(now.year, now.month, now.day,
                                      pickedTime.hour, pickedTime.minute),
                                );

                                // Delay the execution of setState
                                //   // Delay the execution of setState
                                //    Future.delayed(Duration.zero, () {
                                setState(() {
                                  endtime.text = formattedTime;
                                });
                                //  });
                              }
                            } else {
                              TimeOfDay? pickedTime = await showTimePicker(
                                initialTime: TimeOfDay.now(),
                                context: context,
                              );
                              if (pickedTime != null) {
                                DateTime currentDateWithoutTime = DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day);

                                DateTime now = DateTime.now();
                                TimeOfDay currentTimeOfDay =
                                    TimeOfDay.fromDateTime(now);
                                print(currentDateWithoutTime);
                                DateTime selectedendtDate =
                                    deadlinedate.text.isNotEmpty
                                        ? dateFormat.parse(deadlinedate.text)
                                        : DateTime(0);

                                if ((pickedTime.hour < currentTimeOfDay.hour ||
                                    (pickedTime.hour == currentTimeOfDay.hour &&
                                        pickedTime.minute <
                                            currentTimeOfDay.minute))) {
                                  // Show error dialog
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Invalid Time',
                                            style: TextStyle(
                                                fontFamily: 'Poppins')),
                                        content: Text(
                                            'Please select the correct time.',
                                            style: TextStyle(
                                                fontFamily: 'Poppins')),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('OK',
                                                style: TextStyle(
                                                    fontFamily: 'Poppins')),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  String formattedTime =
                                      DateFormat('HH:mm:ss').format(
                                    DateTime(now.year, now.month, now.day,
                                        pickedTime.hour, pickedTime.minute),
                                  );

                                  // Delay the execution of setState
                                  //   // Delay the execution of setState
                                  Future.delayed(Duration.zero, () {
                                    setState(() {
                                      endtime.text = formattedTime;
                                    });
                                  });
                                }
                              } else {
                                print("Time is not selected");
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30.0),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        child: TextFormField(
                          controller:
                          reminderDate,
                          decoration: InputDecoration(
                              icon: Icon(Icons.date_range, size: 20),
                              labelText: 'Reminder Date',
                              labelStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.black,
                                  fontSize: 15),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(7))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(7))),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(7)))),
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1950),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              DateTime currentDateWithoutTime = DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                              );
                              DateTime pickedDateWithoutTime = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                              );

                              DateTime startDate =
                              DateFormat('yyyy-MM-dd').parse(
                                  startdate.text);
                              DateTime endDate = DateFormat('yyyy-MM-dd')
                                  .parse(deadlinedate.text);

                              if ((pickedDateWithoutTime
                                  .isAfter(startDate) ||
                                  pickedDateWithoutTime
                                      .isAtSameMomentAs(startDate)) &&
                                  (pickedDateWithoutTime
                                      .isBefore(endDate) ||
                                      pickedDateWithoutTime
                                          .isAtSameMomentAs(endDate))) {
                                setState(() {
                                  reminderDate.text =
                                      DateFormat('yyyy-MM-dd')
                                          .format(pickedDate);
                                });
                                SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                                await prefs.setString(
                                    'reminderDate',
                                    reminderDate.text);
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Invalid Reminder Date',
                                          style: TextStyle(
                                              fontFamily: 'Poppins')),
                                      content: Text(
                                          'Please select a date between the start date and end date.',
                                          style: TextStyle(
                                              fontFamily: 'Poppins')),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('OK',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins')),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Container(
                        height: 40,
                        child: TextField(
                          controller:
                          remindertime,
                          decoration: InputDecoration(
                              icon: Icon(
                                Icons.timer,
                                size: 25,
                              ),
                              labelText: 'Reminder Time',
                              labelStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.black,
                                  fontSize: 15),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(7))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(7))),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(7)))),
                          readOnly: true,
                          onTap: () async {
                            DateTime now = DateTime.now();
                            DateFormat dateFormat = DateFormat(
                                'yyyy-MM-dd'); // Format for the start date

                            DateTime selectedStartDate =
                            startdate.text.isNotEmpty
                                ? dateFormat.parse(
                                startdate.text)
                                : DateTime(0);
                            DateTime selectedendtDate =
                            deadlinedate.text.isNotEmpty
                                ? dateFormat.parse(
                                deadlinedate.text)
                                : DateTime(0);
                            print("justcheck");
                            print(selectedStartDate);
                            print(selectedendtDate);
                            if (selectedendtDate
                                .isAfter(selectedStartDate)) {
                              TimeOfDay? pickedTime =
                              await showTimePicker(
                                initialTime: TimeOfDay.now(),
                                context: context,
                              );
                              if (pickedTime != null) {
                                DateTime now = DateTime.now();
                                String formattedTime =
                                DateFormat('HH:mm:ss').format(
                                  DateTime(now.year, now.month, now.day,
                                      pickedTime.hour, pickedTime.minute),
                                );
                                setState(() {
                                  remindertime.text = formattedTime;
                                });
                                SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                                await prefs.setString(
                                    'endTime', formattedTime);
                              }
                            } else {
                              TimeOfDay? pickedTime =
                              await showTimePicker(
                                initialTime: TimeOfDay.now(),
                                context: context,
                              );
                              if (pickedTime != null) {
                                DateTime currentDateWithoutTime =
                                DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day);
                                DateTime now = DateTime.now();
                                TimeOfDay currentTimeOfDay =
                                TimeOfDay.fromDateTime(now);
                                print(currentDateWithoutTime);
                                DateTime selectedendtDate =
                                deadlinedate.text.isNotEmpty
                                    ? dateFormat.parse(
                                    deadlinedate.text)
                                    : DateTime(0);
                                if ((pickedTime.hour <
                                    currentTimeOfDay.hour ||
                                    (pickedTime.hour ==
                                        currentTimeOfDay.hour &&
                                        pickedTime.minute <
                                            currentTimeOfDay.minute))) {
                                  // Show error dialog
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Invalid Time',
                                            style: TextStyle(
                                                fontFamily: 'Poppins')),
                                        content: Text(
                                            'Please select the correct time.',
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
                                } else {
                                  String formattedTime =
                                  DateFormat('HH:mm:ss').format(
                                    DateTime(
                                        now.year,
                                        now.month,
                                        now.day,
                                        pickedTime.hour,
                                        pickedTime.minute),
                                  );
                                  Future.delayed(Duration.zero, () {
                                    setState(() {
                                      endtime.text = formattedTime;
                                    });
                                  });
                                }
                              } else {
                                print("Time is not selected");
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30.0),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.all(Radius.circular(11))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      DropdownButton<Employee>(
                        underline: Container(
                          // Add this line to remove underline
                          height: 0,
                          color: Colors.transparent,
                        ),
                        hint: Row(
                          children: [
                            Text('Select Employee'),
                          ],
                        ),
                        value: null, // Dropdown doesn't have a pre-selected value
                        onChanged: (Employee? employee) {
                          setState(() {
                            if (employee != null &&
                                !selectedEmployees.contains(employee)) {
                              selectedEmployees.add(employee);
                            }
                          });
                        },
                        items: employeess.map((Employee employee) {
                          return DropdownMenuItem<Employee>(
                            value: employee,
                            child: Text(employee.name),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: selectedEmployees.map((Employee employeess) {
                          return Chip(
                            label: Text(employeess.name),
                            onDeleted: () {
                              setState(() {
                                selectedEmployees.remove(employeess);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 30.0),
                Row(
                  children: [
                    const SizedBox(width: 16.0),
                    Flexible(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff7c81dd),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyApp(
                                title: title.text,
                                startdate: startdate.text,
                                deadlinedate: deadlinedate.text,
                                starttime: starttime.text,
                                endtime: endtime.text,
                                image: image.toString(),
                              ),
                            ),
                          );
                        },
                        child: const Text('Upload Audio',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                            )),
                      ),
                    ),
                    const SizedBox(width: 36.0),
                    Flexible(
                      child: ElevatedButton(
                        onPressed: () {
                          myAlert();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff7c81dd),
                        ),
                        child: Text('Upload Photo',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ],
                ),
                _selectedAudio != null
                    ? Text(path.basename(_selectedAudio!.path),
                        style: TextStyle(fontFamily: 'Poppins'))
                    : audioPath != false && audioPath != AppString.audiourl
                        ? Text(path.basename(audioPath.toString()),
                            style: TextStyle(fontFamily: 'Poppins'))
                        : const Text(''),
                image != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(image!.path),
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            height: 150,
                          ),
                        ),
                      )
                    : const SizedBox(
                        height: 10,
                      ),
                image != null
                    ? //Text(path.basename(image!.path),style: TextStyle(fontFamily: 'Poppins'))
                    Text('')
                    : const Text(''),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff7c81dd),
                  ),
                  onPressed: isButtonEnabled
                      ? null
                      : () async {
                          var success = await addTask(
                              title.text,
                              description.text,
                              startdate.text,
                              starttime.text,
                              deadlinedate.text,
                              endtime.text,
                              reminderDate.text,
                              remindertime.text);
                          if (success) {
                            addTask(
                                title.text,
                                description.text,
                                startdate.text,
                                starttime.text,
                                deadlinedate.text,
                                endtime.text,
                                reminderDate.text,
                                remindertime.text);
                            title.clear();
                            description.clear();
                            startdate.clear();
                            starttime.clear();
                            deadlinedate.clear();
                            endtime.clear();
                            reminderDate.clear();
                            remindertime.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.green,
                                content:
                                    Text(' Congratulation Task is Cretaed '),
                                duration: Duration(seconds: 3),
                              ),
                            );
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return Taskincompleted();
                              },
                            ));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                    'Task is Not Cretaed Yet Please Fill All Fields Carefully'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                  child: isLoading
                      ? CircularProgressIndicator() // Show loader when isLoading is true
                      : Text('Save',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
List<Employee> employeess = [];
  Future<List<Employee>> fetchEmployees() async {
    final url = Uri.parse("http://103.159.85.246:4000/api/employee/subemployees/list");
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String empGetEmpToken = await prefs.getString("token") ?? "";
      print("Token From Completed API $empGetEmpToken");

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': empGetEmpToken,
        },
      );

      var data = jsonDecode(response.body.toString());
      if (response.statusCode == 200) {
        // Clear existing list before adding new employees
        employeess.clear();

        for (var index in data) {
          String employeeId = index["_id"];

          // Check if employee with this ID already exists in the list
          bool employeeExists = employeess.any((emp) => emp.id == employeeId);

          if (!employeeExists) {
            employeess.add(Employee.fromJson(index));
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('_id', employeeId);
          }
        }

        return employeess;
      } else {
        throw Exception('Failed to fetch employees');
      }
    } catch (e) {
      throw Exception('Failed to fetch employees: $e');
    }
  }
}
class Employee {
  String id;
  String name;
  String phoneNumber;
  String email;

  Employee({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
  });

  // Factory method to create Employee object from JSON
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['_id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
    );
  }
}

class TaskTextField extends StatelessWidget {
  final String hintText;
  final BorderRadius borderRadius;

  const TaskTextField({
    required this.hintText,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
    );
  }
}
