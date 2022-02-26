import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mad_assignment_1/screens/chats.dart';
import 'package:mad_assignment_1/screens/logout.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'feed.dart';
class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;
  String _user=FirebaseAuth.instance.currentUser.uid;
  var _storage=FirebaseFirestore.instance.collection("Users");
  firebase_storage.FirebaseStorage _cloud=firebase_storage.FirebaseStorage.instance;
  String _usertype="";
  String _fname="";
  String _lname="";
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Feed(),
    Chats(),
    Logout(),

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  void _get_data(){
    _storage.doc(_user.toString()).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        _fname= documentSnapshot.data()["First name"];
        _lname=documentSnapshot.data()["Last name"];
        _usertype=documentSnapshot.data()["User Type"];
      } else {
        //return ('Document does not exist on the database');
      }
    });
  }
  Future<void> _postAdder(String url )async{
    var now = new DateTime.now();
    String date_formatter = DateFormat('yyyy-MM-dd').format(now);
    String time_formatter=DateFormat.Hms().format(now);
    int likes=0;
    List <Map<String,String>>comments=[{"sample":"looks good!"}];
    DocumentReference ref= await FirebaseFirestore.instance.collection("posts").add(
        {
          "user": _fname + " " + _lname,
          "url": url,
          "time": time_formatter,
          "date": date_formatter,
          "likes": likes,
          "comments": comments,
          "userId": _user

        },
        );
    String id=ref.id;
    await FirebaseFirestore.instance.collection("posts").doc(id).update({"docId":id});

  }
  Future<void> _uploader(File file)async {
    try {
      var task=await firebase_storage.FirebaseStorage.instance
          .ref("/Images/"+_user+"/"+file.path.split("/").last)
          .putFile(file);
      String url = (await task.ref.getDownloadURL()).toString();
      if(url!=null){
        _postAdder(url);
      }

    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
      ));
    }

  }
  Future<void> _displayTextInputDialog(BuildContext context)async{
    TextEditingController textFieldController = TextEditingController();
    var now = new DateTime.now();
    String date_formatter = DateFormat('yyyy-MM-dd').format(now);
    String time_formatter=DateFormat.Hms().format(now);
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title:Text('Enter your message'),
            content: TextField(
              maxLines: 8,
              onChanged: (value) {
                setState(() {
                  //valueText = value;
                });
              },
              controller: textFieldController,
              decoration: InputDecoration(hintText: "Type your Message"),
            ),
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
                  setState((){

                    FirebaseFirestore.instance.collection("messages").add
                        (
                        {
                          "message": textFieldController.text,
                          "sender":_fname+" "+_lname,
                          "date":date_formatter,
                          "time":time_formatter
                        });
                    Navigator.pop(context);

                  });
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    _get_data();
    return Scaffold(
        appBar:AppBar(
            title:Text("Homepage"),
          backgroundColor: Colors.red,

        ),
        body:_widgetOptions[_selectedIndex],
        // body:Center(
        //     child:MaterialButton(
        //       onPressed: () {_signOut().whenComplete(() =>
        //           Navigator.pushReplacement(context,
        //               MaterialPageRoute(builder: (context)=>Login())));},
        //       child:Text("Signout")
        //     ),
        //
        // ),
        floatingActionButton: FloatingActionButton(
        onPressed: () async {

          if(_usertype=="Admin"){
            _displayTextInputDialog(context);
          }
          else{
            FilePickerResult? result = await FilePicker.platform.pickFiles();

            if(result != null) {
              File file = File(result.files.single.path);
              _uploader(file).whenComplete(() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("File upload completed"),
              )));


            } else {
              // User canceled the picker
            }
          }
      // Add your onPressed code here!
    },
    child: const Icon(Icons.add),
    backgroundColor: Colors.red,
    ),
    bottomNavigationBar: BottomNavigationBar(
    items: const <BottomNavigationBarItem>[
    BottomNavigationBarItem(
    icon: Icon(Icons.home),
    label: 'Home',
    ),
    BottomNavigationBarItem(
    icon: Icon(Icons.chat),
    label: 'Chats',
    ),
    BottomNavigationBarItem(
    icon: Icon(Icons.logout),
    label: 'Logout',
    ),
    ],
    currentIndex: _selectedIndex,
    selectedItemColor: Colors.red,
    onTap: _onItemTapped,
    )
    );
  }
}
