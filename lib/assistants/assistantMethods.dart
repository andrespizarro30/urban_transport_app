import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:urban_transport_app/DataHandler/appData.dart';
import 'package:urban_transport_app/Utils/configMaps.dart';
import 'package:urban_transport_app/assistants/requestAssistant.dart';
import 'package:urban_transport_app/model/address.dart';
import 'package:urban_transport_app/model/history_trip_model.dart';

import '../Utils/GeoPosition.dart';
import '../main.dart';
import '../model/directions_class.dart';
import '../model/geoCoding_class.dart';
import '../model/places_class.dart';
import '../model/places_info_class.dart';
import 'package:http/http.dart' as http;

class AssistantMethods{

  Future<String> searchCoordinateAddress(Position position, context) async{

    String placeAddress = "";
    String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=${geoCodingKey}";

    var response = await RequestAssistant.getRequest(Uri.parse(url));

    if(response != "failed"){
      final geoCode = GeoCodingModel.fromJson(response);

      for(var address in geoCode.results![0].addressComponents!){
        placeAddress = "${placeAddress}${address.longName} ";
      }

      Address userPickUpAddress = Address(
          placeFormattedAddress: geoCode.results![0].formattedAddress,
          placeName: placeAddress,
          placeId: geoCode.results![0].placeId,
          latitude: position.latitude,
          longitude: position.longitude
      );

      Provider.of<AppData>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);

    }

    return placeAddress;

  }

  Future<List<Predictions>?> findPlace(String placeName,context) async{

    if(placeName.length>1){
      String autoCompleteURL="https://maps.googleapis.com/maps/api/place/autocomplete/json?"
          "input=${placeName}&"
          "key=${geoCodingKey}&"
          "components=country:co";

      var response = await RequestAssistant.getRequest(Uri.parse(autoCompleteURL));

      if(response != "failed"){

        final placeCode = PlaceModel.fromJson(response);

        if(placeCode.status == "OK"){
          Provider.of<AppData>(context, listen: false).updateDropOffLocation(placeCode.predictions!);
        }else{

        }

        return placeCode.predictions;
      }
    }

    return null;
  }

  Future<PlacesInfoModel?> getPlaceDetails(String placeId,context) async{

    if(placeId.length>1){
      String placeDetailURL = "https://maps.googleapis.com/maps/api/place/details/json?"
          "place_id=${placeId}&"
          "key=${geoCodingKey}&"
          "fields=address_components,adr_address,formatted_address,geometry,place_id,type,url,vicinity";

      var response = await RequestAssistant.getRequest(Uri.parse(placeDetailURL));

      if(response != "failed"){

        final placeDetails = PlacesInfoModel.fromJson(response);

        if(placeDetails.status == "OK"){
          print(placeDetails.result!.toJson().toString());
        }

        return placeDetails;
      }

    }
    return null;
  }

  Future<List<Routes>?> getDirections(LatLng origPos, LatLng destPos, context) async{

    if(origPos != null && destPos != null){

      String directionsURL = "https://maps.googleapis.com/maps/api/directions/json?"
          "origin=${origPos.latitude},${origPos.longitude}&"
          "destination=${destPos.latitude},${destPos.longitude}&"
          "key=${geoCodingKey}";

      print(directionsURL);

      var response = await RequestAssistant.getRequest(Uri.parse(directionsURL));

      if(response != "failed"){

        final directions = DirectionsModel.fromJson(response);

        if(directions.status == "OK"){
          Provider.of<AppData>(context, listen: false).setDirectionsDetails(directions.routes!);
        }

        return directions.routes;
      }

    }

    return null;

  }

  Future<Routes?> getDriversDistanceToMe(LatLng origPos, LatLng destPos, context) async{

    if(origPos != null && destPos != null){

      String directionsURL = "https://maps.googleapis.com/maps/api/directions/json?"
          "origin=${origPos.latitude},${origPos.longitude}&"
          "destination=${destPos.latitude},${destPos.longitude}&"
          "key=${geoCodingKey}";

      print(directionsURL);

      var response = await RequestAssistant.getRequest(Uri.parse(directionsURL));

      if(response != "failed"){

        final directions = DirectionsModel.fromJson(response);

        return directions.routes![0];
      }

    }

    return null;

  }

  int calculateFares(Routes? routes, double fareKm, double fareMin){

    double distanceTraveledFare = (routes!.legs![0].distance!.value! / 1000) * fareKm;
    double timeTraveledFare = (routes!.legs![0].duration!.value! / 60) * fareMin;

    double totalFareAmount = distanceTraveledFare + timeTraveledFare;

    if(totalFareAmount<5000){
      totalFareAmount = 5000.0;
    }

    int resid = totalFareAmount.truncate() % 100;

    if (resid > 0) {
      return (totalFareAmount.truncate() ~/ 100) * 100 + 100;
    }else{
      return totalFareAmount.truncate();
    }

  }

  int calculateTravelFare(double totalDistance,int totalMinutes,double fareKm, double fareMin){

    double distanceTraveledFare = totalDistance * fareKm;
    double timeTraveledFare = totalMinutes * fareMin;

    double totalFareAmount = 2000 + distanceTraveledFare + timeTraveledFare;

    if(totalFareAmount<5000){
      totalFareAmount = 5000.0;
    }

    int resid = totalFareAmount.truncate() % 100;

    if (resid > 0) {
      return (totalFareAmount.truncate() ~/ 100) * 100 + 100;
    }else{
      return totalFareAmount.truncate();
    }

  }

  static pauseLiveLocationUpdate(){
    streamSubscriptionPosition!.pause();
    Geofire.removeLocation(firebaseAuth.currentUser!.uid);
  }

  static resumeLiveLocationUpdate(){

    streamSubscriptionPosition!.resume();
    Geofire.setLocation(
        firebaseAuth.currentUser!.uid,
        globalCurrentPosition!.latitude,
        globalCurrentPosition!.longitude
    );
  }

  static sendNotificationToDriverNow(String tokenDevice,String rideRequestId,BuildContext context) async{


    Result? result = Provider.of<AppData>(context, listen: false).result!;

    var destinationAddress = result.formattedAddress;

    Map<String, String> headerNotification = {
      'Content-Type': 'application/json',
      'Authorization': cloudMessagingServerToken
    };

    Map<String,String> bodyNotification = {
      "body":"Dirección de destino, ${destinationAddress}",
      "title":"APP Transporte Pereira"
    };

    Map<String,String> dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "rideRequestId": rideRequestId
    };

    Map<String,dynamic> officialNotificationFormat = {
      "notification":bodyNotification,
      "priority": "high",
      "data":dataMap,
      "to": tokenDevice
    };

    var responseNotification = await http.post(
      Uri.parse(messagingURL),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormat)
    );


  }

  static void readRetrieveKeysForOnLineUser(BuildContext context) async{

    await rideRequestsRef
        .orderByChild("userName")
        .equalTo(currentUserInfo!.name)
        .once()
        .then((snapShot){

          if(snapShot.snapshot.value != null){

            Map keysTrips = snapShot.snapshot.value as Map;

            List<TripsHistoryModel> listTripHistory = [];

            keysTrips.forEach((key, value) {

              if(value["status"]=="terminado"){
                var trip = TripsHistoryModel.fromMap(value);
                listTripHistory.add(trip);
              }

            });

            Provider.of<AppData>(context,listen: false).updateAllTripsHistory(listTripHistory);

          }

    });
    
  }

  static void readRetrieveKeysForOnLineDrivers(BuildContext context) async{

    await rideRequestsRef
        .orderByChild("driverId")
        .equalTo(currentDriverInfo!.id)
        .once()
        .then((snapShot){

      if(snapShot.snapshot.value != null){

        Map keysTrips = snapShot.snapshot.value as Map;

        List<TripsHistoryModelD> listTripHistory = [];

        keysTrips.forEach((key, value) {

          if(value["status"]=="terminado"){
            var trip = TripsHistoryModelD.fromMap(value);
            listTripHistory.add(trip);
          }

        });

        Provider.of<AppData>(context,listen: false).updateAllTripsHistoryD(listTripHistory);

      }

    });

  }
  
  static void getDriverEarnings(BuildContext context) async{
    await driverRef
        .child(firebaseAuth.currentUser!.uid!)
        .child("earnings")
        .once()
        .then((snapShot){

          if(snapShot.snapshot.value != null){
            String driverEarnings = snapShot.snapshot.value.toString();
            Provider.of<AppData>(context,listen: false).updateTotalEarning(driverEarnings);
          }

    });
  }

}