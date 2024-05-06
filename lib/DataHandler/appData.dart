import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:urban_transport_app/model/address.dart';
import 'package:urban_transport_app/model/fares_class.dart';
import 'package:urban_transport_app/model/geoCoding_class.dart';
import 'package:urban_transport_app/model/places_class.dart';
import 'package:urban_transport_app/model/places_info_class.dart';

import '../model/directions_class.dart';
import '../model/history_trip_model.dart';

class AppData extends ChangeNotifier{

  Position? position;

  void updateLocation(Position position){

    this.position=position;

    notifyListeners();

  }

  Position? positionDriver;

  void updateLocationDriver(Position position){

    this.positionDriver=position;

    notifyListeners();

  }

  Address? address;

  void updatePickUpLocationAddress(Address address){

    this.address = address;

    notifyListeners();

  }

  List<Predictions>? predictions;

  void updateDropOffLocation(List<Predictions> predictions){

    this.predictions = predictions;

    notifyListeners();

  }

  Result? result;

  void setPlacesDetails(Result result){

    this.result = result;

    notifyListeners();

  }

  List<Routes>? routes;

  void setDirectionsDetails(List<Routes> routes){

    this.routes = routes;

    notifyListeners();

  }

  Fares? fares;

  void getFaresValues(Fares fares){

    this.fares = fares;

    notifyListeners();
  }

  bool? cancelRequest;

  void setCancelRequest(bool cancel){

    this.cancelRequest = cancel;

    notifyListeners();

  }

  void setCancelRequest_(){

    this.cancelRequest = false;

  }


  FareInfo? fareInfo;

  void setFareInfo(FareInfo fareInfo){

    this.fareInfo = fareInfo;

    notifyListeners();

  }

  void setFareInfo_(){

    this.fareInfo = null;

  }

  List<TripsHistoryModel> listTripHistory = [];

  void updateAllTripsHistory(List<TripsHistoryModel> listTripHistory){

    this.listTripHistory = listTripHistory;

    notifyListeners();
  }

  List<TripsHistoryModelD> listTripHistoryD = [];

  void updateAllTripsHistoryD(List<TripsHistoryModelD> listTripHistoryD){

    this.listTripHistoryD = listTripHistoryD;

    notifyListeners();
  }

  String? totalEarning;

  void updateTotalEarning(String earning){

    this.totalEarning = earning;

    notifyListeners();
  }

}