import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Home/conversation.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/shared/constants.dart';
import 'package:substring_highlight/substring_highlight.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchcontroller = new TextEditingController();
  DatabaseServices databaseService = new DatabaseServices();
  QuerySnapshot searchsnapshot;
  List<QueryDocumentSnapshot> finalRes;
  Map<String, String> searchresult = {};
  bool loading = false;

  createChatRoomandStartConv(String userName, String userProfpic) async {
    String curUserProfpic = Constants.MyProfPic;
    List<String> users = [userName, Constants.MyName];
    String chatRoomID = getChatRoomID(userName, Constants.MyName);
    var len = await databaseService.getSingleChatRoom(chatRoomID);
    print(len.exists);
    if (len.exists == false) {
      print('create');
      Map<String, dynamic> chatRoomMap = {
        "users": users,
        "chatRoomID": chatRoomID,
        'lastMessage': "",
        'lastMessageTime': 0,
        "hour": 0,
        "minute": 0,
        "lastmessBy": "",
        "seenby$userName": true,
        "seenby${Constants.MyName}": true,
      };
      databaseService.createChatRoom(chatRoomID, chatRoomMap);
    }
    print(chatRoomID);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ConversationScreen(chatRoomID, userName, userProfpic)));
  }

  Widget SearchTile({String userName, String userEmail, String userProfpic}) {
    return GestureDetector(
      onTap: () {
        createChatRoomandStartConv(userName, userProfpic);
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey)),
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        child: ListTile(
          dense: false,
          isThreeLine: false,
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage("assets/profPic.jpg"),
              ),
              CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.transparent,
                  backgroundImage: (userProfpic == "" || userProfpic == null)
                      ? AssetImage("assets/profPic.jpg")
                      : NetworkImage(userProfpic)),
            ],
          ),
          subtitle: Text(
            userName, // each string needing highlighting
            style: TextStyle(
              // fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w500,
              // fontStyle: FontStyle.italic,
            ),
          ),
          title: Text(
            userEmail, // each string needing highlighting
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              // fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }

  Widget searchResultList() {
    return finalRes == null
        ? Container()
        : ListView.builder(
            itemCount: finalRes.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              if (finalRes[index].get('name') != Constants.MyName) {
                return SearchTile(
                  userName: finalRes[index].get("name"),
                  userEmail: finalRes[index].get("email"),
                  userProfpic: finalRes[index].get("profpic"),
                );
              }
              return Container();
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            // color: Colors.grey[900],
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          // color: Colors.white,
                          size: 25,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          autofocus: true,
                          style: TextStyle(color: Colors.black, fontSize: 18),
                          controller: searchcontroller,
                          onChanged: (value) async {
                            setState(() {
                              loading = true;
                            });
                            await databaseService
                                .searchUser(searchcontroller.text)
                                .then((val) {
                              setState(() {
                                searchsnapshot = val;
                                if (searchcontroller.text == "") {
                                  finalRes = [];
                                } else {
                                  finalRes = searchsnapshot.docs
                                      .where((element) => (element
                                              .get('name')
                                              .startsWith(
                                                  searchcontroller.text) ||
                                          element.get('email').startsWith(
                                              searchcontroller.text)))
                                      .toList();
                                }
                                setState(() {
                                  loading = false;
                                });
                              });
                            });
                          },
                          decoration: InputDecoration(
                              alignLabelWithHint: true,
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                color: Colors.grey[700],
                              ),
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
                                    BorderSide(color: Colors.blue, width: 2),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                loading
                    ? Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : searchResultList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

getChatRoomID(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}
