import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:chatapp/shared/constants.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

class DatabaseServices {
  searchUser(String name) {
    return FirebaseFirestore.instance
        .collection('user')
        // .where("name", isGreaterThan: name)
        .get();
  }

  searchUserbyEmail(String email) {
    return FirebaseFirestore.instance
        .collection('user')
        .where("email", isEqualTo: email)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  getProfPic(String name) {
    return FirebaseFirestore.instance
        .collection('user')
        .where("name", isEqualTo: name)
        .get();
  }

  getAllProfPics() async {
    var shot = await FirebaseFirestore.instance.collection('user').get();
    return shot;
  }

  uploadUserInfo(String name, String email) {
    FirebaseFirestore.instance
        .collection('user')
        .doc(name)
        .set({'name': name, 'email': email, 'profpic': "", 'tokens': []});
    updateDeviceToken();
  }

  uploadUserProfilePic(String name, String imageUrl) {
    FirebaseFirestore.instance
        .collection('user')
        .doc(name)
        .update({'profpic': imageUrl});
  }

  createChatRoom(String chatRoomID, chatRoomMap) {
    FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomID)
        .set(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  sendMessagetoFirestore(String chatRoomID, chatMap, time) {
    FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomID)
        .collection('chats')
        .doc(time)
        .set(chatMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  updateLastMessage(String chatRoomID, String mess) {
    print(chatRoomID);
    FirebaseFirestore.instance.collection('chatRooms').doc(chatRoomID).update({
      'lastMessage': mess,
      'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
      "hour": DateTime.now().hour,
      "minute": DateTime.now().minute,
      'lastmessBy': Constants.MyName,
    });
  }

  updateDeviceToken() {
    FirebaseMessaging.instance.getToken().then((token) {
      FirebaseFirestore.instance
          .collection('user')
          .doc(Constants.MyName)
          .update({
        'tokens': FieldValue.arrayUnion([token])
      });
    });
  }

  getMessagesFromFirestore(String chatRoomID) {
    return FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomID)
        .collection('chats')
        .orderBy("time", descending: true)
        .snapshots();
  }

  getChatRooms(String userName) async {
    return FirebaseFirestore.instance
        .collection('chatRooms')
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  getSingleChatRoom(String chatRoomID) async {
    var d = await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomID)
        .get();
    return d;
  }

  updateSeenInfoWhenMessSent(String chatRoomID, String user) {
    FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomID)
        .update({'seenby$user': false});
  }

  updateSeenInfoWhenMessReceived(String chatRoomID) {
    FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomID)
        .update({'seenby${Constants.MyName}': true});
  }

  updateseenInfoOfText(String chatRoomID, time) {
    FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomID)
        .collection('chats')
        .doc(time)
        .update({'seenby': true});
  }
}
