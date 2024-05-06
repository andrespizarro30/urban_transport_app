import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:urban_transport_app/Utils/GeoPosition.dart';
import 'package:urban_transport_app/Utils/commonFunctions.dart';
import 'package:urban_transport_app/Utils/configMaps.dart';
import 'package:urban_transport_app/main.dart';
import 'package:urban_transport_app/model/drivers_class.dart';
import 'package:urban_transport_app/push_notifications/push_notification_system.dart';

import '../../../DataHandler/appData.dart';
import '../../../ViewModel/backEndHelper.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> with AutomaticKeepAliveClientMixin {

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController newGoogleMapController;

  Position? position = null;

  double bottomPaddingOfMap = 0;

  final initialCameraPosition = const CameraPosition(target: LatLng(4.8103424,-75.7582129),zoom: 15.0);
  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  bool getLoc = true;

  String statusText = "Offline";
  Color buttonColor = Colors.grey;
  bool isDriverActive = false;

  int speed = 0;
  Color? speedColor = Colors.lightGreen;

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCurrentOnlineUserInfo();
    readCurrentDriverInformation();

  }

  @override
  Widget build(BuildContext context) {

    position = Provider.of<AppData>(context).positionDriver != null
        ? Provider.of<AppData>(context).positionDriver!
        : null;

    if(position != null && getLoc){
      getLoc = false;
      getPosition();
    }

    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Transport App"),
          ),
          body: Stack(
              children: [
                GoogleMap(
                  padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
                  mapType: MapType.normal,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  zoomGesturesEnabled: true,
                  zoomControlsEnabled: true,
                  polylines: polylineSet,
                  markers: markersSet,
                  circles: circlesSet,
                  initialCameraPosition: initialCameraPosition,
                  onMapCreated: (GoogleMapController controller){
                    _controllerGoogleMap.complete(controller);
                    newGoogleMapController = controller;

                    setState(() {
                      bottomPaddingOfMap=265.0;
                    });

                    getPosition();
                    //getPositionUpdates();

                  },
                ),

                (statusText != "Online" ?
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    color: Colors.black87,
                  ) :
                  Container(

                  )
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
                  top: statusText != "Online" ?
                    MediaQuery.of(context).size.height * 0.45 :
                    25.0,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: (){
                            if(!isDriverActive){
                              driverIsOnLine();
                              updateDriverLocationAtRealTime();
                              setState(() {
                                statusText="Online";
                                isDriverActive = true;
                                buttonColor = Colors.lightGreenAccent;
                              });
                              displayToastMessages("Estás En Linea", context);
                            }else{
                              driverIsOffLine();
                              setState(() {
                                statusText="Offline";
                                isDriverActive = false;
                                buttonColor = Colors.grey;
                              });
                              displayToastMessages("Estás Fuera de Linea", context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            primary: buttonColor,
                            padding: const EdgeInsets.symmetric(horizontal: 18.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26)
                            )
                          ),
                          child: statusText != "Online" ?
                          Text(
                            statusText,
                            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white),
                          ) :
                          Icon(
                            Icons.phonelink_ring,
                            color: Colors.white,
                            size: 26.0,
                          )
                      )
                    ],
                  )
                )
              ]
          ),
        )
    );
  }

  void getPosition() async{

    if(position == null){
      locatePositionDriver(context);
    }
    else
    if(position != null){
      LatLng latLng = LatLng(position!.latitude, position!.longitude);
      CameraPosition cameraPosition = new CameraPosition(target: latLng,zoom: 14);
      newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }

  }
  
  void driverIsOnLine(){

    Geofire.initialize("activeDrivers");
    Geofire.setLocation(
        firebaseAuth.currentUser!.uid,
        position!.latitude,
        position!.longitude
    );

    DatabaseReference ref = driverRef
        .child(firebaseAuth.currentUser!.uid)
        .child("newRideStatus");

    ref.set("idle");
    ref.onValue.listen((event) {

    });

  }

  void updateDriverLocationAtRealTime(){

    streamSubscriptionPosition = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (Position? position) async {

              this.position = position;

              if(isDriverActive){
                Geofire.setLocation(
                    firebaseAuth.currentUser!.uid,
                    position!.latitude,
                    position!.longitude
                );
              }

              LatLng latLng = LatLng(this.position!.latitude, this.position!.longitude);

              setState(() {
                CameraPosition cameraPosition = CameraPosition(target: latLng,zoom: 16);
                newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

                speed = (position!.speed * (3600/1000)).truncate();

                if(speed<60){
                  speedColor = Colors.lightGreenAccent;
                }else{
                  speedColor = Colors.redAccent;
                }

              });
        });

  }

  void driverIsOffLine(){
    Geofire.removeLocation(firebaseAuth.currentUser!.uid);

    DatabaseReference? ref = driverRef
        .child(firebaseAuth.currentUser!.uid)
        .child("newRideStatus");

    ref.onDisconnect();
    ref.remove();
    ref = null;

    Future.delayed(const Duration(milliseconds: 2000),(){
      //SystemChannels.platform.invokeMethod("SystemNavigator.pop");
      SystemNavigator.pop(animated: false);
    });

  }

  void readCurrentDriverInformation() async{

    PushNotificationSystem pushNotificationSystem = PushNotificationSystem(context: context);
    pushNotificationSystem.initializeCloudMessaging();
    pushNotificationSystem.generateMessagingToken();

  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
