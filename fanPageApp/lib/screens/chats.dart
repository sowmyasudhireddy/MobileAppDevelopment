import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Chats extends StatefulWidget {
  const Chats({Key? key}) : super(key: key);

  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  final Stream<QuerySnapshot> _messageStream = FirebaseFirestore.instance.collection('messages').orderBy("date",descending: true).orderBy('time',descending: true).snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _messageStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            return Card(
              child: ListTile(
                leading: Icon(Icons.message, color: Colors.red,size: 50,),
                title: Text(data['message']),
                subtitle: Text( "sent from : "+data['sender']+ " at: "+data['date']+" "+data['time']),
                isThreeLine: true,
              ),

            );
          }).toList(),
        );
      },
    );
  }
}
