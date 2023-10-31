// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/pages/login_page.dart';
import 'home_page.dart';

class RegistrationPage extends StatefulWidget {
  RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController =
      TextEditingController(); // Controller for confirming password
  final userIdController = TextEditingController(); // Controller for userID

  void registerUser() async {
    // Check if any of the fields is empty
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmController.text.isEmpty ||
        userIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
        ),
      );
    } else {
      // Ensure password matches confirmation
      if (passwordController.text == confirmController.text) {
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
          // Registration successful, navigate to home page
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    LoginPage()), // Replace 'HomePage' with your actual home page.
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {
            // Show a snackbar for a weak password
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('The password provided is too weak.'),
              ),
            );
          } else if (e.code == 'email-already-in-use') {
            // Show a snackbar for an email already in use
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('The account already exists for that email.'),
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An error occurred. Please try again later.'),
            ),
          );
        }
      } else {
        // Show a snackbar for password mismatch
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: userIdController, // Adding userID field
              decoration: InputDecoration(hintText: 'UserID'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(hintText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(hintText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: confirmController, // Adding confirm password field
              decoration: InputDecoration(hintText: 'Confirm Password'),
              obscureText: true,
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: registerUser,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
