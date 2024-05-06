import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:urban_transport_app/AllWidgets/history_d_design_ui.dart';
import 'package:urban_transport_app/AllWidgets/history_design_ui.dart';
import 'package:urban_transport_app/DataHandler/appData.dart';
import 'package:urban_transport_app/assistants/assistantMethods.dart';

import '../main.dart';
import '../model/history_trip_model.dart';

class TripsHistoryScreen extends StatefulWidget {

  @override
  State<TripsHistoryScreen> createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen> {

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    if(firebaseAuth.currentUser!.displayName! == "Usuario"){
      AssistantMethods.readRetrieveKeysForOnLineUser(context);
    }else
    if(firebaseAuth.currentUser!.displayName! == "Conductor"){
      //AssistantMethods.readRetrieveKeysForOnLineDrivers(context);
    }
  }

  @override
  Widget build(BuildContext context) {

    List<TripsHistoryModel>? listTripHistory;
    List<TripsHistoryModelD>? listTripHistoryD;

    if(firebaseAuth.currentUser!.displayName! == "Usuario"){
      listTripHistory = Provider.of<AppData>(context).listTripHistory != null
          ? Provider.of<AppData>(context).listTripHistory!
          : [];
    }else
    if(firebaseAuth.currentUser!.displayName! == "Conductor"){
      listTripHistoryD = Provider.of<AppData>(context).listTripHistoryD != null
          ? Provider.of<AppData>(context).listTripHistoryD!
          : [];
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Historial de Viajes",
          style: TextStyle(
            color: Colors.white
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.separated(
          separatorBuilder: (context, i) => const Divider(
            color: Colors.black,
            thickness: 2,
            height: 2,
          ),
          itemBuilder: (context,i){
            return Card(
              child: (firebaseAuth.currentUser!.displayName! == "Usuario") ?
                HistoryDesignUI(
                  tripHistoryInformation: listTripHistory![i],
                ) :
                HistoryDDesignUI(
                  tripHistoryInformation: listTripHistoryD![i]
                )
              ,
            );
          },
        itemCount: (firebaseAuth.currentUser!.displayName! == "Usuario") ?
                    listTripHistory!.length!:
                    listTripHistoryD!.length,
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
      ),
    );

  }
}
