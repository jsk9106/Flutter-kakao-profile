import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kakao_profile_img_app/controller/profile_controller.dart';
import 'package:flutter_kakao_profile_img_app/screens/login_screen.dart';
import 'package:flutter_kakao_profile_img_app/screens/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        ProfileController.to.authStateChanges(snapshot.data);
        if(!snapshot.hasData){
          return LoginScreen();
        } else{
          return ProfileScreen();
        }
      },
    );
  }
}
