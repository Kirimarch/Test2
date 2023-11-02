import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/models/message.dart';

class ChatService extends ChangeNotifier{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receiverId, String message) async {
    //get current user
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();
    //create new message
      Message newMessage = Message(
      senderId: currentUserId,
      senderEmail:  currentUserEmail,
      receiverId: receiverId,
      timestamp: timestamp,
      message: message,
    );

    //construct chat room id
    List<String> ids = [currentUserId, receiverId];
    ids.sort(); //sort the ids
    String chatRoomId = ids.join(
      "_"
    );
    //add new message
    await _firestore
      .collection('chat_rooms')
      .doc(chatRoomId)
      .collection('message')
      .add(newMessage.toMap());
  }


  //GET message
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
      .collection('chat_rooms')
      .doc(chatRoomId)
      .collection('message')
      .orderBy('timestamp',descending: false).snapshots();
  }
}