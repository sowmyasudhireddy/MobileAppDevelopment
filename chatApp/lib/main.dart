import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/screens/Home/conversation.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/shared/constants.dart';
import './screens/Wrapper.dart';
import './services/auth.dart';
import 'package:provider/provider.dart';
import './models/user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluro/fluro.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // StreamSubscription iosSubscription;
  // void initState() {
  //   final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  //   if (Platform.isIOS) {
  //     iosSubscription = _fcm.getToken();
  //     onIosSettingsRegistered.listen((data) {
  //       // save the token  OR subscribe to a topic here
  //     });
  //     _fcm.requestNotificationPermissions(IosNotificationSettings());
  //   }
  // }
  var trackHandler =
      Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return ConversationScreen(
        params["id"][0], params["id"][1], params["id"][2]);
  });
  void defineRoutes(FluroRouter router) {
    router.define("/conv/:id/:name/:pic", handler: trackHandler);
    // it is also possible to define the route transition to use
    // router.define("users/:id", handler: usersHandler, transitionType: TransitionType.inFromLeft);
  }

  @override
  void initState() {
    notifInit();
    var router = FluroRouter();

    defineRoutes(router);
    super.initState();
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp();
    print('Handling a background message ${message.messageId}');
  }

  void notifInit() {
    var fbm = FirebaseMessaging.instance;
    // fbm.requestPermission();
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
        print(message);
      }
    });
    FirebaseMessaging.onBackgroundMessage((msg) async {
      print(msg.data);
      dynamic data = msg.data;
      var db = DatabaseServices();
      var chatRoom;
      var chatRoomID = Constants.MyName + "_" + data['title'];
      chatRoom = await db.getSingleChatRoom(chatRoomID);
      if (chatRoom == null) {
        var chatRoomID = data['title'] + "_" + Constants.MyName;
        chatRoom = await db.getSingleChatRoom(chatRoomID);
      }
      final GlobalKey<NavigatorState> navigatorKey =
          new GlobalKey<NavigatorState>();
      print(chatRoomID);
      return navigatorKey.currentState.pushReplacementNamed(
          '/conv/:$chatRoomID/:${data["title"]}/:${chatRoom[data["title"]]}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<User1>.value(
      value: AuthService().user,
      child: MaterialApp(
        theme: ThemeData(
            appBarTheme: AppBarTheme(
                titleTextStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 22),
                color: Colors.black,
                iconTheme: IconThemeData(color: Colors.green[900]))),
        home: Wrapper(),
      ),
    );
  }
}
