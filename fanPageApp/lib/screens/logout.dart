import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login.dart';

class Logout extends StatefulWidget {
  const Logout({Key? key}) : super(key: key);

  @override
  _LogoutState createState() => _LogoutState();
}

class _LogoutState extends State<Logout> {
  Future<void> _displayTextInputDialog(BuildContext context){
    return showDialog(
        context: context,
        builder: (context)
    {
      return AlertDialog(
          title: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            FlatButton(
              color: Colors.red,
              textColor: Colors.white,
              child: Text('CANCEL'),
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
            ),
            FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () {
                  _signOut();
                  Navigator.pop(context);
                }
            )
          ]
      );
  }
    );
  }
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Center(
        child:RaisedButton(
        textColor: Colors.white,
        color: Colors.red,
        child: Text('Logout'),
    onPressed: (){_displayTextInputDialog(context);}
        )));
  }
}
