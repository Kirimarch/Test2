// ignore_for_file: file_names, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_const_constructors, avoid_print, unused_field, no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class AddMembersPage extends StatefulWidget {
  final String groupId;

  AddMembersPage({required this.groupId});

  @override
  _AddMembersPageState createState() => _AddMembersPageState();
}

class _AddMembersPageState extends State<AddMembersPage> {
  late User? user;
  List<String> selectedUsers = [];
  final TextEditingController _userIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _userIdController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Members'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              addMembersToGroup(_userIdController.text);
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _userIdController,
              decoration: InputDecoration(
                labelText: 'User ID',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Current User ID: ${user!.uid}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  void addMembersToGroup(String userId) {
    if (userId.isNotEmpty) {
      selectedUsers.add(userId);
    }
    try {
      _firestore.collection('groups').doc(widget.groupId).update({
        'members': FieldValue.arrayUnion(selectedUsers),
      });
      print('Members added successfully');
    } catch (e) {
      print('Error adding members: $e');
    }
  }
}
