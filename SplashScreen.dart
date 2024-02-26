import 'package:flutter/material.dart';

import 'LoginScreen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 2),(){
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) =>  LoginScreen(),
          settings: const RouteSettings(name: 'LoginScreen'),
        ),
            (Route<dynamic> route) => false,
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return const Scaffold(

      body: Center(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Text("WELCOME TO TODO LIST",textAlign: TextAlign.center,style: TextStyle(fontSize: 28,color: Colors.black,fontWeight: FontWeight.bold),),
          )),
    );
  }
}
