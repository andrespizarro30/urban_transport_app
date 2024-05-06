import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:urban_transport_app/Utils/commonFunctions.dart';
import 'package:urban_transport_app/Utils/configMaps.dart';
import 'package:urban_transport_app/ZDriveApp/Screens/trip_screen.dart';
import 'package:urban_transport_app/assistants/assistantMethods.dart';
import 'package:urban_transport_app/main.dart';

import '../model/user_ride_request_data.dart';


class NotificationDialogBox extends StatefulWidget {

  UserRideRequestData? userRideRequestDetails;
  
  NotificationDialogBox({this.userRideRequestDetails});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {

  @override
  Widget build(BuildContext context) {
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24)
      ),
      backgroundColor: Colors.transparent,
        elevation: 2,
      child: Container(
        margin: EdgeInsets.all(5),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[800]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 22,),

            Image.asset("images/car_logo.png",
              width: 160,
            ),

            const SizedBox(height: 2,),

            Text(
              "Nueva Solicitud de Servicio",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),

            const SizedBox(height: 2,),

            const Divider(
              height: 3,
              thickness: 3,
              color: Colors.grey,
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset("images/origin.png",
                        width: 30,
                        height: 30,
                      ),

                      const SizedBox(width: 22,),

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

                  const SizedBox(height: 20,),

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
                  )
                ],
              ),
            ),

            const Divider(
              height: 3,
              thickness: 3,
              color: Colors.grey,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: (){
                        audioPlayer.pause();
                        audioPlayer.stop();
                        audioPlayer = AssetsAudioPlayer();
                        
                        rideRequestsRef
                            .child(widget.userRideRequestDetails!.rideRequestId!)
                            .remove().then((value){
                              driverRef
                                  .child(firebaseAuth.currentUser!.uid!)
                                  .child("newRideStatus")
                                  .set("idle");
                        }).then((value){
                          driverRef
                              .child(firebaseAuth.currentUser!.uid!)
                              .child("tripsHistory")
                              .child(widget.userRideRequestDetails!.rideRequestId!).remove();
                        }).then((value) => {
                          displayToastMessages("Solicitud de Viaje Cancelada", context)
                        });
                        
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Cancelar".toUpperCase(),
                        style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.white
                        ),
                      ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      maximumSize: Size(200, 40)
                    ),
                  ),

                  const SizedBox(width: 10,),

                  ElevatedButton(
                      onPressed: (){
                        audioPlayer.pause();
                        audioPlayer.stop();
                        audioPlayer = AssetsAudioPlayer();

                        acceptRideRequest(context);

                      },
                      child: Text(
                        "Aceptar".toUpperCase(),
                        style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.white
                        ),
                      ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      maximumSize: Size(200, 40)
                    ),
                  )
                ],
              ),
            ),

          ],
        ),
      ),
    );
    
  }

  void acceptRideRequest(BuildContext context) {

    String rideRequestId = "";

    driverRef.child(firebaseAuth.currentUser!.uid).child("newRideStatus").once().then((snapShot){
      if(snapShot.snapshot.value != null){
        rideRequestId = snapShot.snapshot.value.toString();
      }else{
        displayToastMessages("Esta solicitud ya no existe", context );
      }

      if(rideRequestId == widget.userRideRequestDetails!.rideRequestId){

        AssistantMethods.pauseLiveLocationUpdate();

        driverRef.child(firebaseAuth.currentUser!.uid).child("newRideStatus").set("aceptado");

        Navigator.push(context, MaterialPageRoute(builder: (c)=>TripScreen(
            userRideRequestDetails : widget.userRideRequestDetails
        )));

      }else{
        driverRef.child(firebaseAuth.currentUser!.uid).child("idle");
        displayToastMessages("Esta solicitud ya no existe", context);
        Navigator.pop(context);
      }

    });

  }
}
