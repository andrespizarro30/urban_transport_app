import UIKit
import Flutter
import GoogleMaps
import FirebaseCore

import CoreLocation

import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GMSServices.provideAPIKey("AIzaSyB3gCARPJjOJlVD-HWqHYxUpwC2T-ZnxYg")

    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback{(registry) in
    GeneratedPluginRegistrant.register(with: registry)
    }

    GeneratedPluginRegistrant.register(with: self)

    if #available(iOS 10.0, *){
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
      
      let locationManager = CLLocationManager()
      locationManager.delegate = self as? CLLocationManagerDelegate
      locationManager.requestAlwaysAuthorization()
      locationManager.startUpdatingLocation()
      locationManager.showsBackgroundLocationIndicator = true

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
