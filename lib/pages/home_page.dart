// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/pages/login_page.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

void signOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
    (Route<dynamic> route) => false,
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late User? user;
  late List<dynamic> groups;
  String selectedSubject = 'Math';
  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    groups = [];
    if (user != null) {
      fetchGroups();
    }
  }

  void fetchGroups() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('groups')
        .where('createdBy', isEqualTo: user!.uid)
        .get();
    setState(() {
      groups = querySnapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        leading: IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: () {
            signOut(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showCreateGroupDialog(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (BuildContext context, int index) {
          var group = groups[index];
          return ListTile(
            title: Text(group['groupName']),
            subtitle: Text(group['selectedSubject']),
            onTap: () {
              // รหัสดำเนินการเมื่อกดที่รายการ
            },
          );
        },
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    List<String> subjects = [
      'Math',
      'Science',
      'History',
      'English',
      'Art',
      'Programing',
    ];

    String groupName = '';
    String description = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Group'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  setState(() {
                    groupName = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Group Name',
                  hintText: 'Enter the name of your group',
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('Subject: '),
                  SizedBox(width: 10),
                  DropdownButton<String>(
                    value: selectedSubject,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSubject = newValue!;
                      });
                    },
                    items:
                        subjects.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter a brief description of your group',
                ),
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
            ElevatedButton(
              onPressed: () {
                addDataToFirestore(groupName, selectedSubject, description);
                Navigator.of(context).pop();
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void addDataToFirestore(
      String groupName, String selectedSubject, String description) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      var random = Random();
      String groupId = '';
      for (var i = 0; i < 6; i++) {
        groupId += (random.nextInt(10)).toString();
      }

      try {
        await _firestore.collection('groups').doc(groupId).set({
          'groupId': groupId,
          'groupName': groupName,
          'selectedSubject': selectedSubject,
          'description': description,
          'createdBy': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'members': [],
        });
      } catch (e) {
        print('Error adding data: $e');
      }
    }
  }
}
