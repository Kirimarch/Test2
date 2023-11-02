// ignore_for_file: file_names, use_key_in_widget_constructors, prefer_const_constructors, prefer_const_constructors_in_immutables, unused_element, use_build_context_synchronously, prefer_const_literals_to_create_immutables
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TaskDetailsPage extends StatelessWidget {
  final Map<String, dynamic> data;
  TaskDetailsPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Details for ${data['taskName']}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          _buildActions(context, data),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Name: ${data['taskName']}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            Expanded(
              child: Text(
                'Task Description: ${data['taskDescription']}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                _handleComment(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.comment),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _confirmDelete(context, data);
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.remove_red_eye),
                  onPressed: () {
                    _showComments(context, data);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, Map<String, dynamic> data) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.email == data['createdBy']) {
      return IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          _handleEditTask(context, data);
        },
      );
    } else {
      return SizedBox.shrink();
    }
  }

  void _handleEditTask(BuildContext context, Map<String, dynamic> data) async {
    TextEditingController taskNameController =
        TextEditingController(text: data['taskName']);
    TextEditingController taskDescriptionController =
        TextEditingController(text: data['taskDescription']);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Task'),
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
                try {
                  FirebaseFirestore firestore = FirebaseFirestore.instance;
                  CollectionReference tasks = firestore.collection('tasks');
                  QuerySnapshot snapshot = await tasks
                      .where('taskName', isEqualTo: data['taskName'])
                      .get();
                  if (snapshot.docs.isNotEmpty) {
                    DocumentSnapshot doc = snapshot.docs.first;
                    await tasks.doc(doc.id).update({
                      'taskName': taskNameController.text,
                      'taskDescription': taskDescriptionController.text,
                    });
                  }
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                    ),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _handleComment(BuildContext context) {
    TextEditingController commentController = TextEditingController();
    User? currentUser =
        FirebaseAuth.instance.currentUser; // เพิ่มตัวแปร currentUser

    int rating = 0; // คะแนนที่เลือกโดยผู้ใช้

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Comment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Am in: ${currentUser?.email}', // แสดงอีเมลผู้ใช้ปัจจุบัน
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: commentController,
                decoration: InputDecoration(hintText: 'Write a comment'),
              ),
              SizedBox(height: 10),
              Row(
                children: List.generate(6, (index) {
                  if (index == 0) {
                    return Text('Rate: ');
                  }
                  return IconButton(
                    onPressed: () {
                      rating = index;
                    },
                    icon: Icon(
                      Icons.star,
                      color: rating >= index ? Colors.amber : Colors.grey,
                    ),
                  );
                }),
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
                try {
                  FirebaseFirestore firestore = FirebaseFirestore.instance;
                  CollectionReference comments =
                      firestore.collection('comments');
                  await comments.add({
                    'taskId': data['taskId'],
                    'comment': commentController.text,
                    'user': currentUser?.email,
                    'rating': rating,
                    'createdAt': DateTime.now(),
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                    ),
                  );
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this task?'),
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
                  if (firebaseUser != null &&
                      firebaseUser.email == data['createdBy']) {
                    FirebaseFirestore firestore = FirebaseFirestore.instance;
                    CollectionReference tasks = firestore.collection('tasks');
                    QuerySnapshot snapshot = await tasks
                        .where('taskName', isEqualTo: data['taskName'])
                        .get();
                    if (snapshot.docs.isNotEmpty) {
                      DocumentSnapshot doc = snapshot.docs.first;
                      await tasks.doc(doc.id).delete();
                    }
                    Navigator.of(context).pop();
                    Navigator.popUntil(
                        context, ModalRoute.withName('/GroupPage.dart'));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Only the creator of the task can delete it.'),
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

  void _showComments(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Comments for ${data['taskName']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('comments')
                      .where('taskId', isEqualTo: data['taskId'])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    if (snapshot.hasData && snapshot.data != null) {
                      List<Widget> commentWidgets =
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> commentData =
                            document.data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(commentData['comment']),
                          subtitle: Text(
                              'User: ${commentData['user']}, Rate: ${commentData['rating']}'),
                        );
                      }).toList();

                      return ListView(
                        children: commentWidgets,
                      );
                    }

                    return SizedBox();
                  },
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
