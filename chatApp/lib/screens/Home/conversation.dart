import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/screens/Home/Profile.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/shared/constants.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:image_cropper/image_cropper.dart';
// import 'package:flutter_emoji_keyboard/flutter_emoji_keyboard.dart';

class ConversationScreen extends StatefulWidget {
  final String chatRoomID;
  String userName;
  String Profpic;
  ConversationScreen(this.chatRoomID, this.userName, this.Profpic);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  TextEditingController chatController = new TextEditingController();
  DatabaseServices databaseService = new DatabaseServices();

  File _image;
  final picker = ImagePicker();
  Future getImage() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 20);

    _cropImage(pickedFile).then((_) => {uploadPic()});
  }

  Future<Null> _cropImage(pickedFile) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    setState(() {
      try {
        _image = File(croppedFile.path);
      } catch (e) {
        print(e.toString());
      }
    });
  }

  String imgurl = "";

  Future uploadPic() async {
    String fileName = basename(_image.path);
    var firebasestorageRef =
        FirebaseStorage.instance.ref().child('${widget.chatRoomID}/"$fileName');
    var uploadTask = firebasestorageRef.putFile(_image);
    var taskSnapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    sendimage(downloadUrl, widget.userName);
    // print("after upload $imgurl");
  }

  Stream messagesStream;

  Widget chatList() {
    return Expanded(
      child: StreamBuilder(
          stream: messagesStream,
          builder: (context, snapshot) {
            return snapshot.hasData
                ? ListView.builder(
                    reverse: true,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      if (snapshot.data.docs[index]['sendBy'] !=
                              Constants.MyName &&
                          snapshot.data.docs[index]['seenby'] == false) {
                        databaseService.updateseenInfoOfText(widget.chatRoomID,
                            snapshot.data.docs[index]['time'].toString());
                      }
                      return messageTile(
                          snapshot.data.docs[index]['message'],
                          snapshot.data.docs[index]['sendBy'] ==
                              Constants.MyName,
                          snapshot.data.docs[index]['hour'],
                          snapshot.data.docs[index]['minute'],
                          snapshot.data.docs[index]['imageurl'],
                          snapshot.data.docs[index]['sendBy'] ==
                                  Constants.MyName
                              ? snapshot.data.docs[index]['seenby']
                              : false,
                          widget.chatRoomID,
                          // "",
                          index != snapshot.data.docs.length - 1
                              ? (DateTime.fromMicrosecondsSinceEpoch(snapshot.data.docs[index]['time'] * 1000)
                                          .day !=
                                      DateTime.fromMicrosecondsSinceEpoch(
                                              snapshot.data.docs[index + 1]
                                                      ['time'] *
                                                  1000)
                                          .day
                                  ? DateTime.fromMicrosecondsSinceEpoch(
                                      snapshot.data.docs[index]['time'] * 1000)
                                  : null)
                              : DateTime.fromMicrosecondsSinceEpoch(
                                  snapshot.data.docs[index]['time'] * 1000));
                    })
                : Container();
          }),
    );
  }

  sendMessage(String message, String userName) {
    if (message.isNotEmpty) {
      var tim = DateTime.now().millisecondsSinceEpoch;
      Map<String, dynamic> chatMap = {
        "message": message,
        "sendBy": Constants.MyName,
        "time": tim,
        "hour": DateTime.now().hour,
        "minute": DateTime.now().minute,
        "imageurl": "",
        "seenby": false,
      };
      databaseService.sendMessagetoFirestore(
          widget.chatRoomID, chatMap, tim.toString());
      chatController.text = "";
      databaseService.updateLastMessage(widget.chatRoomID, message);
      databaseService.updateSeenInfoWhenMessSent(
          widget.chatRoomID,
          widget.chatRoomID
              .replaceAll('_', '')
              .replaceAll(Constants.MyName, ''));
    }
  }

  sendimage(String url, String userName) {
    if (url != "") {
      var tim = DateTime.now().millisecondsSinceEpoch;

      Map<String, dynamic> chatMap = {
        "message": "",
        "sendBy": Constants.MyName,
        "time": tim,
        "hour": DateTime.now().hour,
        "minute": DateTime.now().minute,
        "imageurl": url,
        "seenby": false,
      };
      databaseService.sendMessagetoFirestore(
          widget.chatRoomID, chatMap, tim.toString());
      databaseService.updateLastMessage(widget.chatRoomID, null);
    }
  }

  @override
  void initState() {
    dynamic value = databaseService.getMessagesFromFirestore(widget.chatRoomID);
    setState(() {
      messagesStream = value;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 20,
        title: Row(
          children: <Widget>[
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage("assets/profPic.jpg"),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Profile(widget.userName, widget.Profpic)));
                  },
                  child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.transparent,
                      backgroundImage:
                          (widget.Profpic == "" || widget.Profpic == null)
                              ? AssetImage("assets/profPic.jpg")
                              : NetworkImage(widget.Profpic)),
                ),
              ],
            ),
            SizedBox(
              width: 15,
            ),
            Text(
              widget.userName,
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
      body: Container(
        // color: Colors.black87,
        child: Column(
          children: [
            Container(child: chatList()),
            Container(
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey))),
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(7),
                child: Row(
                  children: <Widget>[
                   
                    Expanded(
                      child: TextField(
                        style: TextStyle(fontSize: 17),
                        controller: chatController,
                        decoration: InputDecoration(
                            alignLabelWithHint: true,
                            hintText: 'Type message....',
                            fillColor: Colors.white,
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: Colors.green[900], width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 2),
                            )),
                      ),
                    ),
                    GestureDetector(
                        onTap: () {
                          sendMessage(chatController.text, widget.userName);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 5),
                          child: Container(
                            // decoration: BoxDecoration(
                            //     borderRadius: BorderRadius.circular(40),
                            //     color: Colors.green[900]),
                            // padding: EdgeInsets.symmetric(horizontal: 5),
                            // height: 40,
                            // width: 40,
                            child: Icon(
                              Icons.send,
                              size: 30,
                              color: Colors.green[900],
                            ),
                          ),
                        ))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class messageTile extends StatefulWidget {
  final String message;
  final int hour;
  final int minute;
  final bool isitsentbyme;
  final String imageurl;
  final bool seen;
  final String chatRoomID;
  final DateTime date;
  messageTile(this.message, this.isitsentbyme, this.hour, this.minute,
      this.imageurl, this.seen, this.chatRoomID, this.date);

  @override
  _messageTileState createState() => _messageTileState();
}

class _messageTileState extends State<messageTile> {
  @override
  void initState() {
    DatabaseServices databaseService = new DatabaseServices();

    databaseService.updateSeenInfoWhenMessReceived(widget.chatRoomID);

    super.initState();
  }

  Widget build(BuildContext context) {
    // print("tile $imageurl");
    var week = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Son'];
    var month = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'June',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return Column(
      children: [
       
        Container(
          padding: EdgeInsets.all(8),
          width: MediaQuery.of(context).size.width,
          alignment: widget.isitsentbyme
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Column(
            children: <Widget>[
              Container(
                // width: MediaQuery.of(context).size.width,
                constraints: BoxConstraints(minWidth: 50, maxWidth: 250),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                    color: widget.isitsentbyme
                        ? Colors.green[900]
                        : Colors.grey[500],
                    borderRadius: widget.isitsentbyme
                        ? BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                            bottomLeft: Radius.circular(30),
                          )
                        : BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          )),
                child: Column(
                  crossAxisAlignment: widget.isitsentbyme
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: <Widget>[
                    (widget.message == "" && widget.imageurl != "")
                        ? Container(
                            decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(12)),
                            height: 250,
                            width: 190,
                            child: Stack(
                              children: [
                                Center(
                                  child: Container(
                                    child: CircularProgressIndicator(
                                      // backgroundColor: Colors.black,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    widget.imageurl,
                                    height: 250,
                                    width: 190,
                                    fit: BoxFit.cover,
                                    // width: 50,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(left: 3.0),
                            child: Text(
                              widget.message,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                    
                    
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
