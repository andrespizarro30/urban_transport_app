import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vector_math/vector_math.dart';
import 'dart:math';

displayToastMessages(String msg,BuildContext context){
  Fluttertoast.showToast(msg: msg,toastLength: Toast.LENGTH_LONG);
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

double getBearing(LatLng startPosition, LatLng endPosition){
  double lat= (startPosition.latitude-endPosition.latitude).abs();
  double lng= (startPosition.longitude-endPosition.longitude).abs();

  if(startPosition.latitude<endPosition.latitude && startPosition.longitude<endPosition.longitude){
    return degrees(atan(lng/lat));
  }else
  if(startPosition.latitude>=endPosition.latitude && startPosition.longitude<endPosition.longitude){
    return (90 - degrees(atan(lng/lat)))+90;
  }else
  if(startPosition.latitude>=endPosition.latitude && startPosition.longitude>=endPosition.longitude){
    return degrees(atan(lng/lat))+180;
  }else
  if(startPosition.latitude<endPosition.latitude && startPosition.longitude>=endPosition.longitude){
    return (90 - degrees(atan(lng/lat)))+270;
  }

  return -1;
}