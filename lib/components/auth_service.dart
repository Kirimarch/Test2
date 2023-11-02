import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> signInWithEmailAndPassword(
    String email, String password) async {
    try{
      //sign in
      UserCredential userCredential =
        await _firebaseAuth.signInWithEmailAndPassword(
          email: email, 
          password: password,
          );

        _firestore.collection('users').doc(userCredential.user!.uid).set({
          'userId': userCredential.user!.uid,
          'email': email,
        }, SetOptions(merge: true));

        return userCredential;
    }
    on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
    }

    //create new user
    //sign out
    Future<void> signOut() async {
      return await FirebaseAuth.instance.signOut();  }
}

