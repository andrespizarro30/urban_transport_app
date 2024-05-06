import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserRideRequestData{

  LatLng? originLatLng;
  String? originAddress;
  LatLng? destinLatLng;
  String? destinAddress;
  String? rideRequestId;
  String? userName;
  String? userPhone;

  UserRideRequestData({this.originLatLng,this.originAddress,this.destinLatLng,this.destinAddress,this.userName,this.userPhone});

  UserRideRequestData.fromSnapshot(DataSnapshot dataSnapshot){

    if(dataSnapshot != null){

      Map valueMap = dataSnapshot.value as Map;

      double originLat = double.parse(valueMap["origin"]["latitude"].toString());
      double originLong = double.parse(valueMap["origin"]["longitude"].toString());
      originLatLng = LatLng(originLat, originLong);
      originAddress = valueMap["originAddress"].toString();

      double destinLat = double.parse(valueMap["destination"]["latitude"].toString());
      double destinLong = double.parse(valueMap["destination"]["longitude"].toString());
      destinLatLng = LatLng(destinLat, destinLong);
      destinAddress = valueMap["destinationAddress"].toString();

      rideRequestId = dataSnapshot.key.toString();
      userName = valueMap["userName"].toString();
      userPhone = valueMap["userPhone"].toString();

    }

  }

}