import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:followup/Lead_list.dart';
import 'package:followup/constant/conurl.dart';
import 'package:followup/dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeadForm extends StatefulWidget {
  final String? id;
  final String? task;

  LeadForm({required this.id, required this.task});

  @override
  State<LeadForm> createState() => _LeadFormState();
}

File? _selectedImage = null;
final picker = ImagePicker();

class _LeadFormState extends State<LeadForm> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController CustomerName = TextEditingController();
  TextEditingController CompanyName = TextEditingController();
  TextEditingController ContactNo = TextEditingController();
  TextEditingController MailId = TextEditingController();
  TextEditingController Website = TextEditingController();
  TextEditingController Description = TextEditingController();
  TextEditingController OwnerName = TextEditingController();

  LocationData? currentLocation;
  String? leadImageUrl = null;
  String? imageUrl = null;

  @override
  void initState() {
    getLocation();
    getlead(widget.id);
    super.initState();
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
                      backgroundColor: Color(0xFFFFD700),
                    ),
                    onPressed: () {
                      _captureImage();
                      Navigator.pop(context);
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

  Future<void> _selectImageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        imageUrl = null;
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        imageUrl = null;
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Widget _buildSelectedImage() {
    if (_selectedImage != null || imageUrl != null) {
      return Container(
        height: 150, // Set the desired height here
        child: imageUrl != null
            ? Image.network(imageUrl!)
            : Image.file(_selectedImage!),
      );
    } else {
      return SizedBox();
    }
  }

  Future<void> getlead(id) async {
    var urlString = AppString.constanturl + 'getleaddetails';
    Uri uri = Uri.parse(urlString);
    var response = await http.post(uri, body: {
      "id": '$id',
    });
    var jsondata = jsonDecode(response.body);
    print(jsondata);
    CustomerName.text = jsondata['customer_name'] ?? "";
    CompanyName.text = jsondata['company_name'] ?? "";
    ContactNo.text = jsondata['contact_no'] ?? "";
    MailId.text = jsondata['mail_id'] ?? "";
    Website.text = jsondata['website'] ?? "";
    Description.text = jsondata['description'] ?? "";
    OwnerName.text = jsondata['owner_name'] ?? "";
    leadImageUrl = jsondata['lead_img'];
    if (leadImageUrl != null && leadImageUrl!.isNotEmpty) {
      setState(() {
        imageUrl = AppString.imageurl + '$leadImageUrl';
      });
    } else {
      setState(() {
        _selectedImage = null;
        imageUrl = null;
      });
    }
  }

  Future<void> getLocation() async {
    var location = Location();
    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void savelead(customer_name, company_name, contact_no, mail_id, website, desc,
      owner_name) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString('id');
    cmpid = preferences.getString('cmpid');

    var urlString = AppString.constanturl + 'create_lead';
    Uri uri = Uri.parse(urlString);
    var response = await http.post(uri, body: {
      "customer_name": customer_name,
      "company_name": company_name,
      "contact_number": contact_no,
      "mail_id": mail_id,
      "website": website,
      "description": desc,
      "owner_name": owner_name,
      "lat": '${currentLocation?.latitude}',
      "long": '${currentLocation?.longitude}',
      "emp_id": '${id}',
      "company_id": '${cmpid}',
    });

    var jsonResponse = json.decode(response.body);
    if (_selectedImage != null) {
      saveimage(jsonResponse['id']);
    }
    if (jsonResponse['result'] == "sucess") {
      Fluttertoast.showToast(
        backgroundColor: const Color.fromARGB(255, 0, 255, 55),
        textColor: Colors.white,
        msg: 'Lead Added Successfully.',
        toastLength: Toast.LENGTH_SHORT,
      );
      setState(() {
        _selectedImage == null;
        imageUrl == null;
        CustomerName.text = "";
        CompanyName.text = "";
        ContactNo.text = "";
        MailId.text = "";
        Description.text = "";
        OwnerName.text = "";
        Website.text = "";
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LeadList()),
      );
    }
  }

  Future<void> saveimage(id) async {
    try {
      var urlString = AppString.constanturl + 'addLeadimage'; // Update the URL
      Uri uri = Uri.parse(urlString);
      var request = http.MultipartRequest('POST', uri);

      // Assuming _selectedImage is an XFile from an image picker
      if (_selectedImage != null) {
        String imagePath = _selectedImage!.path; // Get the file path from XFile

        // Compress the selected image
        List<int> compressedImage = await FlutterImageCompress.compressWithList(
          File(imagePath).readAsBytesSync(),
          quality: 80, // Adjust the compression quality as needed
        );

        var compressedFile = File(imagePath)..writeAsBytesSync(compressedImage);

        request.files.add(
          await http.MultipartFile.fromPath(
            'image', // Field name for the image in your API
            compressedFile.path, // Use the compressed image path
          ),
        );

        request.fields['id'] = id.toString();
        var response = await request.send();
        if (response.statusCode == 200) {
          setState(() {
            _selectedImage = null;
            imageUrl = null;
          });
          print('Image uploaded successfully');
        } else {
          print('Image upload failed with status code: ${response.statusCode}');
        }
      } else {
        print('No image selected for upload');
      }
    } catch (e) {
      print('Error during image upload: $e');
    }
  }

  void updatelead(customer_name, company_name, contact_no, mail_id, website,
      desc, owner_name) async {
    var urlString = AppString.constanturl + 'update_lead';
    Uri uri = Uri.parse(urlString);
    var response = await http.post(uri, body: {
      "customer_name": customer_name,
      "company_name": company_name,
      "contact_number": contact_no,
      "mail_id": mail_id,
      "website": website,
      "description": desc,
      "owner_name": owner_name,
      "lat": '${currentLocation?.latitude}',
      "long": '${currentLocation?.longitude}',
      "id": widget.id
    });

    var jsondata = jsonDecode(response.body);
    if (_selectedImage != null) {
      saveimage(widget.id);
    }
    if (jsondata['result'] == "sucess") {
      Fluttertoast.showToast(
        backgroundColor: const Color.fromARGB(255, 0, 255, 55),
        textColor: Colors.white,
        msg: 'Lead Updated Successfully.',
        toastLength: Toast.LENGTH_SHORT,
      );
      setState(() {
        _selectedImage == null;
        imageUrl == null;
        CustomerName.text = "";
        CompanyName.text = "";
        ContactNo.text = "";
        MailId.text = "";
        Description.text = "";
        OwnerName.text = "";
        Website.text = "";
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LeadList()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff7c81dd),
          elevation: 0,
          title: Text(
            'Create Lead',
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardScreen(),));
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 25,horizontal: 25),
              child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Container(
                        height: 70,
                        child: TextFormField(
                          controller: CustomerName,
                          decoration: const InputDecoration(
                            labelText: 'Customer Name',
                              helperText: "",
                            labelStyle: TextStyle(
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
                              )
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(
                                r'[a-zA-Z ]')), // Allow letters and spaces
                          ],
                        ),
                      ),
                      // SizedBox(height: 12,),
                      Container(
                        height: 70,
                        child: TextFormField(
                          controller: CompanyName,
                          decoration: const InputDecoration(
                            labelText: 'Company Name',
                            helperText: "",
                            labelStyle: TextStyle(
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
                              )
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Company Name is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      // SizedBox(height: 20,),
                      Container(
                        height: 70,
                        child: TextFormField(
                          controller: ContactNo,
                          decoration: const InputDecoration(
                            labelText: 'Contact number',
                              helperText: "",
                            labelStyle: TextStyle(
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
                              )
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9]')), // Allow only numbers
                            LengthLimitingTextInputFormatter(
                                10), // Limit the length to 10 characters
                          ],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Contact number is required';
                            }
                            if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                              return 'Invalid contact number format';
                            }
                            return null;
                          },
                        ),
                      ),
                      // SizedBox(height: 20,),
                      Container(
                        height: 70,
                        child: TextFormField(
                          controller: MailId,
                          decoration: const InputDecoration(
                            labelText: 'Mail Id',
                              helperText: "",
                            labelStyle: TextStyle(
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
                              )
                          ),

                        ),
                      ),
                      // SizedBox(height: 20,),
                      Container(
                        height: 70,
                        child: TextFormField(
                          controller: Website,
                          decoration: const InputDecoration(
                            labelText: 'Website',
                              helperText: "",
                            labelStyle: TextStyle(
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
                              )
                          ),
                        ),
                      ),
                      // SizedBox(height: 20,),
                      Container(
                        height: 80,
                        child: TextFormField(
                          controller: Description,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            labelStyle: TextStyle(
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
                              )
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Container(
                        height: 70,
                        child: TextFormField(
                          controller: OwnerName,
                          decoration: const InputDecoration(
                            labelText: 'Owner name',
                              helperText: "",
                            labelStyle: TextStyle(
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
                              )
                          ),

                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      //(_selectedImage != null)
                      _buildSelectedImage(),
                      // : SizedBox(
                      //     height: 10,
                      //   ),
                      if (widget.task != 'view')
                        ElevatedButton(
                          onPressed: () {
                            myAlert();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:Color(0xff7c81dd),
                          ),
                          child: Text('Upload Photo',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color:Colors.white,
                              )),
                        ),
                      SizedBox(
                        height: 20,
                      ),
                      if (widget.task != 'view')
                        (Row(
                          children: [
                            Expanded(
                              child: (widget.id != '0')
                                  ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  Color(0xff7c81dd),
                                ),
                                child: Text(
                                  'Update',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color:Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  if (formKey.currentState!
                                      .validate()) {
                                    // updatelead(
                                    //   CustomerName.text,
                                    //   CompanyName.text,
                                    //   ContactNo.text,
                                    //   MailId.text,
                                    //   Website.text,
                                    //   Description.text,
                                    //   OwnerName.text,
                                    // );
                                    updateleead();
                                  }
                                },
                              )
                                  : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    Color(0xff7c81dd),
                                  ),
                                  child: Text('Save',
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                        color: Colors.white,)),
                                  onPressed: () async {
                                    if (formKey.currentState!
                                        .validate()) {
                                      bool success = await addlead();
                                      if(success)
                                        {
                                          addlead();
                                          CustomerName.clear();
                                          CompanyName.clear();
                                          ContactNo.clear();
                                          MailId.clear();
                                          Website.clear();
                                          Description.clear();
                                          OwnerName.clear();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.green,
                                              content: Text('Lead is Created Succesfully'),
                                              duration: Duration(seconds: 3),
                                            ),
                                          );
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => LeadList(),));
                                        }
                                      else
                                        {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Lead is not created please Fill all Fields'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        }

                                    }
                                  }),
                            ),
                            SizedBox(
                                width:
                                16), // You can adjust the spacing between buttons
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xff7c81dd),
                                ),
                                child: Text(
                                  'Show list',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LeadList()),
                                  );
                                  setState(() {
                                    _selectedImage = null;
                                    imageUrl = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ))
                    ],
                  ))),
        ));
  }
  var data1;

  Future<bool> addlead() async {
    Map<String, dynamic> abc = {
      'customerName': CustomerName.text.trim(),
      'companyName':CompanyName.text.trim(),
      'contactNo': ContactNo.text.trim(),
      'email':MailId.text.trim(),
      'description': Description.text.trim(),
      'ownerName': OwnerName.text.trim(),
      'website': Website.text.trim(),
    };
    try {
      final response = await http.post(
        Uri.parse("http://103.159.85.246:4000/api/lead/createLead"),
        body: jsonEncode(abc),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWJFbXBsb3llZUlkIjoiNjY1NDVlMjcyYzZmMWMxMjE1OTM5OGE0IiwiZW1haWwiOiJ0YW5heWFAZ21haWwuY29tIiwicm9sZSI6InN1Yi1lbXBsb3llZSIsImFkbWluQ29tcGFueU5hbWUiOiJBY21lIiwibmFtZSI6IlRhbmF5YSIsImlhdCI6MTcyMDA4NDQ3Mn0.k3OIKIwkGRTqIPZDZBXPnW1trisnOdACBhFkNUchc54",
        },
      );
      if (response.statusCode == 200) {
        data1 = jsonDecode(response.body);
        print('#### Data Added: $data1');
        return true; // Return true on successful response
      } else {
        print('Error: ${response.statusCode}');
        print('Error Body: ${response.body}');
        return false; // Return false on error response
      }
    } catch (e) {
      print('Exception during add operation: $e');
      return false; // Return false on exception
    }
  }
  Future<bool> updateleead() async {
    Map<String, dynamic> abc = {
      // your map initialization
    };
    try {
      final response = await http.put(
        Uri.parse("http://103.159.85.246:4000/api/lead/editLead/668bc85787514aa3ae6e5937"),
        body: jsonEncode(abc),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWJFbXBsb3llZUlkIjoiNjY1NDVlMjcyYzZmMWMxMjE1OTM5OGE0IiwiZW1haWwiOiJ0YW5heWFAZ21haWwuY29tIiwicm9sZSI6InN1Yi1lbXBsb3llZSIsImFkbWluQ29tcGFueU5hbWUiOiJBY21lIiwibmFtZSI6IlRhbmF5YSIsImlhdCI6MTcyMDA4NDQ3Mn0.k3OIKIwkGRTqIPZDZBXPnW1trisnOdACBhFkNUchc54",
        },
      );
      if (response.statusCode == 200) {
        // Successful update
        print('#### Data Updated: ${response.body}');
        return true;
      } else {
        // Error updating
        print('Error: ${response.statusCode}');
        print('Error Body: ${response.body}');
        return false;
      }
    } catch (e) {
      // Exception
      print('Exception during update operation: $e');
      return false;
    }
  }
}
