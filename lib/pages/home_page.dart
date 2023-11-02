// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, prefer_const_constructors_in_immutables
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/pages/GroupPage.dart';
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
  late BuildContext scaffoldContext;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    groups = [];
    if (user != null) {
      fetchGroups();
    }
  }

  @override
  Widget build(BuildContext context) {
    scaffoldContext = context;
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
            icon: Icon(Icons.add_home),
            onPressed: () {
              _showCreateGroupDialog(context);
            },
          ),
          SizedBox(width: 20),
          IconButton(
            icon: Icon(Icons.join_full),
            onPressed: () {
              _showJoinRoomDialog(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (BuildContext context, int index) {
          var group = groups[index];
          Color randomColor =
              Colors.primaries[Random().nextInt(Colors.primaries.length)];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupPage(
                        groupName: group['groupName'],
                        groupId: group['groupId']),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: randomColor,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    group['groupName'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          group['selectedSubject'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Members: ${group['members'].length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void fetchGroups() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('groups')
        .where('members', arrayContains: user!.uid)
        .get();
    List<Map<String, dynamic>> fetchedGroups = querySnapshot.docs
        .map((e) => e.data() as Map<String, dynamic>)
        .toList();
    List<Map<String, dynamic>> updatedGroups = [];

    for (var group in fetchedGroups) {
      List<dynamic> members = await fetchGroupMembers(group['groupId']);
      group['members'] = members;
      updatedGroups.add(group);
    }

    setState(() {
      groups = updatedGroups;
    });
  }

  Future<List<dynamic>> fetchGroupMembers(String groupId) async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection('groups').doc(groupId).get();
    if (documentSnapshot.exists) {
      Map<String, dynamic>? data =
          documentSnapshot.data() as Map<String, dynamic>?;
      if (data != null && data['members'] != null) {
        return List.from(data['members']);
      } else {
        return [];
      }
    } else {
      return [];
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
    ];

    String groupName = '';
    String description = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Room'),
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
                  labelText: 'Room Name',
                  hintText: 'Enter the name of your Room',
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
                  hintText: 'Enter a brief description of your Room',
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
          'members': [userId],
        });
      } catch (e) {
        print('Error adding data: $e');
      }
    }
  }

  void _showJoinRoomDialog(BuildContext context) async {
    String groupId = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Join Room'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  setState(() {
                    groupId = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Room ID',
                  hintText: 'Enter the ID of the Room you want to join',
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
              onPressed: () async {
                bool isRoomAvailable = await checkRoomAvailability(groupId);
                if (isRoomAvailable) {
                  await addMemberToGroup(groupId);
                  Navigator.of(context).pop();
                  fetchGroups();
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Room does not exist.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Join'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> checkRoomAvailability(String groupId) async {
    DocumentSnapshot snapshot =
        await _firestore.collection('groups').doc(groupId).get();
    return snapshot.exists;
  }

  Future<void> addMemberToGroup(String groupId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      List<dynamic> groupMembers = await fetchGroupMembers(groupId);
      if (!groupMembers.contains(userId)) {
        try {
          await _firestore.collection('groups').doc(groupId).update({
            'members': FieldValue.arrayUnion([userId]),
          });
        } catch (e) {
          print('Error adding member: $e');
        }
      } else {
        showDialog(
          context: scaffoldContext,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('User is already a member of this group.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }
}
