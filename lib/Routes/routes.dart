import 'package:flutter/material.dart';
import 'package:urban_transport_app/AllWidgets/progressDialog.dart';
import 'package:urban_transport_app/Screens/login_screen.dart';
import 'package:urban_transport_app/Screens/main_screen.dart';
import 'package:urban_transport_app/Screens/nearest_drivers_screen.dart';
import 'package:urban_transport_app/Screens/registration_screen.dart';
import 'package:urban_transport_app/Screens/search_screen.dart';
import 'package:urban_transport_app/Screens/splash_screen.dart';
import 'package:urban_transport_app/ZDriveApp/Screens/d_main_screen.dart';
import 'package:urban_transport_app/ZDriveApp/Screens/trip_screen.dart';

Map<String, WidgetBuilder> getRoutes(){
  return <String,WidgetBuilder>{
    'login' : (BuildContext context) => LoginScreen(),
    'register' : (BuildContext context) => RegistrationScreen(),
    'main': (BuildContext context) => MainScreen(),
    'search': (BuildContext context) => SearchScreen(),
    'splash': (BuildContext context) => MySplashScreen(),
    'd_main': (BuildContext context) => D_MainScreen(),
    'nearest_drivers': (BuildContext context) => NearestActiveDriversScreen(),
    'trip_screen': (BuildContext context) => TripScreen(),
  };
}