// ignore_for_file: prefer_final_fields, prefer_const_constructors, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_literals_to_create_immutables, use_build_context_synchronously, duplicate_ignore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/components/Text_box.dart';
import 'package:modernlogintute/components/chat_bubble.dart';
import 'package:modernlogintute/components/chat_service.dart';
import 'package:modernlogintute/components/my_textfield.dart';
import 'package:modernlogintute/pages/home_page.dart';
import 'package:modernlogintute/pages/login_page.dart';

class Myrealhomepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'แอพพลิเคชันของฉัน',
      theme: ThemeData(
        primarySwatch: Colors.orange, // ตั้งค่าสีหลักเป็นสีส้ม
      ),
      home: MyHomePage(title: 'หน้าหลักแอพพลิเคชัน'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    Home(),
    ChatPage(receiverUserEmail: 'message', receiverUserID: 'message',),
    Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void signOut() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor:
            Colors.orange, // ตั้งค่าสีของไอเทมที่เลือกในแถบข้างล่าง
        onTap: _onItemTapped,
      ),
    );
  }
}
class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  const ChatPage({
    super.key,
    required this.receiverUserEmail,
    required this.receiverUserID,
  });

  @override
  State<ChatPage> createState() => _ChatState();
}

class _ChatState extends State<ChatPage>{

final TextEditingController _messageController = TextEditingController();
final ChatService _chatService = ChatService();
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

void sendMessage() async {
  //only send message if something send
  if(_messageController.text.isNotEmpty) {
    await _chatService.sendMessage(
      widget.receiverUserID, _messageController.text);
      //clear the text controller
    _messageController.clear();

  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverUserEmail)),
      body: Column(
        children: [
          //message
          Expanded(
            child: _buildMessageList(),
            ),

            //user input
            _buildMessageInput(),

            const SizedBox(height: 25,),
        ]),
    );
  }
  //buid message list
  Widget _buildMessageList() {
    return StreamBuilder(stream: _chatService.getMessages(
      widget.receiverUserID, _firebaseAuth.currentUser!.uid),
     builder: (context, snapshot) {
       if(snapshot.hasError) {
        return Text('Error${snapshot.error}');
       }
       if (snapshot.connectionState == ConnectionState.waiting) {
        return const Text('Loading...');
       }

       return ListView(
        children : 
        snapshot.data!.docs.map((document) =>
         _buildMessageItem(document)).toList(),
       );
      }
     );
  }

   //buid message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    //align the message
    var aligment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
    ? Alignment.centerRight 
    : Alignment.centerLeft;

    return Container(
      alignment: aligment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid)
          ? CrossAxisAlignment.end 
          : CrossAxisAlignment.start,
        mainAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? MainAxisAlignment.end 
        : MainAxisAlignment.start,
          children: [
            Text(data['senderEmail']),
            const SizedBox(height: 5),
            ChatBubble(message : data['message']),
          ],
        ),
      ),
    );
  }
   //buid message input
  Widget _buildMessageInput(){
    return Row(
      children: [
        //textfield
        Expanded(child: MyTextField(
          controller: _messageController,
          hintText: "Enter message",
          obscureText: false,
        ),
        ),


        //send button
        IconButton(onPressed: sendMessage, 
        icon: const Icon(
          Icons.arrow_upward, size: 20,
          ),
        ),
      ],
    );
  }
}

class Profile extends StatefulWidget {
  Profile({Key? key,}) : super(key: key);
  
  @override
  State<Profile> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<Profile>{

//user
final currentUser = FirebaseAuth.instance.currentUser!;
//all user
final userCollection = FirebaseFirestore.instance.collection("Users");
//edit field
Future<void> editField(String field) async {
  String newValue = "";
  await showDialog(context: context,
   builder: (context) => AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text("Edit $field",
       style: TextStyle(color: Colors.white),
       ),
       content: TextField(
        autofocus: true,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Enter new $field",
          hintStyle: TextStyle(color: Colors.grey),
        ),
        onChanged: (value){
          newValue = value;
        },


       ),
       actions: [
        //cacel
        TextButton(onPressed: ()=> Navigator.of(context).pop(newValue), 
        child: Text('Save',style: TextStyle(color: Colors.white),
        ),
        ),
       ],
   ),
   );
   //update in firestore
   if (newValue.trim().length > 0){
      await userCollection.doc(currentUser.email).set({field: newValue}, SetOptions(merge: true));
   }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ProfilePage"),
        backgroundColor: Colors.grey,
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection("Users").doc(currentUser.email).snapshots(),
          builder: (context, snapshot) {

            if (snapshot.hasData) {
              final userData = snapshot.data?.data() as Map<String, dynamic>?;
            if (userData != null) {
             // Now, you can safely work with userData
            } else {
             // Handle the case where snapshot.data is null or the cast to Map<String, dynamic> failed
            }
            
              return ListView(
          children: [
            const SizedBox(height: 50),
            //profile pic
            Icon(
              Icons.person,
              size: 72,
            ),

            //user email
            Text(
              currentUser.email!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            //user details
            Padding(padding: const EdgeInsets.only(left: 25.0),
              child: Text(
                'My Details',
              style: TextStyle(color: Colors.grey),
              ),
            ),
            //username
            MyTextBox(
            text: userData?['username'] ?? 'Default Username',
            sectionName: 'Username',
            onPressed: () => editField('username'),
            ),
            //bio
              MyTextBox(
            text: userData?['bio'] ?? 'Default bio',
            sectionName: 'Favorite subject',
            onPressed: () => editField('bio'),
            ),

            const SizedBox(height: 50),
            
            //user posts
            Padding(padding: const EdgeInsets.only(left: 25.0),
              child: Text(
                'My Posts',
              style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error${snapshot.error}'),
              );
            }


            return const Center(child: CircularProgressIndicator(),
            );
          },
          ) ,
    );
  }
}
