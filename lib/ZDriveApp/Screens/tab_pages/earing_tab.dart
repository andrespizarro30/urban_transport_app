import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:urban_transport_app/Screens/history_screen.dart';
import 'package:urban_transport_app/assistants/assistantMethods.dart';

import '../../../DataHandler/appData.dart';
import '../../../model/history_trip_model.dart';

class EaringTabPage extends StatefulWidget {
  const EaringTabPage({super.key});

  @override
  State<EaringTabPage> createState() => _EaringTabPageState();
}

class _EaringTabPageState extends State<EaringTabPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    AssistantMethods.getDriverEarnings(context);
    AssistantMethods.readRetrieveKeysForOnLineDrivers(context);

  }


  @override
  Widget build(BuildContext context) {

    String totalEarning = Provider.of<AppData>(context).totalEarning != null
        ? Provider.of<AppData>(context).totalEarning!
        : "0";

    List<TripsHistoryModelD>? listTripHistoryD = Provider.of<AppData>(context).listTripHistoryD != null
        ? Provider.of<AppData>(context).listTripHistoryD!
        : [];

    NumberFormat formatter = NumberFormat.decimalPatternDigits(
      locale: 'en_us',
      decimalDigits: 0,
    );

    return Container(
      color: Colors.grey,
      child: Column(
        children: [
          Container(
            color: Colors.black,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: Column(
                children: [
                  Text(
                    "Tus Ganancias",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20
                    ),
                  )
                  ,SizedBox(
                    height: 10,
                  ),
                  Text(
                    "COP ${formatter.format(double.parse(totalEarning))}",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 40,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 2,
          ),
          ElevatedButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (c) => TripsHistoryScreen()));
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.white54,
              minimumSize: Size(double.infinity, 70)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              children: [
                Image.asset(
                  "images/car_logo.png",
                  width: 100,
                  alignment: Alignment.centerLeft,
                ),
                Text(
                    "Total de Viaje Completados",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                    )
                ),
                Expanded(
                  child: Text(
                    "${listTripHistoryD.length}",
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),

              ],
            )
          )
        ],
      ),
    );

  }
}
