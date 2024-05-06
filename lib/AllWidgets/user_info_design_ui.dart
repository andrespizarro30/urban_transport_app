import 'package:flutter/material.dart';

class UserInfoDesignUI extends StatefulWidget {

  String? textInfo;
  IconData? iconData;

  UserInfoDesignUI({this.textInfo,this.iconData});

  @override
  State<UserInfoDesignUI> createState() => _UserInfoDesignUIState();
}

class _UserInfoDesignUIState extends State<UserInfoDesignUI> {
  @override
  Widget build(BuildContext context) {

    return Card(
      color: Colors.white54,
      margin: const EdgeInsets.symmetric(vertical: 12,horizontal: 24),
      child: ListTile(
        leading: Icon(
          widget!.iconData!,
          color: Colors.black,
        ),
        title: Text(
          widget!.textInfo!,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );

  }
}
