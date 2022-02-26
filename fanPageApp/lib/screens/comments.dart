import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:comment_box/comment/comment.dart';

class Comments extends StatefulWidget {
 final List comments;
 final String docId;
  const Comments({Key? key, required List this.comments,required this.docId}) : super(key: key);

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  List key = [];
  List labels=[];
  String _fname="";
  String _lname="";
  void _get_data(){
    FirebaseFirestore.instance.collection("Users").doc(FirebaseAuth.instance.currentUser.uid).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        _fname= documentSnapshot.data()["First name"];
        _lname=documentSnapshot.data()["Last name"];
      } else {
        //return ('Document does not exist on the database');
      }
    });
  }
  TextEditingController commentController = TextEditingController();
  void comments_updator(String comment){
    List c=widget.comments;
    c+=[{_fname+" "+_lname:comment}];
    print(widget.comments);
    FirebaseFirestore.instance.collection("posts").doc(widget.docId).set({"comments":c},SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    _get_data();
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.red,
          title:Text("Comments")
      ),
      body: Column(
    children:<Widget>[
      Expanded(
      child:ListView.builder(
      itemCount: widget.comments.length,
      itemBuilder: (BuildContext context, int index) {
        Map d=widget.comments[index];
        return Container(
                    child: Card(
                        child: ListTile(
                            title:Text(d.values.toString().replaceAll("(","").replaceAll(")", "")),
                          subtitle:Text(d.keys.toString().replaceAll("(","").replaceAll(")", "")),

                    ),));},
      )),
      Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10,bottom: 10,top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  SizedBox(width: 15,),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: "Write or reply to a comment...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none
                      ),
                      controller:commentController ,
                    ),
                  ),
                  SizedBox(width: 15,),
                  FloatingActionButton(
                    onPressed: (){comments_updator(commentController.text.toString());
                    commentController.text="";
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                    },

                    child: Icon(Icons.send,color: Colors.white,size: 18,),
                    backgroundColor: Colors.red,
                    elevation: 0,
                  ),
                ],

              ),
            ),
          ),
        ],
      ),



    ]),);
  }
}