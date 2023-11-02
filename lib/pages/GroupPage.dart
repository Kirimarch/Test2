// ignore_for_file: file_names, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors, library_private_types_in_public_api, avoid_print, use_build_context_synchronously, unnecessary_null_comparison, non_constant_identifier_names, unused_local_variable

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modernlogintute/pages/TaskDetailsPage.dart';

class GroupPage extends StatelessWidget {
  final String groupName;
  final String groupId;
  GroupPage({required this.groupName, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          SizedBox(width: 20),
          IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _confirmDelete(context);
              }),
          SizedBox(width: 20),
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _showAddMemberDialog(context);
              }),
          SizedBox(width: 20),
          IconButton(
            icon: Icon(Icons.add_task),
            onPressed: () {
              _showAddTaskDialog(context);
            },
          ),
        ],
        title: Center(
          child: Text(
            groupName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('groupId', isEqualTo: groupId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No tasks found'));
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              DateTime selectedDate = data['selectedDate'].toDate();
              DateTime now = DateTime.now();
              Duration difference = selectedDate.difference(now);
              int days = difference.inDays;
              int hours = difference.inHours.remainder(24);
              int minutes = difference.inMinutes.remainder(60);

              Color randomColor = Color.fromARGB(
                Random().nextInt(255),
                Random().nextInt(255),
                Random().nextInt(255),
                Random().nextInt(255),
              );

              return GestureDetector(
                onTap: () {
                  _handleTaskTap(context, data);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: days < 0 || hours < 0 || minutes < 0
                        ? Colors.red
                        : randomColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Task name: ${data['taskName']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Description: ${data['taskDescription']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5),
                      _buildCountdownWidget(days, hours, minutes),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildCountdownWidget(int days, int hours, int minutes) {
    if (days < 0 || hours < 0 || minutes < 0) {
      days = 0;
      hours = 0;
      minutes = 0;
    }

    String countdownText = 'Ends in: $days days $hours hours $minutes minutes';
    Color boxColor =
        days < 0 || hours < 0 || minutes < 0 ? Colors.red : Colors.blue;
    IconData iconData = days < 0 || hours < 0 || minutes < 0
        ? Icons.warning
        : Icons.access_alarm;

    return Row(
      children: [
        Icon(
          iconData,
          color: Colors.white,
        ),
        SizedBox(width: 5),
        Text(
          countdownText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    TextEditingController memberIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add members'),
          content: TextField(
            controller: memberIdController,
            decoration: InputDecoration(
              hintText: 'Enter member UserId',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                try {
                  String groupIds =
                      groupId; // ใส่ค่า groupId ที่ต้องการจาก Firebase Firestore

                  Clipboard.setData(ClipboardData(text: groupIds));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Copied the code to the clipboard.'),
                    ),
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                    ),
                  );
                }
              },
              child: Text('Copy Code'),
            ),
            TextButton(
              onPressed: () async {
                String userId = memberIdController.text;
                await addMemberToGroup(context, userId);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> addMemberToGroup(BuildContext context, String userId) async {
    try {
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        if (firebaseUser.uid == userId) {
          FirebaseFirestore firestore = FirebaseFirestore.instance;
          CollectionReference groups = firestore.collection('groups');
          String groupIds = groupId;
          await groups.doc(groupIds).update({
            'members': FieldValue.arrayUnion([userId]),
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added $userId to the group.'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid user ID'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No user is currently logged in.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding member: $e'),
        ),
      );
    }
  }

  void _showAddTaskDialog(BuildContext context) {
    TextEditingController taskNameController = TextEditingController();
    TextEditingController taskDescriptionController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: taskNameController,
                decoration: InputDecoration(hintText: 'Task Name'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: taskDescriptionController,
                decoration: InputDecoration(hintText: 'Task Description'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  ).then((value) {
                    if (value != null) {
                      showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      ).then((time) {
                        if (time != null) {
                          selectedDate = DateTime(
                            value.year,
                            value.month,
                            value.day,
                            time.hour,
                            time.minute,
                          );
                        }
                      });
                    }
                  });
                },
                child: Text('Select Date and Time'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (taskNameController.text.isNotEmpty &&
                    taskDescriptionController.text.isNotEmpty &&
                    selectedDate != null) {
                  var random = Random();
                  String task_id = '';
                  for (var i = 0; i < 6; i++) {
                    task_id += (random.nextInt(10)).toString();
                  }
                  try {
                    User? currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser != null) {
                      FirebaseFirestore firestore = FirebaseFirestore.instance;
                      CollectionReference tasks = firestore.collection('tasks');
                      await tasks.add({
                        'taskId': task_id,
                        'taskName': taskNameController.text,
                        'taskDescription': taskDescriptionController.text,
                        'selectedDate': selectedDate,
                        'groupId': groupId,
                        'createdAt': DateTime.now(),
                        'createdBy': currentUser.email,
                      });
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('No user is currently logged in.'),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                      ),
                    );
                  }
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _handleTaskTap(BuildContext context, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailsPage(data: data),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this group?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  User? firebaseUser = FirebaseAuth.instance.currentUser;
                  if (firebaseUser != null) {
                    String currentUserId = firebaseUser.uid;
                    FirebaseFirestore firestore = FirebaseFirestore.instance;
                    CollectionReference groups = firestore.collection('groups');
                    DocumentSnapshot groupDoc = await groups.doc(groupId).get();
                    Map<String, dynamic>? data =
                        groupDoc.data() as Map<String, dynamic>?;

                    if (data != null && data['createdBy'] == currentUserId) {
                      await groups.doc(groupId).delete();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Only the group creator can delete the group.'),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('No user is currently logged in.'),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                    ),
                  );
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
