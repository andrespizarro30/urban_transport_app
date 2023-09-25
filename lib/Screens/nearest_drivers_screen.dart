import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import 'package:urban_transport_app/Utils/commonFunctions.dart';
import 'package:urban_transport_app/Utils/configMaps.dart';

import '../DataHandler/appData.dart';
import '../assistants/assistantMethods.dart';

class NearestActiveDriversScreen extends StatefulWidget {

  @override
  State<NearestActiveDriversScreen> createState() => _NearestActiveDriversScreenState();
}

class _NearestActiveDriversScreenState extends State<NearestActiveDriversScreen> {
  @override
  Widget build(BuildContext context) {

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
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.white54,
          title: const Text(
            "Conductores Cercanos",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.close, color: Colors.white,
            ),
            onPressed: (){
              Provider.of<AppData>(context, listen: false).setCancelRequest(true);
              displayToastMessages("Has cancelado la solicitud de Servicio...", context);
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView.builder(
          itemCount: dList.length,
          itemBuilder: (BuildContext context, int index){
            return GestureDetector(
              onTap: (){

                setState(() {
                  chosenDriverId = dList[index]["key"];
                });

                Navigator.pop(context,"driverChosen");

              },
              child: Card(
                color: Colors.grey,
                elevation: 3,
                shadowColor: Colors.green,
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: FadeInImage(
                      placeholder: AssetImage('images/car_android.png'),
                      image: NetworkImage("https://firebasestorage.googleapis.com/v0/b/plataformatransporte-b20ba.appspot.com/o/${dList[index]["carMake"]}_${dList[index]["carModel"]}.jpeg?alt=media&token=dc8ab158-472d-4150-b19b-2fa87971b4d6"),
                      width: 70,
                      height: 70,
                    ),
                  ),
                  title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          dList[index]["name"],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54
                          ),
                        ),
                        Text(
                          "${dList[index]["carMake"]}-${dList[index]["carModel"]}",
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54
                          )
                        ),
                        SmoothStarRating(
                          rating: 3.5,
                          color: Colors.black,
                          borderColor: Colors.black,
                          allowHalfRating: true,
                          starCount: 5,
                          size: 15,
                        )
                      ],
                    ),trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "COP ${formatter.format(AssistantMethods().calculateFares(tripDirectionDetails, fares_!.valueKm, fares_!.valueMin))}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(height: 2,),
                        Text(
                          (tripDirectionDetails != null ? (tripDirectionDetails!.legs![0].distance!.value!/1000).toStringAsFixed(2) : "0.00") + " km",
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(height: 2,),
                        Text(
                          (tripDirectionDetails != null ? (tripDirectionDetails!.legs![0].duration!.value!/60).toStringAsFixed(0) : "0.00") + " min",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black
                          ),
                        )
                      ],
                    ),
                ),
              ),
            );
          }
        ),
      ),
    );

  }
}
