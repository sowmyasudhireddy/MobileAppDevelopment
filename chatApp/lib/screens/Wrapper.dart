import 'package:flutter/material.dart';
import '../screens/Authenticate/Authenticate.dart';
import '../screens/Home/Home.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User1>(context);
    if (user == null) {
    } else {}
    // user.uid.;

    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}
