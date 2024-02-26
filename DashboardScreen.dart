import 'package:flutter/material.dart';

import '../LoginScreen.dart';
import 'MyTaskScreen.dart';
import 'TaskReceived.dart';

class DashboardScreen extends StatefulWidget {
String email;

DashboardScreen(this.email);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        automaticallyImplyLeading: false, // Hides the back icon
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) =>  LoginScreen(),
                    settings: const RouteSettings(name: 'LoginScreen'),
                  ),
                      (Route<dynamic> route) => false,
                );
                // Add your logout logic here
              },
              child: Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 4),
                  Text('Logout'),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

           children: [

             GestureDetector(
               onTap: (){
                 Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => MyTask(widget.email)));
               },
               child: Container(
                 width: 200,

                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(5),
                   color: Colors.blue,
                 ),
                 child: Center(
                   child: Container(
                     margin: EdgeInsets.all(10),
                     child: Row(
                       children: [
                         Icon(Icons.task,color: Colors.white,),
                         SizedBox(width: 10.0),

                         Text(
                           "My Task",
                           style: TextStyle(fontSize: 20,color: Colors.white),
                         ),
                       ],
                     )
                   ),
                 ),
               ),
             ),
             SizedBox(height: 16.0),


             GestureDetector(
               onTap: (){
                 Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => TaskReceivedScreen(widget.email)));

               },
               child: Container(
                 width: 200,

                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(5),
                   color: Colors.blue,
                 ),
                 child: Center(
                   child: Container(
                     margin: EdgeInsets.all(10),
                     child: Row(
                       children: [
                         Icon(Icons.call_received,color: Colors.white,),
                         SizedBox(width: 10.0),

                         Text(
                           "Task Received",
                           style: TextStyle(fontSize: 20,color: Colors.white),
                         ),
                       ],
                     )
                   ),
                 ),
               ),
             ),
           ],


          ),
        ),
      ),
    );
  }
}
