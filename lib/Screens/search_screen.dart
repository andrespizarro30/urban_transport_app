import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:urban_transport_app/AllWidgets/progressDialog.dart';
import 'package:urban_transport_app/DataHandler/appData.dart';
import 'package:urban_transport_app/assistants/assistantMethods.dart';
import 'package:urban_transport_app/model/places_class.dart';
import 'package:urban_transport_app/model/places_info_class.dart';

import '../model/address.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  TextEditingController pickupTEC = TextEditingController();
  TextEditingController dropOffTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {

    Address? address = Provider.of<AppData>(context).address != null
      ? Provider.of<AppData>(context).address!
      : null;

    if(address != null){
      pickupTEC.text = address!.placeName!;
    }

    List<Predictions>? predictions = Provider.of<AppData>(context).predictions != null
        ? Provider.of<AppData>(context).predictions!
        : [];

    return Scaffold(
      body:Column(
        children: [
          Container(
            height: 215.0,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 6.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7,0.7)
                )
              ]
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 25.0,top: 20.0, right: 25.0, bottom: 20.0),
              child: Column(
                children: [
                  SizedBox(height: 30.0,),
                  Stack(
                    children: [
                      GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.arrow_back)
                      ),
                      Center(
                        child: Text(
                          "Establecer ruta",
                          style: TextStyle(fontSize: 18.0,fontFamily: "Brand-Bold"),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 16.0,),
                  Row(
                    children: [
                      Image.asset("images/pickicon.png",height: 16.0,width: 16.0,),
                      SizedBox(width: 18.0,),
                      Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(5.0)
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(3.0),
                              child: TextField(
                                controller: pickupTEC,
                                decoration: InputDecoration(
                                  hintText: "Dirección de recogida",
                                  fillColor: Colors.grey[400],
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(left: 11.0,top: 5.0,bottom: 0.0)
                                ),
                              ),
                            ),
                          )
                      )
                    ],
                  ),
                  SizedBox(height: 10.0,),
                  Row(
                    children: [
                      GestureDetector(
                          onTap:() async {
                            String val = dropOffTEC.text;
                            await AssistantMethods().findPlace(val,context);
                          },
                          child: Image.asset("images/desticon.png",height: 16.0,width: 16.0,)
                      ),
                      SizedBox(width: 18.0,),
                      Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(5.0)
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(3.0),
                              child: TextField(
                                onChanged: (val) async {
                                  //await AssistantMethods().findPlace(val,context);
                                },
                                controller: dropOffTEC,
                                decoration: InputDecoration(
                                    hintText: "A donde vas?",
                                    fillColor: Colors.grey[400],
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(left: 11.0,top: 8.0,bottom: 8.0)
                                ),
                              ),
                            ),
                          )
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 10.0,),
          (predictions!.length>0)
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.0,horizontal: 16.0),
                  child: ListView.separated(
                      padding: EdgeInsets.all(0.0),
                      itemBuilder: (BuildContext context, int index){
                        return PredictionTile(prediction: predictions[index],origAddress: address!);
                      },
                      separatorBuilder: (BuildContext context, int index) => const Divider(),
                      itemCount: predictions.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}

class PredictionTile extends StatelessWidget {

  final Predictions prediction;
  final Address origAddress;

  PredictionTile({Key? key,required this.prediction,required this.origAddress}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    StructuredFormatting structuredFormatting = prediction.structuredFormatting!;

    return TextButton(
      onPressed: (){
        getPlaceAddressDetails(origAddress,prediction,context);
      },
      child: Container(
        child: Column(
          children: [
            SizedBox(width: 10.0,),
            Row(
              children: [
                Icon(Icons.add_location),
                SizedBox(width: 14.0,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(structuredFormatting.mainText!,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 16.0),),
                      SizedBox(height: 3.0,),
                      Text(structuredFormatting.secondaryText!,style: TextStyle(fontSize: 12.0,color: Colors.grey),)
                    ],
                  ),
                )
              ],
            ),
            SizedBox(width: 10.0,)
          ],
        ),
      ),
    );
  }

  Future<void> getPlaceAddressDetails(Address address, Predictions predicition,context) async {

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(message: "Obteniendo Información \nde destino, \npor Favor espere...")
    );

    var res = await AssistantMethods().getPlaceDetails(prediction.placeId!, context);

    Navigator.pop(context);

    if(res?.status == "OK"){
      Provider.of<AppData>(context, listen: false).setPlacesDetails(res!.result!);
      print(res!.result!.formattedAddress!);
      Navigator.pop(context,"obtainDirections");
    }

  }

}

