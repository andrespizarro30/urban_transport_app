import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:urban_transport_app/DataHandler/appData.dart';
import 'package:urban_transport_app/Utils/configMaps.dart';
import 'package:urban_transport_app/assistants/requestAssistant.dart';
import 'package:urban_transport_app/model/address.dart';

import '../model/directions_class.dart';
import '../model/geoCoding_class.dart';
import '../model/places_class.dart';
import '../model/places_info_class.dart';

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
          "key=${geoCodingKey}";

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

  Future<List<Routes>?> getDirections(Position origPos, LatLng destPos, context) async{

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


}