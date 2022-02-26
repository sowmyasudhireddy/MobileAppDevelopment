import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mad_assignment_1/screens/homepage.dart';
import 'package:mad_assignment_1/screens/login.dart';
import 'package:mad_assignment_1/screens/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:Splash(), //LandingPage()
    );
  }
}
class LandingPage extends StatelessWidget{
  final Future<FirebaseApp> _initialization =Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FutureBuilder(future: _initialization,builder: (context,snapshot){
      if(snapshot.hasError){
        return Scaffold(
        body:Center(
          child:Text("Error: ${snapshot.error}"),
        )
      );
      }
      if(snapshot.connectionState==ConnectionState.done){
        return StreamBuilder(
        stream:FirebaseAuth.instance.authStateChanges(),
          builder:(context,snapshot){
          if(snapshot.connectionState==ConnectionState.active){
            Object? user=snapshot.data;
            if(user==null){return Login();}
            else{return Homepage();}
          }
          return Scaffold(
            body:Center(
              child:Text("Checking Authentication....."),
            ),
          );
          }

        );

      }
      return Scaffold(
          body:Center(
            child:Text("Connecting to the firebase....."),
          ),
      );
    }

  );

  }

}