// import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/models/user.dart';
import 'package:chatapp/screens/Authenticate/helperfuncs.dart';
import 'package:chatapp/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User1 _userfromfirebaseUser(user) {
    return user != null ? User1(uid: user.uid) : null;
  }

  Stream<User1> get user {
    return _auth.authStateChanges().map(_userfromfirebaseUser);
  }

  Future signwithEMail(String email, String password) async {
    try {
      var res = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      DatabaseServices databaseService = new DatabaseServices();

      databaseService.updateDeviceToken();
      var user = res.user;
      return _userfromfirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future regwithEmail(String email, String password) async {
    try {
      var res = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      var user = res.user;
      return _userfromfirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return _auth.signOut();
      await helperFunctions.saveUserNameSharedPreference('');
      await helperFunctions.saveUserEmailSharedPreference('');
      await helperFunctions.saveUserLoggedInSharedPreference(false);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
