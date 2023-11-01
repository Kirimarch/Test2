// ignore_for_file: file_names, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors, library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:modernlogintute/pages/Addmember_page.dart';

class GroupPage extends StatelessWidget {
  final String groupName;

  GroupPage({required this.groupName});

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
          SizedBox(width: 20), // เพิ่มระยะห่าง
          IconButton(
            icon: Icon(Icons.description),
            onPressed: () {
              // รหัสดำเนินการเมื่อกดปุ่มเพิ่มสมาชิก
            },
          ),
          SizedBox(width: 20), // เพิ่มระยะห่าง
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddMembersPage(groupId: groupName),
                  ),
                );
              }),
          SizedBox(width: 20), // เพิ่มระยะห่าง
          IconButton(
            icon: Icon(Icons.add_task),
            onPressed: () {
              // รหัสดำเนินการเมื่อกดปุ่มการแจ้งเตือน
            },
          ),
        ],
        title: Center(
          child: Text(
            groupName,
            style: TextStyle(
              fontWeight: FontWeight.bold, // ตัวหนา
              fontSize: 20, // ขนาดตัวอักษร
              color: Colors.white, // สีข้อความ
            ),
          ),
        ),
      ),
    );
  }
}
