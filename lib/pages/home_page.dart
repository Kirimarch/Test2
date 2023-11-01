// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables, avoid_print

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/pages/login_page.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

void signOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  // ทำการล้างค่าและนำผู้ใช้ออกจากระบบ
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
        builder: (context) =>
            LoginPage()), // ให้ LoginPage ตรงกับหน้าล็อคอินของคุณ
    (Route<dynamic> route) => false,
  );
}

class Home extends StatelessWidget {
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[],
        ),
      ),
    );
  }
}

void _showCreateGroupDialog(BuildContext context) {
  List<String> subjects = [
    'Math',
    'Science',
    'History',
    'English',
    'Art',
    'Programing',
  ]; // Replace this list with your subjects

  String selectedSubject = subjects[0];
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
                groupName = value; // อัปเดตค่า groupName เมื่อมีการเปลี่ยนแปลง
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
                    selectedSubject = newValue!;
                  },
                  items: subjects.map<DropdownMenuItem<String>>((String value) {
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
                description =
                    value; // อัปเดตค่า description เมื่อมีการเปลี่ยนแปลง
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
              addDataToFirestore(groupName, selectedSubject,
                  description); // Replace 'user123' with the actual user ID
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

    // สร้าง Group ID แบบสุ่ม
    var random = Random();
    String groupId = '';
    for (var i = 0; i < 6; i++) {
      groupId += (random.nextInt(10)).toString();
    }

    // เพิ่มข้อมูลลงใน Firestore
    try {
      await _firestore.collection('groups').doc(groupId).set({
        'groupId': groupId,
        'groupName': groupName,
        'selectedSubject': selectedSubject,
        'description': description,
        'createdBy': userId,
        'createdAt': FieldValue.serverTimestamp(), // วันที่และเวลาที่สร้าง
        'members': [], // สมาชิกในกลุ่มที่จะเพิ่มเข้ามาทีหลัง
      });
    } catch (e) {
      print('เกิดข้อผิดพลาดในการเพิ่มข้อมูล: $e');
    }
  }
}
