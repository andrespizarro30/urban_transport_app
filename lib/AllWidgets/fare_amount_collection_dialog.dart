import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class FareAmountCollectionDialog extends StatefulWidget {

  String userType;
  int totalFareAmount;

  FareAmountCollectionDialog({required this.totalFareAmount, required this.userType});

  @override
  State<FareAmountCollectionDialog> createState() => _FareAmountCollectionDialogState();
}

class _FareAmountCollectionDialogState extends State<FareAmountCollectionDialog> {

  NumberFormat formatter = NumberFormat.decimalPatternDigits(
    locale: 'en_us',
    decimalDigits: 0,
  );

  String bodyText = "";
  String btnText = "";


  @override
  Widget build(BuildContext context) {

    if(widget.userType == "Usuario"){
      bodyText="A Pagar del Valor Total del Viaje";
      btnText="Pagar";
    }else
    if(widget.userType == "Conductor"){
      bodyText="A Cobrar del Valor Total del Viaje";
      btnText="Cobrar";
    }


    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14)
      ),
      backgroundColor: Colors.white,
      child: Container(
        margin: const EdgeInsets.all(6),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20,),
            Text(
              "Tarifa Total del Viaje",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16
              ),
            ),
            const SizedBox(height: 20,),
            Divider(
              thickness: 4,
              color: Colors.grey,
            ),
            const SizedBox(height: 16,),
            Text(
                "COP ${formatter.format(widget.totalFareAmount)}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 50
              ),
            ),
            const SizedBox(height: 10,),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                bodyText.toUpperCase(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
              ),
            ),
            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.all(18),
              child: ElevatedButton(
                  onPressed: (){
                    if(widget.userType == "Usuario"){
                      Navigator.pop(context,"cashPaid");
                    }else
                    if(widget.userType == "Conductor"){
                      Future.delayed(const Duration(microseconds: 2000),(){
                        SystemNavigator.pop();
                      });
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        btnText!.toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20
                        ),
                      ),
                      Icon(
                        Icons.attach_money,
                        color: Colors.white,
                        size: 28,
                      ),
                      Text(
                        "${formatter.format(widget.totalFareAmount)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20
                        ),
                      )
                    ],
                  ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.green
                ),
              ),
            ),

            SizedBox(height: 4,)
          ],
        ),
      ),
    );
  }
}
