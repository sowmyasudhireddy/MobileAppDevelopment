import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/screens/Authenticate/helperfuncs.dart';
import 'package:chatapp/screens/Authenticate/sign_in.dart';
import 'package:chatapp/screens/Home/conversation.dart';
import 'package:chatapp/screens/Home/search.dart';
import 'package:chatapp/screens/Home/settings.dart';
import 'package:chatapp/services/auth.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/shared/constants.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  DatabaseServices databaseService = new DatabaseServices();
  Stream chatRoomStream;
  QuerySnapshot profpicsnapshot;
  bool loading = true;
  Widget chatRoomList() {
    return StreamBuilder(
      stream: chatRoomStream,
      builder: (context, snapshot) {
        return snapshot.data != null
            ?
            // print(snapshot.data.docs[0]['users']);
            snapshot.data.docs.length != 0
                ? ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      List usArray = snapshot.data.docs[index]['users'];
                      if (usArray.contains(Constants.MyName)) {
                        if (snapshot.data.docs[index]['lastMessage'] != "") {
                          String uname = snapshot.data.docs[index]['chatRoomID']
                              .toString()
                              .replaceAll('_', '')
                              .replaceAll(Constants.MyName, '');
                          return profpicsnapshot == null
                              ? Container()
                              : ChatRoomTile(
                                  uname,
                                  snapshot.data.docs[index]['chatRoomID'],
                                  profpicsnapshot,
                                  snapshot.data.docs[index]['hour'],
                                  snapshot.data.docs[index]['minute'],
                                  snapshot.data.docs[index]['lastmessBy'],
                                  snapshot.data.docs[index]['lastMessage'],
                                  snapshot.data.docs[index]
                                      ['seenby${Constants.MyName}'],
                                  snapshot.data.docs[index]['seenby$uname'],
                                );
                        }
                      }
                      return Container();
                    })
                : Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
            : Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
      },
    );
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async {
    if (Constants.MyName == '') {
      Constants.MyName = await helperFunctions.getUserNameSharedPreference();
    }
    databaseService.getChatRooms(Constants.MyName).then((value) {
      setState(() {
        chatRoomStream = value;
        loading = false;
      });
    });
    var imagesnapshot = await databaseService.getProfPic(Constants.MyName);
    Constants.MyProfPic = imagesnapshot.docs[0].get('profpic');
    databaseService.getAllProfPics().then((value) async {
      setState(() {
        profpicsnapshot = value;
      });
    });
  }

  Widget popUpMemu() {
    return PopupMenuButton<int>(
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Row(
            children: <Widget>[
              Icon(
                Icons.exit_to_app,
                color: Colors.black,
              ),
              Text('Logout')
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: <Widget>[
              Icon(
                Icons.person_outline,
                color: Colors.black,
              ),
              Text('Profile')
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 1) {
          _auth.signOut();
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Sign_in()));
        } else {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Settings1()));
        }
      },
      icon: Icon(
        Icons.list,
        size: MediaQuery.of(context).size.width * 0.08,
        color: Colors.blue[700],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // leadingWidth: 20,
        backgroundColor: Colors.green[900],
        elevation: 0,

        title: Text(
          'Chat App',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),

        centerTitle: false,
        actions: <Widget>[
          // dropMenu()
          Padding(
            padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.01),
            child: IconButton(
              color: Colors.white,
              // shape:
              // iconSize:
              icon: Icon(Icons.person_outline,
                  size: MediaQuery.of(context).size.width * 0.07,
                  color: Colors.white),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Settings1()));
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.01),
            child: IconButton(
                color: Colors.white,
                // shape:
                // iconSize:
                icon: Icon(Icons.search,
                    size: MediaQuery.of(context).size.width * 0.07,
                    color: Colors.white),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Search(),
                      ));
                }),
          ),
          Padding(
            padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.01),
            child: GestureDetector(
              child: Icon(
                Icons.logout_rounded,
                color: Colors.white,
                size: MediaQuery.of(context).size.width * 0.07,
              ),
              onTap: () => {_auth.signOut()},
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              color: Colors.white,
              child: Column(
                children: [
                  chatRoomList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatRoomTile extends StatelessWidget {
  final String userName;
  final String chatRoomID;
  QuerySnapshot url;
  final int hour;
  final int minute;
  final String sentby;
  final String lastmess;
  final bool seenbyme;
  final bool seenbyOther;
  // final Querysnapshot prof;
  ChatRoomTile(this.userName, this.chatRoomID, this.url, this.hour, this.minute,
      this.sentby, this.lastmess, this.seenbyme, this.seenbyOther);
  @override
  Widget build(BuildContext context) {
    final List arr = url.docs.toList();
    String p;
    for (int i = 0; i < arr.length; i++) {
      if (arr[i]['name'] == userName) {
        p = arr[i]['profpic'];
      }
    }
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            print(chatRoomID);
            DatabaseServices databaseService = new DatabaseServices();
            // databaseService.updateSeenInfoWhenMessReceived(chatRoomID);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ConversationScreen(chatRoomID, userName, p)));
          },
          child: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              // decoration: BoxDecoration(border: ),
              child: Row(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage("assets/profPic.jpg"),
                        ),
                        CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.transparent,
                            backgroundImage: (p == "" || p == null)
                                ? AssetImage("assets/profPic.jpg")
                                : NetworkImage(p)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Row(
                          children: <Widget>[
                            Container(
                              constraints:
                                  BoxConstraints(maxWidth: 200, maxHeight: 42),
                              child: lastmess == null
                                  ? Row(
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 5.0),
                                          child: Icon(
                                            Icons.camera_alt,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          'Image',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        )
                                      ],
                                    )
                                  : Text(
                                      lastmess,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: seenbyme == true
                                              ? FontWeight.normal
                                              : FontWeight.bold,
                                          color: Colors.black),
                                    ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              )),
        ),
        Padding(
          padding:
              EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.2),
          child: Divider(
            color: Colors.grey[600],
          ),
        )
      ],
    );
  }
}
