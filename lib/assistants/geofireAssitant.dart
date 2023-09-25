import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/acrtive_nearby_available_driver.dart';

class GeoFireAssistance{

  static List<ActiveNearByAvailableDrivers> activeNearbyAvailableDriversList = [];

  static bool driverExists(String driverId){

    int index = activeNearbyAvailableDriversList.indexWhere((element) => element.driverId == driverId);

    return (index>=0 ? true : false);

  }

  static void deleteOfflineDriverFromList(String driverId){

    int index = activeNearbyAvailableDriversList.indexWhere((element) => element.driverId == driverId);

    if(index>=0){
      activeNearbyAvailableDriversList.removeAt(index);
    }

  }

  static void updateActiveNearbyAvailableDriverLocation(ActiveNearByAvailableDrivers driverMoving){

    int index = activeNearbyAvailableDriversList.indexWhere((element) => element.driverId == driverMoving.driverId);

    if(index>=0){
      activeNearbyAvailableDriversList[index].locLatitude = driverMoving.locLatitude;
      activeNearbyAvailableDriversList[index].locLongitude = driverMoving.locLongitude;
      activeNearbyAvailableDriversList[index].bearing = driverMoving.bearing;
    }

  }

  static LatLng getLastLocationFromDriver(String driverId){

    int index = activeNearbyAvailableDriversList.indexWhere((element) => element.driverId == driverId);

    LatLng lastDriverPosition = LatLng(0.0, 0.0);

    if(index>=0){
      lastDriverPosition = LatLng(activeNearbyAvailableDriversList[index].locLatitude!, activeNearbyAvailableDriversList[index].locLongitude!);
    }


    return lastDriverPosition;
  }

}