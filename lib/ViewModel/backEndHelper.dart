import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_transport_app/AllWidgets/progressDialog.dart';
import 'package:urban_transport_app/Utils/commonFunctions.dart';
import 'package:urban_transport_app/main.dart';
import 'package:urban_transport_app/model/drivers_class.dart';
import 'package:urban_transport_app/model/fares_class.dart';
import 'package:urban_transport_app/model/users_class.dart';

import '../DataHandler/appData.dart';
import '../Utils/configMaps.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

void registerNewUser(BuildContext context,String name,String email,String phone,String password,String userType) async {

  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return ProgressDialog(message: "Registrando Usuario, \npor favor espere...",);
      }
  );

  final User? firebaseUser = (await _firebaseAuth
      .createUserWithEmailAndPassword(email: email, password: password)
      .catchError((errorMsg){
        Navigator.pop(context);
        displayToastMessages(errorMsg, context);
  })).user;

  if(firebaseUser != null){

    Map<String,String> userAppMap = {
      "name": name,
      "email": email,
      "phone": phone,
      "password": password,
      "usertype": userType
    };

    firebaseUser.updateDisplayName(userType);

    userRef.child(firebaseUser.uid).set(userAppMap);

    displayToastMessages("Cuenta creada exitosamente", context);

    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);

  }else{
    Navigator.pop(context);
    displayToastMessages("Nuevo usuario no pudo ser creado, intente de nuevo o contacte al admin.", context);
  }

}

void registerNewDriver(
    BuildContext context,
    String name,
    String email,
    String phone,
    String password,
    String userType,
    String carMake,
    String carModel,
    String carColor,
    String carPlate
    ) async {

  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return ProgressDialog(message: "Registrando Conductor, \npor favor espere...",);
      }
  );

  final User? firebaseUser = (await _firebaseAuth
      .createUserWithEmailAndPassword(email: email, password: password)
      .catchError((errorMsg){
    Navigator.pop(context);
    displayToastMessages(errorMsg, context);
  })).user;

  if(firebaseUser != null){

    Map<String,String> driverAppMap = {
      "name": name,
      "email": email,
      "phone": phone,
      "password": password,
      "usertype": userType,
      "carMake": carMake,
      "carModel": carModel,
      "carColor": carColor,
      "carPlate": carPlate
    };

    firebaseUser.updateDisplayName(userType);

    driverRef.child(firebaseUser.uid).set(driverAppMap);

    displayToastMessages("Cuenta creada exitosamente", context);

    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);

  }else{
    Navigator.pop(context);
    displayToastMessages("Nuevo usuario no pudo ser creado, intente de nuevo o contacte al admin.", context);
  }

}

void loginAuthenticateUser(BuildContext context,String email,String password) async{

  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return ProgressDialog(message: "Autenticando, \npor favor espere...",);
      }
  );

  final User? firebaseUser = (await _firebaseAuth
      .signInWithEmailAndPassword(
      email: email,
      password: password
  ).catchError((errorMsg){
    Navigator.pop(context);
    displayToastMessages("Error: ${errorMsg.toString()}", context);
  })).user;

  if(firebaseUser != null){

    DataSnapshot? snapshot;

    if(firebaseUser.displayName=="Usuario"){
      snapshot = await userRef.child(firebaseUser.uid).get();
    }else
    if(firebaseUser.displayName=="Conductor"){
      snapshot = await driverRef.child(firebaseUser.uid).get();
    }

    if (snapshot!.exists) {

      Navigator.pushNamedAndRemoveUntil(context, (firebaseUser.displayName == "Usuario" ? 'main' : 'd_main'), (route) => false);

      Map valueMap = snapshot.value as Map;

      displayToastMessages("Bienvenido a tu App, ${valueMap["name"].toString()}!!!", context);

    } else {
      Navigator.pop(context);
      displayToastMessages("Sin registro actual, solicite crear usuario", context);
    }

  }

}

void getFaresValues(context) async{

  final snapshot = await faresRef.get();

  Map valueMap = snapshot.value as Map;

  Fares fares = Fares(valueKm: double.parse(valueMap["kilometer"].toString()),valueMin: double.parse(valueMap["minute"].toString()));

  Provider.of<AppData>(context, listen: false).getFaresValues(fares);

}

void getCurrentOnlineUserInfo() async{

  firebaseUser = await FirebaseAuth.instance.currentUser;

  String userId = firebaseUser!.uid;

  if(firebaseUser!.displayName=="Usuario"){
    DatabaseReference reference = userRef.child(userId);
    reference.once().then((DatabaseEvent databaseEvent){
      currentUserInfo = Users.fromSnapshot(databaseEvent.snapshot);
    });
  }else
  if(firebaseUser!.displayName=="Conductor"){
    DatabaseReference reference = driverRef.child(userId);
    await reference.once().then((DatabaseEvent databaseEvent){
      if(databaseEvent.snapshot != null){
        currentDriverInfo = Drivers.fromSnapshot(databaseEvent.snapshot);
      }
    });
  }



}
