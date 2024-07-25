import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:urban_transport_app/model/drivers_class.dart';
import 'package:urban_transport_app/model/users_class.dart';

import '../model/directions_class.dart';
import '../model/fares_class.dart';
import '../model/user_ride_request_data.dart';

String androidMapKey = "AIzaSyAkBBvSMGpO4EoLTNjkLr7V-HzvdRlTY14";
String iosMapKey = "AIzaSyB3gCARPJjOJlVD-HWqHYxUpwC2T-ZnxYg";
String geoCodingKey = "AIzaSyCBDQ2l_f4ksZaSzkCqhNsOhdHfbU5lKqA";

String cloudMessagingServerToken = "";

String messagingURL = "https://fcm.googleapis.com/fcm/send";

User? firebaseUser;
Users? currentUserInfo;
Drivers? currentDriverInfo;

UserRideRequestData? userRideRequestData;

AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();

List dList = [];

String? chosenDriverId = "";

Routes? tripDirectionDetails;

Fares? fares_;

double countRatingStars = 0.0;

String titleStarsRating = "";
