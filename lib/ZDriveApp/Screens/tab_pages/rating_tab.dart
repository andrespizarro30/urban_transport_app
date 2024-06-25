import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

import '../../../Utils/configMaps.dart';
import '../../../main.dart';

class RatingTabPage extends StatefulWidget {
  const RatingTabPage({super.key});

  @override
  State<RatingTabPage> createState() => _RatingTabPageState();
}

class _RatingTabPageState extends State<RatingTabPage> {

  @override
  void initState(){
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
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
                  "Mi calificación",
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
                AbsorbPointer(
                  absorbing: true,
                  child: SmoothStarRating(
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
                )
              ],
            ),
          ),
        )
      );
  }
}
