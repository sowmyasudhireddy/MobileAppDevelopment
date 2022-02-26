import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mad_assignment_1/screens/comments.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  String _post_id="";
  String _docId="";
  Stream <QuerySnapshot>collectionStream =FirebaseFirestore.instance.collection('posts').snapshots();
 void liker() {
    FirebaseFirestore.instance.collection("posts").doc(_docId).update({"likes":FieldValue.increment(1)});
  }
  Future<void> nav(List<dynamic> list) async {
    Navigator.push(context,MaterialPageRoute(builder:(context)=>Comments(comments:list,docId:_docId)));
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: collectionStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index){
              return Card(
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      child:Image.network(snapshot.data!.docs[index]['url'],loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },)
                    ),
              ExpansionTile(
                      title: Text(snapshot.data!.docs[index]['user']),
                      subtitle: Text("Posted on :"+snapshot.data!.docs[index]['date']+" at "+snapshot.data!.docs[index]['time']),
                      children:[Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children:[
                            Container(
                                child:IconButton(icon: Icon(Icons.thumb_up),onPressed:(){setState(() {
                                  _post_id=snapshot.data!.docs[index]['userId'];
                                  _docId=snapshot.data!.docs[index]['docId'];
                                  liker();
                                });},
                                  color: Colors.blue,)
                            ),
                            Text("Likes : "+snapshot.data!.docs[index]["likes"].toString()),
              ]),
                            Column(
                            children:[Container(
                              child: IconButton(icon: Icon(Icons.comment),onPressed:(){setState(() {
                                _docId=snapshot.data!.docs[index]['docId'];
                                nav(snapshot.data!.docs[index]['comments']);

                              });},color: Colors.green),),
                                Text("Comments : "+snapshot.data!.docs[index]["comments"].length.toString()),
            ]
                            )

                          ]


                      ),]
                    ),

              ]));
            },



          );
        }
    );
  }
}
