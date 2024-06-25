import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import 'package:urban_transport_app/Utils/commonFunctions.dart';

import '../Utils/configMaps.dart';
import '../main.dart';

class RateDriverScreen extends StatefulWidget {

  String? driverId;

  RateDriverScreen({this.driverId});

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14)
        ),
        backgroundColor: Colors.white60,
        child: Container(
          margin: EdgeInsets.all(8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(6)
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 22.0,
              ),
              Text(
                "Califique el viaje",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54
                ),
              ),
              SizedBox(
                height: 22.0,
              ),
              Divider(
                height: 4.0,thickness: 4.0,
              ),
              SizedBox(height: 22.0,),
              SmoothStarRating(
                rating: countRatingStars,
                allowHalfRating: true,
                starCount: 5,
                color: Colors.green,
                borderColor: Colors.white,
                size: 46,
                onRatingChanged: (valueOfStars){
                  countRatingStars = valueOfStars;
                  if(countRatingStars >= 0 && countRatingStars<2){
                    setState(() {
                      titleStarsRating = "Muy Mal";
                    });
                  }else
                  if(countRatingStars >= 2 && countRatingStars<3){
                    setState(() {
                      titleStarsRating = "Mal";
                    });
                  }else
                  if(countRatingStars >= 3 && countRatingStars<4){
                    setState(() {
                      titleStarsRating = "Bueno";
                    });
                  }else
                  if(countRatingStars >= 4 && countRatingStars<5){
                    setState(() {
                      titleStarsRating = "Muy Bueno";
                    });
                  }else
                  if(countRatingStars == 5){
                    setState(() {
                      titleStarsRating = "Excelente";
                    });
                  }
                },
              ),
              SizedBox(
                height: 12.0,
              ),
              Text(
                titleStarsRating,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.green
                ),
              ),
              SizedBox(
                height: 18.0,
              ),
              ElevatedButton(
                  onPressed: (){
                    DatabaseReference rateDriversRef = driverRef.child(widget.driverId!).child("ratings");

                    rateDriversRef.once().then((snapShot){
                      if(snapShot.snapshot.value == null){
                        rateDriversRef.set(countRatingStars.toString());
                        SystemNavigator.pop();
                      }else{
                        double pastRatings = double.parse(snapShot.snapshot.value.toString());
                        double newAvgRating = (pastRatings + countRatingStars)/2;
                        rateDriversRef.set(newAvgRating.toString());
                        Navigator.pop(context);
                        //SystemNavigator.pop();
                      }
                    });
                    displayToastMessages("Gracias por utilizar nuestro servicio", context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 58)
                  ),
                  child: Text(
                    "Enviar",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  )
              ),
              SizedBox(
                height: 10.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
