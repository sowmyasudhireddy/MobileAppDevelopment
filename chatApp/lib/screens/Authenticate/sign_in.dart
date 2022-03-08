import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/services/auth.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/shared/constants.dart';
import 'package:chatapp/shared/loading.dart';
import 'package:chatapp/screens/Authenticate/helperfuncs.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Sign_in extends StatefulWidget {
  final Function toggleview;
  Sign_in({this.toggleview});
  @override
  _Sign_inState createState() => _Sign_inState();
}

class _Sign_inState extends State<Sign_in> {
  final AuthService _auth = AuthService();
  final _formkey = GlobalKey<FormState>();
  DatabaseServices databaseService = new DatabaseServices();
  QuerySnapshot usersnapshot;

  String email = '';
  String password = '';
  String error = '';
  bool loading = false;

  findsignedCurUser(QuerySnapshot val) async {
    String curUser = val.docs[0].get('name');
    helperFunctions.saveUserEmailSharedPreference(email);
    helperFunctions.saveUserNameSharedPreference(curUser);
    helperFunctions.saveUserLoggedInSharedPreference(true);
    //  Constants.MyName=await helperFunctions.getUserNameSharedPreference();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.only(bottom: 50, top: 100),
                // color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      child: Form(
                        key: _formkey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                                padding: EdgeInsets.only(
                                  left: 20,
                                ),
                                child: Text(
                                  "Chat App",
                                  style: TextStyle(
                                      color: Colors.green[900],
                                      fontWeight: FontWeight.w900,
                                      fontSize: 50),
                                )),
                            SizedBox(height: 20),
                            TextFormField(
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                              decoration: InputDecoration(
                                  icon: Icon(
                                    Icons.email,
                                    color: Colors.grey[600],
                                  ),
                                  alignLabelWithHint: true,
                                  hintText: 'Email',
                                  hintStyle: TextStyle(
                                      color: Colors.black, fontSize: 18),
                                  fillColor: Colors.white,
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2),
                                  )),
                              validator: (val) =>
                                  val.isEmpty ? 'invalid email' : null,
                              onChanged: (val) {
                                setState(() => email = val);
                              },
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                              decoration: InputDecoration(
                                  icon: Icon(
                                    Icons.lock,
                                    color: Colors.grey[600],
                                  ),
                                  alignLabelWithHint: true,
                                  hintText: 'Password',
                                  hintStyle: TextStyle(
                                      color: Colors.black, fontSize: 18),
                                  fillColor: Colors.white,
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2),
                                  )),
                              validator: (val) => val.length < 6
                                  ? 'password should be 6+ long'
                                  : null,
                              obscureText: true,
                              onChanged: (val) {
                                setState(() => password = val);
                              },
                            ),
                            SizedBox(height: 20),
                            RaisedButton(
                              elevation: 4,
                              color: Colors.green[900],
                              onPressed: () async {
                                if (_formkey.currentState.validate()) {
                                  setState(() => loading = true);
                                  print('user');
                                  usersnapshot = await databaseService
                                      .searchUserbyEmail(email);
                                  setState(() {
                                    Constants.MyName =
                                        usersnapshot.docs[0].get('name');
                                  });
                                  dynamic res = await _auth.signwithEMail(
                                      email, password);

                                  if (res == null) {
                                    setState(() {
                                      error = 'COULD NOT SIGN IN';
                                      loading = false;
                                    });
                                  } else {
                                    Constants.MyProfPic =
                                        usersnapshot.docs[0].data()['profpic'];
                                    print(
                                        "user ${usersnapshot.docs[0].data()['name']}");
                                    Constants.MyName =
                                        usersnapshot.docs[0].data()['name'];
                                    findsignedCurUser(usersnapshot);
                                  }
                                }
                              },
                              child: Text(
                                'Sign in',
                                style: (TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600)),
                              ),
                            ),

                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              error,
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                            // SizedBox(height: 220,),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      child: RaisedButton.icon(
                        color: Colors.green[900],
                        onPressed: () {
                          widget.toggleview();
                        },
                        label: Text(
                          'Register',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        icon: Icon(
                          Icons.person,
                          color: Colors.white,
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
