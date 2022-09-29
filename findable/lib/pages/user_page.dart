import 'package:flutter/material.dart';

import '../models/users.dart';


class UserPage extends StatefulWidget {
  const UserPage({Key? key, required this.user}) : super(key: key);
  final User user;


  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
        child: Scaffold(
          body: Center(
            child: Text(widget.user.name),
          ),
        )
    );
  }

}