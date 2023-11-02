import 'package:flutter/material.dart';

class MyTextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final void Function()? onPressed;
  const MyTextBox({super.key, required this.text, required this.sectionName, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(66, 65, 73, 44),
        borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.only(
        left: 15,
        bottom: 15,
      ),
      margin: const EdgeInsets.only(left: 20,right: 20,top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //sectionName
              Text(sectionName,
              style: const TextStyle(color: Color.fromARGB(194, 88, 25, 215)),
              ),

              //edit button
              IconButton(onPressed: onPressed,
               icon: const Icon(Icons.settings, color: Color.fromARGB(72, 92, 9, 236),),
               ),
            ],
          ),

          //text
          Text(text),
        ],
      ),
    );
  }
}