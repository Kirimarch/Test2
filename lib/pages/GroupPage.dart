// ignore_for_file: file_names, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors, library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
            icon: Icon(Icons.description),
            onPressed: () {},
          ),
          SizedBox(width: 20),
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _showAddMemberDialog(context);
              }),
          SizedBox(width: 20),
          IconButton(
            icon: Icon(Icons.add_task),
            onPressed: () {},
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

  Future _showAddMemberDialog(BuildContext context) async {
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
                String groupId = await _fetchGroupIdFromFirestore();
                Clipboard.setData(ClipboardData(text: groupId));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copied the code to the clipboard.'),
                  ),
                );
                Navigator.of(context).pop();
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
          String groupId = groupName;

          await groups.doc(groupId).update({
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

  Future<String> _fetchGroupIdFromFirestore() async {
    // Replace 'collectionName' with the actual name of your collection in Firestore
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('collectionName')
        .doc('documentId')
        .get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      String groupId = data['groupid'];
      return groupId;
    } else {
      throw Exception('Document does not exist in the database.');
    }
  }
}
