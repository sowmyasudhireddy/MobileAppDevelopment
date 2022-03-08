import 'package:flutter/material.dart';
import 'package:chatapp/services/auth.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/screens/Authenticate/helperfuncs.dart';

import 'package:chatapp/shared/constants.dart';
import 'package:chatapp/shared/loading.dart';

class signUp extends StatefulWidget {
  final Function toggleview;
  signUp({this.toggleview});
  @override
  _signUpState createState() => _signUpState();
}

class _signUpState extends State<signUp> {
  final AuthService _auth = AuthService();
  final _formkey = GlobalKey<FormState>();
  DatabaseServices databaseService = new DatabaseServices();
  String name = '';
  String email = '';
  String password = '';
  String error = '';
  bool loading = false;

  findCurUser(String email, String name) async {
    helperFunctions.saveUserEmailSharedPreference(email);
    helperFunctions.saveUserNameSharedPreference(name);
    helperFunctions.saveUserLoggedInSharedPreference(true);
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            body: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.only(top: 60, bottom: 50),
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Form(
                        key: _formkey,
                        child: Column(
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
                                    Icons.person,
                                    color: Colors.grey[600],
                                  ),
                                  alignLabelWithHint: true,
                                  hintText: 'name',
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
                                  val.isEmpty ? 'invalid name' : null,
                              onChanged: (val) {
                                setState(() => name = val);
                              },
                            ),
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
                                  hintText: 'email',
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
                                  hintText: 'password',
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
                              // shape: BeveledRectangleBorder (
                              // side: BorderSide(color: Colors.indigo, width: 1.5)),
                              color: Colors.green[900],

                              elevation: 4,
                              onPressed: () async {
                                if (_formkey.currentState.validate()) {
                                  setState(() => loading = true);
                                  dynamic res =
                                      await _auth.regwithEmail(email, password);
                                  Constants.MyName = name;
                                  findCurUser(email, name);
                                  if (res == null) {
                                    setState(() {
                                      error = 'please supply valid email';
                                      loading = false;
                                    });
                                  } else {
                                    Constants.MyName = name;
                                    await databaseService.uploadUserInfo(
                                        name, email);
                                  }
                                }
                              },
                              child: Text(
                                'Sign Up',
                                style: (TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600)),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              error,
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
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
                          'Log In',
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
