import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:urban_transport_app/AllWidgets/divider.dart';
import 'package:urban_transport_app/DataHandler/appData.dart';
import 'package:urban_transport_app/Utils/GeoPosition.dart';
import 'package:urban_transport_app/Utils/commonFunctions.dart';
import 'package:urban_transport_app/assistants/assistantMethods.dart';
import 'package:urban_transport_app/assistants/geofireAssitant.dart';
import 'package:urban_transport_app/model/acrtive_nearby_available_driver.dart';
import 'package:urban_transport_app/model/directions_class.dart';
import 'package:intl/intl.dart';

import '../Utils/configMaps.dart';
import '../ViewModel/backEndHelper.dart';
import '../main.dart';
import '../model/address.dart';
import '../model/fares_class.dart';
import '../model/places_info_class.dart';

class MainScreen extends StatefulWidget {

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin{

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  bool drawerOpen = true;

  final initialCameraPosition = const CameraPosition(target: LatLng(4.8103424,-75.7582129),zoom: 15.0);

  double bottomPaddingOfMap = 0;

  Address? address = null;

  Position? position = null;

  bool getLoc = true;

  TextEditingController addressTEC = TextEditingController();

  Result? result = null;

  late var obtainResults;

  bool cancelRequest = false;

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  double rideDetailsContainerHeight = 0.0;
  double requestRideContainerHeight = 0.0;
  double searchContainerHeight = 350.0;

  bool activeNearbyDriverKeysLoaded = false;

  BitmapDescriptor? activeNearbyIcon;

  Fares? fares = null;

  List<ActiveNearByAvailableDrivers>? onlineNearByAvailableDriversList =[] ;

  StreamSubscription<dynamic>? streamSubscriptionGeoFire;

  DatabaseReference? rideRequestRef_;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCurrentOnlineUserInfo();

  }

  @override
  Widget build(BuildContext context) {

    position = Provider.of<AppData>(context).position != null
        ? Provider.of<AppData>(context).position!
        : null;

    if(position != null && getLoc){
      getLoc = false;
      getPosition();
    }

    result = Provider.of<AppData>(context).result != null
        ? Provider.of<AppData>(context).result!
        : null;

    if(result != null && obtainResults == "obtainDirections"){
      obtainResults="";
      displayRideDetailsContainer();
    }
    
    cancelRequest = Provider.of<AppData>(context).cancelRequest != null
        ? Provider.of<AppData>(context).cancelRequest!
        : false;

    if(cancelRequest){
      Provider.of<AppData>(context, listen: false).setCancelRequest_();
      cancelRideRequest();
      resetApp();
    }

    address = Provider.of<AppData>(context).address != null
        ? Provider.of<AppData>(context).address!
        : Address(placeFormattedAddress: "", placeName: "", placeId: "", latitude: 0.0, longitude: 0.0);

    fares = Provider.of<AppData>(context).fares != null
        ? Provider.of<AppData>(context).fares!
        : Fares(valueKm: 0.0, valueMin: 0.0);

    fares_ = fares;

    print("FARE KM: ${fares!.valueKm.toString()}");
    print("FARE MIN: ${fares!.valueMin.toString()}");

    createActiveNearByDriverIconMarker();

    NumberFormat formatter = NumberFormat.decimalPatternDigits(
      locale: 'en_us',
      decimalDigits: 0,
    );

    Future<bool> _onWillPop() async {
      return false;
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text("Transport App"),
        ),
        drawer: Container(
          color: Colors.white,
          width: 255.0,
          child: Drawer(
            child: ListView(
              children: [
                Container(
                  height: 165.0,
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.white
                    ),
                    child: Row(
                      children: [
                        Image.asset("images/user_icon.png",height: 65.0,width: 65.0,),
                        SizedBox(width: 16.0,),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Profile Name",style: TextStyle(fontSize: 16.0,fontFamily: "Brand-Bold"),),
                            SizedBox(height: 6.0,),
                            Text("Visit profile",style: TextStyle(fontSize: 12.0,fontFamily: "Brand-Bold"),),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                DividerWidget(),
                SizedBox(height: 12.0,),
                ListTile(
                  leading: Icon(Icons.history),
                  title: Text("Historial",style: TextStyle(fontSize: 15.0)),
                  onTap: (){
                    displayToastMessages("Historial", context);
                  },
                ),
                ListTile(
                    leading: Icon(Icons.person),
                    title: Text("Perfil",style: TextStyle(fontSize: 15.0)),
                  onTap: (){
                    displayToastMessages("Perfil", context);
                  },
                ),
                ListTile(
                    leading: Icon(Icons.info),
                    title: Text("Acerca de",style: TextStyle(fontSize: 15.0)),
                  onTap: (){
                    displayToastMessages("Info", context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.follow_the_signs),
                  title: Text("Salir",style: TextStyle(fontSize: 15.0)),
                  onTap: (){
                    FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
                  },
                ),
              ],
            ),
          ),
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
            Positioned(
                top: 38.0,
                left: 22.0,
                child: GestureDetector(
                  onTap: (){
                    if(drawerOpen){
                      scaffoldKey.currentState?.openDrawer();
                    }else{
                      Geofire.stopListener();
                      streamSubscriptionGeoFire!.cancel();
                      resetApp();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black,
                              blurRadius: 6.0,
                              spreadRadius: 0.5,
                              offset: Offset(0.7, 0.7)
                          )
                        ]
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon((drawerOpen) ? Icons.menu : Icons.close,color: Colors.black,),
                      radius: 20.0,
                    ),
                  ),
                )
            ),
            Positioned(
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
                child: AnimatedSize(
                  curve: Curves.bounceIn,
                  duration: new Duration(milliseconds: 1000),
                  child: Container(
                    height: searchContainerHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(18.0)
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 16.0,
                          spreadRadius: 0.5,
                          offset: Offset(0.7,0.7)
                        )
                      ]
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0,vertical: 18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 6.0,),
                          Text("Hola..!!!",style: TextStyle(fontSize: 20.0,fontFamily: "Brand-Bold"),),
                          Text("¿A donde vamos hoy?",style: TextStyle(fontSize: 20.0,fontFamily: "Brand-Bold"),),
                          SizedBox(height: 20.0,),
                          GestureDetector(
                            onTap: () async{
                              obtainResults = await Navigator.pushNamed(context, 'search');
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.circular(5.0),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black54,
                                          blurRadius: 6.0,
                                          spreadRadius: 0.5,
                                          offset: Offset(0.7,0.7)
                                      )
                                    ]
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.search,color: Colors.blueAccent),
                                      SizedBox(width: 10.0,),
                                      Text("Buscar destino",style: TextStyle(fontSize: 15.0,fontFamily: "Brand-Bold"))
                                    ],
                                  ),
                                ),
                            ),
                          ),
                          SizedBox(height: 24.0,),
                          Row(
                            children: [
                              Icon(Icons.home,color: Colors.grey),
                              SizedBox(width: 12.0,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      address!.placeFormattedAddress!
                                      ,
                                      style: TextStyle(fontSize: 12.0,fontFamily: "Brand-Regular"),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4.0,),
                                    Text(
                                      "Tu dirección de vivienda",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14.0,
                                          fontFamily: "Signatra"
                                      ),)
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 10.0,),

                          DividerWidget(),

                          SizedBox(height: 16.0,),

                          Row(
                            children: [
                              Icon(Icons.work,color: Colors.grey),
                              SizedBox(width: 12.0,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Agregar Trabajo",style: TextStyle(fontSize: 12.0,fontFamily: "Brand-Regular")),
                                  SizedBox(height: 4.0,),
                                  Text(
                                    "Tu dirección de trabajo",
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14.0,
                                        fontFamily: "Signatra"
                                    ),)
                                ],
                              )
                            ],
                          )

                        ],
                      ),
                    ),
                  ),
                )
            ),
            Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: AnimatedSize(
                  curve: Curves.bounceIn,
                  duration: new Duration(milliseconds: 1000),
                  child: Container(
                    height: rideDetailsContainerHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0),topRight: Radius.circular(16.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 16.0,
                          spreadRadius: 0.5,
                          offset: Offset(0.7,0.7)
                        )
                      ]
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 17.0),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            color: Colors.tealAccent[100],
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                children: [
                                  Image.asset("images/taxi.png",height: 70.0,width: 80.0,),
                                  SizedBox(width: 16.0,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Automovil",style: TextStyle(fontSize: 18.0,fontFamily: "Brand-Bold"),
                                      ),
                                      Text(
                                        ((tripDirectionDetails != null) ? "${(tripDirectionDetails!.legs![0].distance!.value!/1000).truncate().toString()} km" : "0 km"),style: TextStyle(fontSize: 16.0,color: Colors.grey)
                                      )
                                    ],
                                  ),
                                  Expanded(
                                      child: Container(

                                      )
                                  ),
                                  Text(
                                      ((tripDirectionDetails != null) ? "COP ${formatter.format(AssistantMethods().calculateFares(tripDirectionDetails, fares!.valueKm, fares!.valueMin))}" : "COP 0"),style: TextStyle(fontFamily: "Brand-Bold")
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20.0,),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              children: [
                                Icon(FontAwesomeIcons.moneyCheckAlt,size: 18.0,color: Colors.black54),
                                SizedBox(width: 16.0,),
                                Text("Efectivo"),
                                SizedBox(width: 6.0,),
                                Icon(Icons.keyboard_arrow_down,color: Colors.black54,size: 16.0,)
                              ],
                            )
                          ),
                          SizedBox(height: 24.0,),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: ElevatedButton(
                                onPressed: () {
                                  displayRideRequestContainer();
                                },
                                style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.blueAccent,
                                      shape: new RoundedRectangleBorder(
                                          borderRadius: new BorderRadius.circular(24.0)
                                      )
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(17.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Solicitar",
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white
                                        ),
                                      ),
                                      Icon(FontAwesomeIcons.taxi,color: Colors.white,size: 26.0,)
                                    ],
                                  ),
                                ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
            ),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0),topRight: Radius.circular(16.0)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 0.5,
                      blurRadius: 16.0,
                      color: Colors.black54,
                      offset: Offset(0.7,0.7)
                    )
                  ]
                ),
                height: requestRideContainerHeight,
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      SizedBox(height: 12.0,),
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedTextKit(
                          repeatForever: true,
                          pause: Duration(milliseconds: 1000),
                          onTap: () {
                            print("Tap Event");
                          },
                          animatedTexts: [
                            ColorizeAnimatedText(
                              'Solicitando un Viaje',
                              textStyle: TextStyle(
                                fontSize: 45.0,
                                fontFamily: 'Signatra',
                              ),
                              colors: [
                                Colors.green,
                                Colors.purple,
                                Colors.pink,
                                Colors.blue,
                                Colors.yellow,
                                Colors.red,
                              ],
                              textAlign: TextAlign.center
                            ),
                            ColorizeAnimatedText(
                              'Por favor espere',
                              textStyle: TextStyle(
                                fontSize: 45.0,
                                fontFamily: 'Signatra',
                              ),
                              colors: [
                                Colors.green,
                                Colors.purple,
                                Colors.pink,
                                Colors.blue,
                                Colors.yellow,
                                Colors.red,
                              ],
                              textAlign: TextAlign.center
                            ),
                            ColorizeAnimatedText(
                                'Por favor espere.',
                                textStyle: TextStyle(
                                  fontSize: 45.0,
                                  fontFamily: 'Signatra',
                                ),
                                colors: [
                                  Colors.green,
                                  Colors.purple,
                                  Colors.pink,
                                  Colors.blue,
                                  Colors.yellow,
                                  Colors.red,
                                ],
                                textAlign: TextAlign.center
                            ),
                            ColorizeAnimatedText(
                                'Por favor espere..',
                                textStyle: TextStyle(
                                  fontSize: 45.0,
                                  fontFamily: 'Signatra',
                                ),
                                colors: [
                                  Colors.green,
                                  Colors.purple,
                                  Colors.pink,
                                  Colors.blue,
                                  Colors.yellow,
                                  Colors.red,
                                ],
                                textAlign: TextAlign.center
                            ),
                            ColorizeAnimatedText(
                                'Por favor espere...',
                                textStyle: TextStyle(
                                  fontSize: 45.0,
                                  fontFamily: 'Signatra',
                                ),
                                colors: [
                                  Colors.green,
                                  Colors.purple,
                                  Colors.pink,
                                  Colors.blue,
                                  Colors.yellow,
                                  Colors.red,
                                ],
                                textAlign: TextAlign.center
                            ),
                            ColorizeAnimatedText(
                              'Buscando a un Conductor',
                              textStyle: TextStyle(
                                fontSize: 45.0,
                                fontFamily: 'Signatra',
                              ),
                              colors: [
                                Colors.green,
                                Colors.purple,
                                Colors.pink,
                                Colors.blue,
                                Colors.yellow,
                                Colors.red,
                              ],
                              textAlign: TextAlign.center
                            ),
                          ],
                          isRepeatingAnimation: true,
                        ),
                      ),
                      SizedBox(height: 22.0,),
                      GestureDetector(
                        onTap: (){
                          //cancelRequest = true;
                          //cancelRideRequest();
                          //resetApp();
                        },
                        child: Container(
                          height: 60.0,
                          width: 60.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26.0),
                            border: Border.all(width: 2.0,color: Colors.grey.shade300),
                          ),
                          child: Icon(Icons.close,size: 26.0,),
                        ),
                      ),
                      SizedBox(height: 10.0,),
                      Container(
                        width: double.infinity,
                        child: Text("Cancelar Viaje",textAlign: TextAlign.center,style: TextStyle(fontSize: 15.0),),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void getPosition() async{

    if(position == null){
      locatePosition(context);
    }
    else
    if(position != null){
      LatLng latLng = LatLng(position!.latitude, position!.longitude);
      CameraPosition cameraPosition = new CameraPosition(target: latLng,zoom: 14);
      newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      await AssistantMethods().searchCoordinateAddress(position!,context);
      initializeGeofireListener();
    }

  }

  void getPositionUpdates() async{

    //positionUpdates(context);

  }

  void getDirection() async{

    LatLng origPos = LatLng(position!.latitude, position!.longitude);
    LatLng destPos = LatLng(result!.geometry!.location!.lat!, result!.geometry!.location!.lng!);

    var res = await AssistantMethods().getDirections(position!, destPos, context);

    setState(() {
      tripDirectionDetails = res![0];
    });

    print("DIRECTIONS");
    print(res![0].overviewPolyline!.toJson().toString());

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePolylinePointsResult = polylinePoints.decodePolyline(res![0].overviewPolyline!.points!);

    pLineCoordinates.clear();

    if(decodePolylinePointsResult.isNotEmpty){
      decodePolylinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates.add(LatLng(pointLatLng.latitude,pointLatLng.longitude));
      });
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
          polylineId: PolylineId("polylineId"),
          color: Colors.blueAccent,
          jointType: JointType.round,
          points: pLineCoordinates,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.squareCap,
          geodesic: true
      );

      polylineSet.add(polyline);

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
        markerId: MarkerId("pickUpMarker"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow: InfoWindow(
          title: address!.placeName,
          snippet: "Partida"
        ),
        position: origPos
    );

    Marker destLocationMarker = Marker(
        markerId: MarkerId("destinyMarker"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
            title: result!.name!,
            snippet: "Llegada"
        ),
        position: destPos
    );

    setState(() {
      markersSet.add(origLocationMarker);
      markersSet.add(destLocationMarker);
    });

    Circle origLocCircle = Circle(
        circleId: CircleId("pickUpCircle"),
        fillColor: Colors.blueAccent,
        center: origPos,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.yellowAccent,
    );

    Circle destLocCircle = Circle(
      circleId: CircleId("destinyCircle"),
      fillColor: Colors.deepPurple,
      center: destPos,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.deepPurpleAccent,
    );

    setState(() {
      circlesSet.add(origLocCircle);
      circlesSet.add(destLocCircle);
    });


  }

  void resetApp(){

    setState(() {
      requestRideContainerHeight = 0.0;
      searchContainerHeight = 390.0;
      rideDetailsContainerHeight = 0.0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = true;

      polylineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();
    });

    rideRequestRef_ = null;

    getPosition();

  }

  void displayRideDetailsContainer() async{

    getFaresValues(context);

    getDirection();

    setState(() {
      searchContainerHeight = 0.0;
      rideDetailsContainerHeight = 300.0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = false;
    });

  }

  void displayRideRequestContainer() async{
    setState(() {
      requestRideContainerHeight = 250.0;
      rideDetailsContainerHeight = 0.0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = true;
    });

    saveRideRequest();

  }

  void saveRideRequest(){

    onlineNearByAvailableDriversList = GeoFireAssistance.activeNearbyAvailableDriversList;

    searchNearestOnlineDrivers();

  }

  void sendSavedRequest(){

    var pickUp = LatLng(position!.latitude, position!.longitude);
    var dropOff = LatLng(result!.geometry!.location!.lat!, result!.geometry!.location!.lng!);

    Map<String,String>? pickUpLocMap = {
      "latitude" : pickUp.latitude.toString(),
      "longitude" : pickUp.longitude.toString()
    };

    Map<String,String>? dropOffUpLocMap = {
      "latitude" : dropOff.latitude.toString(),
      "longitude" : dropOff.longitude.toString()
    };

    Map userInformatioMap = {
      "origin": pickUpLocMap!,
      "destination": dropOffUpLocMap,
      "time": DateTime.now().toString(),
      "userName": currentUserInfo!.name,
      "userPhone": currentUserInfo!.phone,
      "originAddress": address!.placeFormattedAddress,
      "destinationAddress": result!.formattedAddress,
      "driverId":"esperando",
      "payment_method":"efectivo",
    };

    rideRequestRef_ = rideRequestsRef.push();
    rideRequestRef_!.set(userInformatioMap);
  }

  void searchNearestOnlineDrivers() async{

    if(onlineNearByAvailableDriversList!.length == 0){
      Geofire.stopListener();
      streamSubscriptionGeoFire!.cancel();
      cancelRideRequest();
      resetApp();
      displayToastMessages("No hay conductores cercanos, intente en unos minutos!!!", context);
    }else{
      sendSavedRequest();
      await retrieveOnlineDriversInformation(onlineNearByAvailableDriversList);
      Geofire.stopListener();
      streamSubscriptionGeoFire!.cancel();
      var response = await Navigator.pushNamed(context, "nearest_drivers");
      
      if(response == "driverChosen"){
        driverRef.child(chosenDriverId!).once().then((snapShot){
          if(snapShot.snapshot.value != null){
            sendNotificationToDriverNow(chosenDriverId);
          }else{
            displayToastMessages("Este conductor no existe, intente de nuevo!!!", context);
          }
        });
      }
      
    }

  }

  void sendNotificationToDriverNow(String? chosenDriverId) {

    //Asigna el ID de la solicitud de servicio a newRideStatus en el id del conductor seleccionado
    driverRef.child(chosenDriverId!).child("newRideStatus").set(rideRequestRef_!.key);

  }

  retrieveOnlineDriversInformation(List<ActiveNearByAvailableDrivers>? onlineNearByAvailableDriversList) async{

    for(int i=0; i<onlineNearByAvailableDriversList!.length; i++){

      await driverRef.child(onlineNearByAvailableDriversList[i].driverId.toString())
          .once()
          .then((dataSnapshot){

            var driverInfoKey = dataSnapshot.snapshot.value as Map;

            if(driverInfoKey != null){
              int index = dList.indexWhere((element) => element["phone"].toString() == driverInfoKey["phone"].toString());
              if(index<0){
                driverInfoKey["key"] = dataSnapshot.snapshot.key;
                dList.add(driverInfoKey);
              }
            }
      });

    }

  }


  void cancelRideRequest(){

    if(rideRequestRef_ != null){
      rideRequestRef_!.remove();
    }

    GeoFireAssistance.activeNearbyAvailableDriversList = [];
    dList = [];

  }

  void initializeGeofireListener() {
    
    Geofire.initialize("activeDrivers");

    streamSubscriptionGeoFire = Geofire.queryAtLocation(position!.latitude, position!.longitude, 3)!.listen((map) {

      print(map);

      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {

          case Geofire.onKeyEntered:

            ActiveNearByAvailableDrivers activeNearByAvailableDriver = ActiveNearByAvailableDrivers();
            activeNearByAvailableDriver.driverId = map['key'];
            activeNearByAvailableDriver.locLatitude = map['latitude'];
            activeNearByAvailableDriver.locLongitude = map['longitude'];
            activeNearByAvailableDriver.bearing = 0.0;

            if(!GeoFireAssistance.driverExists(map['key'])){
              GeoFireAssistance.activeNearbyAvailableDriversList.add(activeNearByAvailableDriver);
            }

            if(activeNearbyDriverKeysLoaded){
              displayActiveDriverOnUserMap();
            }

            break;

          case Geofire.onKeyExited:

            GeoFireAssistance.deleteOfflineDriverFromList(map['key']);

            displayActiveDriverOnUserMap();

            break;

          case Geofire.onKeyMoved:

            LatLng lastDriverPosition = GeoFireAssistance.getLastLocationFromDriver(map['key']);

            ActiveNearByAvailableDrivers activeNearByAvailableDriver = ActiveNearByAvailableDrivers();
            activeNearByAvailableDriver.driverId = map['key'];
            activeNearByAvailableDriver.locLatitude = map['latitude'];
            activeNearByAvailableDriver.locLongitude = map['longitude'];


            LatLng currentDriverPosition = LatLng(map['latitude'], map['longitude']);

            double bearing = 0.0;
            if(lastDriverPosition != currentDriverPosition){
              bearing = getBearing(lastDriverPosition, currentDriverPosition);
            }
            activeNearByAvailableDriver.bearing = bearing;


            GeoFireAssistance.updateActiveNearbyAvailableDriverLocation(activeNearByAvailableDriver);

            displayActiveDriverOnUserMap();

            break;

          case Geofire.onGeoQueryReady:

            activeNearbyDriverKeysLoaded = true;

            displayActiveDriverOnUserMap();

            break;
        }
      }

      setState(() {});

    });
    
  }

  void displayActiveDriverOnUserMap(){

    setState(() {
      markersSet.clear();
      circlesSet.clear();

      Set<Marker> driversMarkerSet = Set<Marker>();

      for(ActiveNearByAvailableDrivers anad in GeoFireAssistance.activeNearbyAvailableDriversList){

        LatLng driverPos = LatLng(anad.locLatitude!,anad.locLongitude!);

        Marker driverMark = Marker(
            markerId: MarkerId(anad.driverId!),
            icon: activeNearbyIcon!,
            position: driverPos,
            rotation: anad.bearing!
        );

        driversMarkerSet.add(driverMark);

      }

      setState(() {
        markersSet= driversMarkerSet;
      });


    });
  }

  createActiveNearByDriverIconMarker() async{
    if(activeNearbyIcon == null){

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
          activeNearbyIcon = value;
        });
      }else{
        BitmapDescriptor.fromAssetImage(imageConfiguration, "images/carmap_android.png").then((value){
          activeNearbyIcon = value;
        });
      }


    }
  }
  
}