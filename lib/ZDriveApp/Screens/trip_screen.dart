import 'dart:async';
import 'dart:isolate';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:urban_transport_app/AllWidgets/fare_amount_collection_dialog.dart';
import 'package:urban_transport_app/AllWidgets/progressDialog.dart';
import 'package:urban_transport_app/Utils/commonFunctions.dart';

import '../../DataHandler/appData.dart';
import '../../Utils/GeoPosition.dart';
import '../../Utils/configMaps.dart';
import '../../ViewModel/backEndHelper.dart';
import '../../assistants/assistantMethods.dart';
import '../../background_services/back_services.dart';
import '../../main.dart';
import '../../model/fares_class.dart';
import '../../model/user_ride_request_data.dart';

class TripScreen extends StatefulWidget {

  UserRideRequestData? userRideRequestDetails;

  TripScreen({this.userRideRequestDetails});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  @override

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController newGoogleMapController;

  final initialCameraPosition = const CameraPosition(target: LatLng(4.8103424,-75.7582129),zoom: 15.0);

  String? buttonTitle = "Llegué";
  Color? buttonColor = Colors.green;

  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircles = Set<Circle>();
  Set<Polyline> setOfPolyline = Set<Polyline>();
  List<LatLng> polyLinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  Position? currentPosition = null;
  Position? onLineDriverCurrentPosition = null;

  LatLng? lastDriverPosition = LatLng(0, 0);

  bool isRequestDirectionDetails = false;

  String rideRequestStatus = "aceptado";

  String durationFromOriginToDestination = "";

  double mapPadding = 0.0;

  int speed = 0;
  Color? speedColor = Colors.lightGreen;

  BitmapDescriptor? iconAnimatedMarker;
  var geolocator = Geolocator();

  Fares? fares = null;
  int totalFareAmount = 0;
  double totalDistance = 0.0;
  int totalMinutes = 0;
  String? timeTraveled = '00:00:00';
  Stopwatch stopwatch = Stopwatch();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    updateDriverLocationAtRealTime();
    getFaresValues(context);

  }

  Widget build(BuildContext context) {

    createDriverIconMarker();

    currentPosition = Provider.of<AppData>(context).positionDriver != null
        ? Provider.of<AppData>(context).positionDriver!
        : null;

    globalCurrentPosition = onLineDriverCurrentPosition;

    fares = Provider.of<AppData>(context).fares != null
        ? Provider.of<AppData>(context).fares!
        : Fares(valueKm: 0.0, valueMin: 0.0);

    NumberFormat formatter = NumberFormat.decimalPatternDigits(
      locale: 'en_us',
      decimalDigits: 0,
    );

    totalFareAmount = AssistantMethods().calculateTravelFare(totalDistance, totalMinutes, fares!.valueKm, fares!.valueMin);

    Future<bool> _onWillPop() async {
      return false;
    }

    return WillPopScope(
    onWillPop: _onWillPop,
    child: Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            markers: setOfMarkers,
            circles: setOfCircles,
            polylines: setOfPolyline,
            initialCameraPosition: initialCameraPosition,
            onMapCreated: (GoogleMapController controller){
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              setState(() {
                mapPadding = 350;
              });

              var driverCurrentPosition = LatLng(currentPosition!.latitude, currentPosition!.longitude);

              var userPickUpPosition = widget.userRideRequestDetails!.originLatLng;

              getDirection(driverCurrentPosition, userPickUpPosition!);

              saveAssignedDriverToUser();

            },
          ),
          Positioned(
              left: 0,
              top: 30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(width: 2),
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "${speed} km/h",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: speedColor,
                          backgroundColor: Colors.white
                      ),
                    )
                  ],
                )
              )
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.0)
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 18,
                    spreadRadius: 0.5,
                    offset: Offset(0.6, 0.6)
                  )
                ]
              ),
              height: 400,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 20),
                child: Column(
                  children: [
                    Text(
                        "${durationFromOriginToDestination} mins",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightGreenAccent
                      ),
                    ),

                    const SizedBox(height: 10.0,),

                    Divider(thickness: 2,height: 2,color: Colors.grey,),

                    const SizedBox(height: 10.0,),

                    Row(
                      children: [
                        Text(
                          widget.userRideRequestDetails!.userName!,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightGreenAccent
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.phone_android,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 15.0,),

                    Row(
                      children: [
                        Image.asset("images/origin.png",
                          width: 30,
                          height: 30,
                        ),

                        const SizedBox(width: 15,),

                        Expanded(
                          child: Text(
                            widget.userRideRequestDetails!.originAddress!,
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey
                            ),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 10.0,),

                    Row(
                      children: [
                        Image.asset("images/destination.png",
                          width: 30,
                          height: 30,
                        ),

                        const SizedBox(width: 22,),

                        Expanded(
                          child: Text(
                            widget.userRideRequestDetails!.destinAddress!,
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey
                            ),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 10.0,),

                    Divider(thickness: 2,height: 2,color: Colors.grey,),

                    const SizedBox(height: 10.0,),

                    ElevatedButton.icon(
                        onPressed: () async{
                          if(rideRequestStatus == "aceptado"){

                            rideRequestStatus = "llego";

                            rideRequestsRef
                                .child(widget.userRideRequestDetails!.rideRequestId!)
                                .child("status").set(rideRequestStatus);

                            setState(() {
                              buttonTitle="Vamos!!!";
                              buttonColor = Colors.lightGreen;
                            });
                            
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext c) => ProgressDialog(
                                message: "Cargando ruta..."
                                )
                            );

                            await getDirection(
                                widget.userRideRequestDetails!.originLatLng!,
                                widget.userRideRequestDetails!.destinLatLng!
                            );

                            Navigator.pop(context);
                            
                          }else
                          if(rideRequestStatus == "llego"){

                            rideRequestStatus = "viajando";

                            rideRequestsRef
                                .child(widget.userRideRequestDetails!.rideRequestId!)
                                .child("status").set(rideRequestStatus);

                            setState(() {
                              buttonTitle="Finalizar Viaje";
                              buttonColor = Colors.redAccent;
                            });

                            //await initializeFareService();
                            //FlutterBackgroundService().invoke("setAsForeground");
                            //FlutterBackgroundService().invoke("setAsBackground");
                            startFareCounter();

                          }else
                          if(rideRequestStatus == "viajando"){

                            _timer.cancel();
                            stopwatch.stop();

                            //FlutterBackgroundService().invoke("stopService");

                            endTripNow();

                          }


                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor
                        ),
                        icon: Icon(
                            Icons.directions_car,
                          color: Colors.white,
                          size: 25,
                        ),
                        label: Text(
                          buttonTitle!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold
                          ),
                        )
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "${timeTraveled}",
                          style: TextStyle(
                              color: Colors.lightGreenAccent,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                          "${(totalDistance).toStringAsFixed(2)} Km",
                          style: TextStyle(
                              color: Colors.lightGreenAccent,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "COP ${formatter.format(totalFareAmount)}",
                      style: TextStyle(
                          color: Colors.lightGreenAccent,
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      )
    )
    );
  }

  Future<void> getDirection(LatLng origPos, LatLng destPos) async{

    showDialog(context: context, builder: (BuildContext context) => ProgressDialog(message: "Por favor espere"));

    var res = await AssistantMethods().getDirections(origPos, destPos, context);

    Navigator.pop(context);

    setState(() {
      tripDirectionDetails = res![0];
    });

    print("DIRECTIONS");
    print(tripDirectionDetails!.overviewPolyline!.toJson().toString());

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePolylinePointsResult = polylinePoints.decodePolyline(tripDirectionDetails!.overviewPolyline!.points!);

    polyLinePositionCoordinates.clear();

    if(decodePolylinePointsResult.isNotEmpty){
      decodePolylinePointsResult.forEach((PointLatLng pointLatLng) {
        polyLinePositionCoordinates.add(LatLng(pointLatLng.latitude,pointLatLng.longitude));
      });
    }

    setOfPolyline.clear();

    setState(() {
      Polyline polyline = Polyline(
          polylineId: PolylineId("polylineId"),
          color: Colors.blueAccent,
          jointType: JointType.round,
          points: polyLinePositionCoordinates,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.squareCap,
          geodesic: true
      );

      setOfPolyline.add(polyline);

    });

    LatLngBounds latLngBounds;

    if(origPos.latitude > destPos.latitude && origPos.longitude > destPos.longitude){
      latLngBounds = LatLngBounds(southwest: destPos, northeast: origPos);
    }else
    if(origPos.longitude > destPos.longitude){
      latLngBounds = LatLngBounds(southwest: LatLng(origPos.latitude,destPos.longitude), northeast: LatLng(destPos.latitude,origPos.longitude));
    }else
    if(origPos.latitude > destPos.latitude){
      latLngBounds = LatLngBounds(southwest: LatLng(destPos.latitude,origPos.longitude), northeast: LatLng(origPos.latitude,destPos.longitude));
    }else{
      latLngBounds = LatLngBounds(southwest: origPos, northeast: destPos);
    }

    newGoogleMapController.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker origLocationMarker = Marker(
        markerId: MarkerId("originId"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow: InfoWindow(
            title: "Mi Ubicación",
            snippet: "Partida"
        ),
        position: origPos
    );

    Marker destLocationMarker = Marker(
        markerId: MarkerId("destinyId"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
            title: widget.userRideRequestDetails!.originAddress!,
            snippet: "Llegada"
        ),
        position: destPos
    );

    setState(() {
      setOfMarkers.add(origLocationMarker);
      setOfMarkers.add(destLocationMarker);
    });

    Circle origLocCircle = Circle(
      circleId: CircleId("originCircleId"),
      fillColor: Colors.green,
      center: origPos,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.yellowAccent,
    );

    Circle destLocCircle = Circle(
      circleId: CircleId("destinyCircleId"),
      fillColor: Colors.red,
      center: destPos,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.deepPurpleAccent,
    );

    setState(() {
      setOfCircles.add(origLocCircle);
      setOfCircles.add(destLocCircle);
    });

  }

  void saveAssignedDriverToUser(){

    DatabaseReference rideRequestReference = rideRequestsRef.child(widget.userRideRequestDetails!.rideRequestId!);

    Map driverLocationMap = {
      "latitude": currentPosition!.latitude.toString(),
      "longitude": currentPosition!.longitude.toString()
    };

    rideRequestReference.child("driverLocation").set(driverLocationMap);
    rideRequestReference.child("status").set("aceptado");
    rideRequestReference.child("driverId").set(currentDriverInfo!.id!);
    rideRequestReference.child("driverName").set(currentDriverInfo!.name!);
    rideRequestReference.child("driverPhone").set(currentDriverInfo!.phone!);
    rideRequestReference.child("car_details").set(currentDriverInfo!.carMake! +" - "+ currentDriverInfo!.carModel! +"-"+ currentDriverInfo!.carColor!);

    //saveRideRequestIdToDriverHistory();

  }

  /*
  void saveRideRequestIdToDriverHistory(){

    DatabaseReference tripHistoryReference = driverRef.child(firebaseAuth.currentUser!.uid).child("tripsHistory");

    tripHistoryReference.child(widget.userRideRequestDetails!.rideRequestId!).set(true);

  }
  */

  void updateDriverLocationAtRealTime(){

    streamSubscriptionDriverLivePosition = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (Position? position) async {

          globalCurrentPosition = position;
          onLineDriverCurrentPosition = position;

          LatLng latLng = LatLng(this.onLineDriverCurrentPosition!.latitude, this.onLineDriverCurrentPosition!.longitude);

          latLng = LatLng(this.onLineDriverCurrentPosition!.latitude, this.onLineDriverCurrentPosition!.longitude);

          double bearing = getBearing(lastDriverPosition!, latLng);

          Marker animatedMarker = Marker(
              markerId: const MarkerId("AnimatedMarker"),
              icon: iconAnimatedMarker!,
              infoWindow: const InfoWindow(title: "Mi posición"),
              position: latLng,
              rotation: bearing
          );

          if(rideRequestStatus == "viajando"){
            double distance = ((lastDriverPosition!.latitude != 0 && lastDriverPosition!.longitude != 0) ?
            Geolocator.distanceBetween(
                lastDriverPosition!.latitude,
                lastDriverPosition!.longitude,
                onLineDriverCurrentPosition!.latitude,
                onLineDriverCurrentPosition!.longitude
            ):0.0);
            setState(() {
              totalDistance = totalDistance + distance/1000;
            });
          }

          lastDriverPosition = LatLng(onLineDriverCurrentPosition!.latitude, onLineDriverCurrentPosition!.longitude);

          setState(() {

            CameraPosition cameraPosition = CameraPosition(target: latLng,zoom: 16);
            newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

            setOfMarkers.removeWhere((element) => element.markerId.value == "AnimatedMarker");
            setOfMarkers.add(animatedMarker);

            speed = (position!.speed * (3600/1000)).truncate();

            if(speed<60){
              speedColor = Colors.lightGreenAccent;
            }else{
              speedColor = Colors.redAccent;
            }

            updateDurationTimeAtRealTime();

            Map driverLatLng = {
              "latitude": onLineDriverCurrentPosition!.latitude.toString(),
              "longitude": onLineDriverCurrentPosition!.longitude.toString()
            };

            rideRequestsRef.child(widget.userRideRequestDetails!.rideRequestId!).child("driverLocation").set(driverLatLng);
            rideRequestsRef.child(widget.userRideRequestDetails!.rideRequestId!).child("speed").set(speed);

          });
        });

  }

  createDriverIconMarker() async{

    if(iconAnimatedMarker == null){

      ImageConfiguration imageConfiguration = ImageConfiguration(
          bundle: DefaultAssetBundle.of(context),
          devicePixelRatio: MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0,
          locale: Localizations.maybeLocaleOf(context),
          textDirection: Directionality.maybeOf(context),
          size: const Size(2,2)
      );

      bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

      if(isIOS){
        BitmapDescriptor.fromAssetImage(imageConfiguration, "images/carmap_ios.png").then((value){
          iconAnimatedMarker = value;
        });
      }else{
        BitmapDescriptor.fromAssetImage(imageConfiguration, "images/carmap_android.png").then((value){
          iconAnimatedMarker = value;
        });
      }


    }
  }

  void updateDurationTimeAtRealTime() async{

    if(!isRequestDirectionDetails){

      isRequestDirectionDetails= true;

      if(onLineDriverCurrentPosition == null){
        return;
      }

      var originLatLng = LatLng(onLineDriverCurrentPosition!.latitude, onLineDriverCurrentPosition!.longitude);

      var destinationLatLng;

      if(rideRequestStatus == "aceptado"){
        destinationLatLng = widget.userRideRequestDetails!.originLatLng;
      }else{
        destinationLatLng = widget.userRideRequestDetails!.destinLatLng;
      }

      var res = await AssistantMethods().getDirections(originLatLng!, destinationLatLng, context);

      if(res != null){
        setState(() {
          durationFromOriginToDestination = (res[0].legs![0].duration!.value!/60).toStringAsFixed(0).toString();
        });
      }

      isRequestDirectionDetails = false;

    }

  }

  void endTripNow() async{

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) => ProgressDialog(
            message: "Por favor espere..."
        )
    );

    /*
    var currentDriverPositionLatlng = LatLng(
        onLineDriverCurrentPosition!.latitude,
        onLineDriverCurrentPosition!.longitude
    );

    var tripDirectionDetails = await AssistantMethods().getDirections(
        currentDriverPositionLatlng,
        widget.userRideRequestDetails!.originLatLng!,
        context
    );

    int totalFareAmount = AssistantMethods().calculateFares(tripDirectionDetails![0], fares!.valueKm, fares!.valueMin);
    */

    rideRequestsRef
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .child("FareAmount")
        .set(totalFareAmount.toString());

    rideRequestStatus = "terminado";

    rideRequestsRef
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .child("status")
        .set(rideRequestStatus);

    streamSubscriptionDriverLivePosition!.cancel();

    Navigator.pop(context);

    showDialog(
        context: context,
        builder: (BuildContext c) => FareAmountCollectionDialog(
          totalFareAmount: totalFareAmount,
          userType: "Conductor"
        ));

    saveFareAmountDriverEarnings(totalFareAmount);

  }

  void saveFareAmountDriverEarnings(int totalFareAmount) {

    driverRef
        .child(firebaseAuth.currentUser!.uid!)
        .child("earnings").once().then((snapshot){

          if(snapshot.snapshot.value != null){
            int oldEarnings = int.parse(snapshot.snapshot.value.toString());
            int driverTotalEarnings = totalFareAmount + oldEarnings;
            driverRef
                .child(firebaseAuth.currentUser!.uid!)
                .child("earnings")
                .set(driverTotalEarnings.toString());
          }else{
            driverRef
                .child(firebaseAuth.currentUser!.uid!)
                .child("earnings")
                .set(totalFareAmount.toString());
          }

    });

  }

  late Timer _timer;

  void startFareCounter() async{

    Duration traveledTime;

    _timer= Timer.periodic(const Duration(milliseconds: 1000), (Timer t) {

      traveledTime = stopwatch.elapsed;

      setState(() {
        totalMinutes = (stopwatch.elapsed.inHours * 60) + stopwatch.elapsed.inMinutes;
        timeTraveled = '${traveledTime.inHours.toString().padLeft(2, '0')}:${(traveledTime.inMinutes % 60).toString().padLeft(2, '0')}:${(traveledTime.inSeconds % 60).toString().padLeft(2, '0')}';
      });
    });

    stopwatch.start();

  }

}
