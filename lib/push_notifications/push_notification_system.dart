import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:urban_transport_app/Utils/commonFunctions.dart';
import 'package:urban_transport_app/push_notifications/notification_dialog_box.dart';
import '../Utils/configMaps.dart';
import '../main.dart';
import '../model/request_message_class.dart';
import '../model/user_ride_request_data.dart';

class PushNotificationSystem{

  BuildContext context;

  PushNotificationSystem({required this.context});

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessaging() async{

    //1.Terminated
    //cuando la app esta completamente cerrada y abre directamente desde la notificación

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage)
    {
      if(remoteMessage != null){

        final requestMessageDetails = PushMessageServiceRequestData.fromJson(remoteMessage.data);
        readUserRideRequestInfo(requestMessageDetails.rideRequestId!);

      }
    });

    //2.Foreground
    //cuando la app esta abierta y recive una notificación
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      if(remoteMessage != null){

        final requestMessageDetails = PushMessageServiceRequestData.fromJson(remoteMessage.data);
        readUserRideRequestInfo(requestMessageDetails.rideRequestId!);

      }
    });

    //3.Background
    //cuando la app esta en segundo plano y abre directamente desde la notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      if(remoteMessage != null){

        final requestMessageDetails = PushMessageServiceRequestData.fromJson(remoteMessage.data);
        readUserRideRequestInfo(requestMessageDetails.rideRequestId!);

      }
    });

  }

  Future generateMessagingToken() async{

    FirebaseMessaging.instance.requestPermission();

    String? registrationToken = await messaging.getToken();

    print("FCM Registration Token: ");
    print(registrationToken);

    driverRef.child(firebaseUser!.uid).child("token").set(registrationToken);

    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");
    messaging.subscribeToTopic("generalInfo");

  }

  void readUserRideRequestInfo(String rideRequestId) {

    rideRequestsRef.child(rideRequestId).once().then((snapData) {
      if(snapData.snapshot.value != null){

        audioPlayer.open(Audio("sounds/music_notification.mp3"));
        audioPlayer.play();

        userRideRequestData = UserRideRequestData.fromSnapshot(snapData.snapshot);

        showDialog(context: context, barrierDismissible: false, builder: (BuildContext context) => NotificationDialogBox(
            userRideRequestDetails: userRideRequestData
        ));

      }else{
          displayToastMessages("Esta solicitud no existe", context);
      }
    });

  }

}
