import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import '../constant/conurl.dart';
import '../create_lead.dart';
import 'admin_add_lead.dart';
import 'admin_dashboard.dart';

class AdminLeadList extends StatefulWidget {
  const AdminLeadList({Key? key}) : super(key: key);

  @override
  State<AdminLeadList> createState() => _AdminLeadListState();
}

class _AdminLeadListState extends State<AdminLeadList> {
  List<dynamic> leads = [];
  ScrollController controller = ScrollController();
  bool isDeleteAlertOpen = false;

  @override
  void initState() {
    super.initState();
    showList();
  }

  void showList() async {
    final url = Uri.parse("http://103.159.85.246:4000/api/lead/leadList");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InZhcmFkQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImFkbWluVXNlcklkIjoiNjY1NDVkMmEyYzZmMWMxMjE1OTM5ODgxIiwiYWRtaW5Db21wYW55TmFtZSI6IkFjbWUiLCJlbXBsb3llZUlkIjoiNjY1NDVkOTUyYzZmMWMxMjE1OTM5ODhiIiwibmFtZSI6IlZhcmFkIiwiaWF0IjoxNzIwMDc2MDUyfQ.BDHsJwZ5dP_LRp9HrII2A_LPw70-X9n-bC2Q7OtKcJQ',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          leads = jsonDecode(response.body);
        });
      } else {
        throw Exception('Failed to fetch lead list: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching lead list : $e');
    }
  }

  void deleteLead(String id) async {
    bool? confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text("Are you sure you want to delete this lead?"),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                Navigator.of(context).pop(true);
                await performDelete(id);
              },
            ),
          ],
        );
      },
    );

    if (confirmed ?? false) {
      showList(); // Refresh list after deletion
    }
  }

  Future<void> performDelete(String id) async {
    try {
      final url = Uri.parse("http://localhost:5000/api/lead/delete_lead");
      final response = await http.post(url, body: {"id": id});

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['success'] == "success") {
          Fluttertoast.showToast(
            backgroundColor: Colors.green,
            textColor: Colors.white,
            msg: jsonData['message'],
            toastLength: Toast.LENGTH_SHORT,
          );
        }
      } else {
        throw Exception('Failed to delete lead: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting lead : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFFFD700),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Lead List',
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
              icon: Icon(Icons.arrow_back, color: AppString.appgraycolor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddLead(id: '', task: ''),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          controller: controller,
          itemCount: leads.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeadForm(
                        id: '${leads[index]['id'] ?? ''}',
                        task: 'view',
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 14,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 45,

                        padding: EdgeInsets.only(
                          top: 1,
                          left: 10,
                          bottom: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color(0xFFFFD700),
                        ),
                        child: Row(
                          children: [
                            Text(
                              leads[index]['assignedByName'] ?? '',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.visibility),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LeadForm(
                                      id: '${leads[index]['id'] ?? ''}',
                                      task: 'view',
                                    ),
                                  ),
                                );
                              },
                              color: Colors.white,
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LeadForm(
                                      id: '${leads[index]['id'] ?? ''}',
                                      task: 'edit',
                                    ),
                                  ),
                                );
                              },
                              color: Colors.white,
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                deleteLead('${leads[index]['id'] ?? ''}');
                              },
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      Opacity(
                        opacity: 1,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${leads[index]['customerName'] ?? ''}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${leads[index]['contactNo'] ?? ''}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${leads[index]['email'] ?? ''}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${leads[index]['ownerName'] ?? ''}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // Padding(
                              //   padding:  EdgeInsets.only(right: 880),
                              //   child: Text(
                              //     '${leads[index]['description'] ?? ''}',
                              //     style: TextStyle(
                              //       fontSize: 14,
                              //       fontWeight: FontWeight.bold,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),

                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}