import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_background_service_ios/flutter_background_service_ios.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';


Future<void> initializeFareService() async{

  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );



  /*
    if (Platform.isIOS || Platform.isAndroid) {
      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          iOS: DarwinInitializationSettings(),
          android: AndroidInitializationSettings('ic_bg_service_small'),
        ),
      );
    }

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    */

  var androidConfiguration = AndroidConfiguration(
    onStart: onStart,
    autoStart: true,
    isForegroundMode: true,
    notificationChannelId: "channelId",
    //initialNotificationTitle: "FARE SERVICE",
    //initialNotificationContent: "Initializing",
    foregroundServiceNotificationId: 888,
  );

  var iosConfiguration = IosConfiguration(
    autoStart: true,
    onForeground: onStart,
    onBackground: onIosBackground,
  );

  await service.configure(iosConfiguration: iosConfiguration, androidConfiguration: androidConfiguration);

  service.startService();
  }

  @pragma('vm:entry-point')
  Future<bool> onIosBackground(ServiceInstance service) async {

  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;

  }

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {

  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('logo');

  var initializationSettingsIOS = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    onDidReceiveLocalNotification: (int id, String? title,String? body, String? payload) async {

    }
  );

  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,iOS: initializationSettingsIOS);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async{

    });

  var notificationDetails = await NotificationDetails(
    android: AndroidNotificationDetails("channelId","channelName",importance: Importance.max),
    iOS: DarwinNotificationDetails()
    );

  flutterLocalNotificationsPlugin.show(888, "Transport App Pereira", "Tarificador", notificationDetails);


  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
    service.setAsForegroundService();
    print("FOREGROUND SERVICES: ${DateTime.now()}");
  });

  service.on('setAsBackground').listen((event) {
    service.setAsBackgroundService();
    print("BACKGROUND SERVICE: ${DateTime.now()}");
  });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  if (service is AndroidServiceInstance) {
    if (await service.isForegroundService()) {
      service.setForegroundNotificationInfo(
      title: "Transport App Pereira", content: "Tarificador");
    }
  }


  Timer.periodic(const Duration(seconds: 5), (timer) async {

    //flutterLocalNotificationsPlugin.show(888, "Transport App Pereira", "Tarificador ${DateTime.now()}", notificationDetails);

    //Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    print("BACK GROUND TARIFICADOR RUNNING: ${DateTime.now()}");

    final deviceInfo = DeviceInfoPlugin();
    String? device;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
      },
    );

  });


}