import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/shared/constants.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

// import 'package:image_crop/image_crop.dart';
import 'dart:io';

class Profile extends StatefulWidget {
  String userName;
  String Profpic;
  Profile(this.userName, this.Profpic);
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Profile> {
  DatabaseServices databaseService = new DatabaseServices();
  QuerySnapshot imagesnapshot;
  bool up = false;

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async {
    imagesnapshot = await databaseService.getProfPic(Constants.MyName);
    Constants.MyProfPic = imagesnapshot.docs[0].get('profpic');
    print("pic ${Constants.MyProfPic}");
  }

  initialValue(val) {
    return TextEditingController(text: val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(widget.userName),
        ),
        body: Container(
            // padding: EdgeInsets.only(top: 70),
            // width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: MediaQuery.of(context).size.width * 0.3,
                          backgroundImage: AssetImage("assets/profPic.jpg"),
                        ),
                        CircleAvatar(
                            radius: MediaQuery.of(context).size.width * 0.3,
                            backgroundColor: Colors.transparent,
                            backgroundImage: (widget.Profpic != ""
                                ? NetworkImage(widget.Profpic)
                                : AssetImage("assets/profPic.jpg"))),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Rating : ",
                      style: TextStyle(color: Colors.black, fontSize: 25),
                    ),
                    Text(
                      "5" + "/5",
                      style: TextStyle(color: Colors.black, fontSize: 25),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Number of users rated : ",
                      style: TextStyle(color: Colors.black, fontSize: 25),
                    ),
                    Text(
                      "5",
                      style: TextStyle(color: Colors.black, fontSize: 25),
                    )
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                // Text(
                //   "Select rating and click submit",
                //   style: TextStyle(color: Colors.black, fontSize: 20),
                // ),
                // SizedBox(
                //   height: 30,
                // ),
                RatingBar.builder(
                  initialRating: 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star_border,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    print(rating);
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.green[900])),
                    onPressed: () {},
                    child: Text(
                      "SAVE RATING",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ))
              ],
              // Scaffold.of(context).showSnackBar(snackBar);
            )));
  }
}
