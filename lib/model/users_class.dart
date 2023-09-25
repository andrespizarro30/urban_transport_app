import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Users {

  String? id;
  String? email;
  String? name;
  String? phone;

  Users({this.id,this.email,this.name,this.phone});

  Users.fromSnapshot(DataSnapshot dataSnapshot){

    if(dataSnapshot != null){

      Map valueMap = dataSnapshot.value as Map;

      id = dataSnapshot.key.toString();
      email = valueMap["email"].toString();
      name = valueMap["name"].toString();
      phone = valueMap["phone"].toString();

    }

  }

}