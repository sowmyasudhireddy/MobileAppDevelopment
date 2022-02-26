import 'package:flutter/material.dart';

import '../main.dart';
    class Splash extends StatefulWidget {
      const Splash({Key? key}) : super(key: key);


      @override
      _SplashState createState() => _SplashState();
    }
    class _SplashState extends State<Splash>{
      @override
      void initState(){
        super.initState();
        _navigateHome();
        }
        _navigateHome() async{
        await Future.delayed(Duration(milliseconds: 2500),(){});
        Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=>LandingPage()));

        }
      @override
      Widget build(BuildContext context) {
        return Scaffold(
        body: Center(
        child: ListView (
            children:<Widget>[
              Container(
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.all(10),
                child:Image.asset("assets/splash.jpg",fit: BoxFit.fill)
              ),
              Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10),
                child:LinearProgressIndicator(
                  backgroundColor: Colors.red,
                  minHeight: 08,
                )
              )
            ]

        )
        )
        );
      }
    }
