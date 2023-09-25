import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:urban_transport_app/Utils/configMaps.dart';
import 'package:urban_transport_app/assistants/requestAssistant.dart';
import 'package:urban_transport_app/model/places_class.dart';

import '../DataHandler/appData.dart';

late Position currentPosition;
var geolocator = Geolocator();

void locatePosition(context) async{

  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  Provider.of<AppData>(context, listen: false).updateLocation(position);

}

void locatePositionDriver(context) async{

  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  Provider.of<AppData>(context, listen: false).updateLocationDriver(position);

}

final LocationSettings locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 0,
  timeLimit: Duration(milliseconds: 600000)
);

void positionUpdates(context) async{

  Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position? position) async {
            //Provider.of<AppData>(context, listen: false).updateLocation(position!);
      });
}


void requestPositionPermission() async {

  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

}