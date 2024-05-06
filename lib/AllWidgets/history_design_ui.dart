import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:urban_transport_app/model/history_trip_model.dart';

class HistoryDesignUI extends StatefulWidget {

  TripsHistoryModel? tripHistoryInformation;

  HistoryDesignUI({this.tripHistoryInformation});

  @override
  State<HistoryDesignUI> createState() => _HistoryDesignUIState();
}

class _HistoryDesignUIState extends State<HistoryDesignUI> {
  
  @override
  Widget build(BuildContext context) {

    return Container(
      color: Colors.black54,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //DRIVER AND COST INFO
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Conductor: " + widget.tripHistoryInformation!.driverName!,
                    style: TextStyle(
                        fontSize: 16
                    ),
                  ),
                ),

                Text(
                  "COP " + widget.tripHistoryInformation!.FareAmount!,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 2,
            ),
            //CAR DETAILS
            Row(
              children: [
                Icon(
                  Icons.car_repair,
                  color: Colors.black,
                  size: 28,
                ),
                const SizedBox(
                  width: 12.0,
                ),
                Text(
                  widget.tripHistoryInformation!.car_details!,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            //ORIGIN INFO
            Row(
              children: [
                Image.asset(
                  "images/origin.png",
                  height: 26,
                  width: 26,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Text(
                    widget.tripHistoryInformation!.originAddress!,
                    style: const TextStyle(
                      fontSize: 16.0
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            //DESTINY INFO
            Row(
              children: [
                Image.asset(
                  "images/destination.png",
                  height: 20,
                  width: 20,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Text(
                    widget.tripHistoryInformation!.destinationAddress!,
                    style: const TextStyle(
                        fontSize: 16.0
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(""),
                Text(
                  formatDateAndTime(widget.tripHistoryInformation!.time!),
                  style: const TextStyle(
                    color: Colors.grey,

                  ),
                ),
              ]
            )
          ],
        ),
      ),
    );

  }

  String formatDateAndTime(String dateTimeOrig){
    
    DateTime dateTime = DateTime.parse(dateTimeOrig);
    
    return "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";

  }
  
}
