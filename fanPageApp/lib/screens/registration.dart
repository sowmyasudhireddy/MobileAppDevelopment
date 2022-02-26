import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mad_assignment_1/screens/homepage.dart';

import 'login.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController fnameController = TextEditingController();
  TextEditingController lnameController = TextEditingController();
  TextEditingController passwordController1 = TextEditingController();
  TextEditingController passwordController2 = TextEditingController();
  TextEditingController emailcontroller=TextEditingController();
  Future<void>addUser(){
    CollectionReference users= FirebaseFirestore.instance.collection("Users");
    String id=FirebaseAuth.instance.currentUser.uid;
    print("id:"+ id);
    var now = new DateTime.now();
    String date_formatter = DateFormat('yyyy-MM-dd').format(now);
    String time_formatter=DateFormat.Hms().format(now);

    return users.doc(id).set({
      "First name":fnameController.text.trim(),
      "Last name":lnameController.text.trim(),
      "Email":emailcontroller.text.trim(),
      "User Id":id,
      "User Type":"User",
      "Date" : date_formatter,
      "Time": time_formatter

    }).then((value) =>ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("User added"),
    ))).catchError((error) => print("Failed to add user: $error"));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Registration'),
          backgroundColor: Colors.red,
        ),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'MyFlutterApp',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                          fontSize: 30),
                    )),
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Sign up',
                      style: TextStyle(fontSize: 20),
                    )),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: fnameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'First Name',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: lnameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Last Name',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: emailcontroller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController1,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController2,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Re enter Password',
                    ),
                  ),
                ),
                Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: RaisedButton(
                      textColor: Colors.white,
                      color: Colors.red,
                      child: Text('Register'),
                      onPressed: ()async {
                        if (EmailValidator.validate(emailcontroller.text.trim()) && passwordController1.text==passwordController2.text) {
                          try {
                            UserCredential userCredential = await FirebaseAuth
                                .instance.createUserWithEmailAndPassword(
                                email: emailcontroller.text.trim(),
                                password: passwordController2.text
                            ).whenComplete(() => addUser()
                            ).whenComplete(() => Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>Homepage())));

                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'weak-password') {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Password is too weak"),
                              ));
                            } else if (e.code == 'email-already-in-use') {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Email already in use"),
                              ));
                            }
                          }
                        }
                        else{
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Invalid Email"),
                          ));
                        }
                      }
                      )),
                Container(
                    child: Row(
                      children: <Widget>[
                        Text('Already have account?'),
                        FlatButton(
                          textColor: Colors.red,
                          child: Text(
                            'Login',
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () {
                           Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>Login()));
                          },
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ))
              ],
            )));
  }
}
