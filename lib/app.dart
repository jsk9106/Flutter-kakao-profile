import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kakao_profile_img_app/screens/home.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if(snapshot.hasError){
          return Center(child: Text("Firebase load Fail"));
        }
        if(snapshot.connectionState == ConnectionState.done){
          return HomeScreen();
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
