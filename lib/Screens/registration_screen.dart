import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:urban_transport_app/Utils/commonFunctions.dart';
import 'package:urban_transport_app/ViewModel/backEndHelper.dart';


class RegistrationScreen extends StatefulWidget {

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {

  TextEditingController nameTEC = TextEditingController();
  TextEditingController emailTEC = TextEditingController();
  TextEditingController phoneTEC = TextEditingController();
  TextEditingController passwordTEC = TextEditingController();

  TextEditingController carMakeTEC = TextEditingController();
  TextEditingController carModelTEC = TextEditingController();
  TextEditingController carColorTEC = TextEditingController();
  TextEditingController carPlateTEC = TextEditingController();

  double carDetailsContainerHeight =0.0;

  String? dropdownValue = 'Usuario';
  List<String> spinnerItems = ['Usuario', 'Conductor'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 10.0),
                Image(
                  image: AssetImage("images/logo.png"),
                  width: 150.0,
                  height: 150.0,
                  alignment: Alignment.bottomCenter,
                ),
                SizedBox(height: 15.0,),
                Text(
                  "Registro",
                  style: TextStyle(fontSize: 24.0,fontFamily: "Brand-Bold"),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Column(children: <Widget>[
                        Text(
                          "Tipo de Usuario",
                          style: TextStyle(fontSize: 14.0,color: Colors.black),
                        ),
                        DropdownButton<String>(
                          value: dropdownValue,
                          icon: Icon(Icons.arrow_drop_down),
                          items: spinnerItems.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              dropdownValue = value;
                              (dropdownValue == "Conductor" ? carDetailsContainerHeight = 300.0 : carDetailsContainerHeight = 0.0);
                            });
                          },
                          isExpanded: true,
                        ),
                        if(dropdownValue == 'Usuario')
                          Text('Usuario'),
                        if(dropdownValue == 'Conductor')
                          Text('Conductor'),
                      ]),
                      SizedBox(height: 1.0,),
                      TextField(
                        controller: nameTEC,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: "Nombre",
                            hintText: "Nombre",
                            labelStyle: TextStyle(
                                fontSize: 14.0,
                                fontFamily: "Brand-Bold"
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)
                            ),
                        ),
                        style: TextStyle(fontSize: 14.0,fontFamily: "Brand-Regular"),
                      ),
                      SizedBox(height: 1.0,),
                      TextField(
                        controller: emailTEC,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: "E-Mail",
                            hintText: "E-Mail",
                            labelStyle: TextStyle(
                                fontSize: 14.0,
                                fontFamily: "Brand-Bold"
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)
                            ),
                        ),
                        style: TextStyle(fontSize: 14.0,fontFamily: "Brand-Regular"),
                      ),
                      SizedBox(height: 1.0,),
                      TextField(
                        controller: phoneTEC,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            labelText: "Teléfono",
                            hintText: "Teléfono",
                            labelStyle: TextStyle(
                                fontSize: 14.0,
                                fontFamily: "Brand-Bold"
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)
                            ),
                        ),
                        style: TextStyle(fontSize: 14.0,fontFamily: "Brand-Regular"),
                      ),
                      SizedBox(height: 1.0,),
                      TextField(
                        controller: passwordTEC,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: "Password",
                            hintText: "Password",
                            labelStyle: TextStyle(
                                fontSize: 14.0,
                                fontFamily: "Brand-Bold"
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)
                            ),
                        ),
                        style: TextStyle(fontSize: 14.0,fontFamily: "Brand-Regular"),
                      ),

                      SizedBox(height: 10.0,),

                      Padding(
                          padding: EdgeInsets.all(8.0),
                          child: AnimatedSize(
                            curve: Curves.linear,
                            duration: new Duration(milliseconds: 500),
                            child: Container(
                              height: carDetailsContainerHeight,
                              child: Column(
                                children: [
                                  TextField(
                                    controller: carMakeTEC,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      labelText: "Marca Vehículo",
                                      hintText: "Marca",
                                      labelStyle: TextStyle(
                                          fontSize: 14.0,
                                          fontFamily: "Brand-Bold"
                                      ),
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10.0,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey)
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey)
                                      ),
                                    ),
                                    style: TextStyle(fontSize: 14.0,fontFamily: "Brand-Regular"),
                                  ),
                                  SizedBox(height: 10.0,),
                                  TextField(
                                    controller: carModelTEC,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      labelText: "Modelo Vehículo",
                                      hintText: "Modelo",
                                      labelStyle: TextStyle(
                                          fontSize: 14.0,
                                          fontFamily: "Brand-Bold"
                                      ),
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10.0,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey)
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey)
                                      ),
                                    ),
                                    style: TextStyle(fontSize: 14.0,fontFamily: "Brand-Regular"),
                                  ),
                                  SizedBox(height: 10.0,),
                                  TextField(
                                    controller: carColorTEC,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      labelText: "Color Vehículo",
                                      hintText: "Color",
                                      labelStyle: TextStyle(
                                          fontSize: 14.0,
                                          fontFamily: "Brand-Bold"
                                      ),
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10.0,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey)
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey)
                                      ),
                                    ),
                                    style: TextStyle(fontSize: 14.0,fontFamily: "Brand-Regular"),
                                  ),
                                  SizedBox(height: 10.0,),
                                  TextField(
                                    controller: carPlateTEC,
                                    keyboardType: TextInputType.text,
                                    textCapitalization: TextCapitalization.characters,
                                    onChanged: (String text){
                                      (text.length==3 && !text.contains("-") ?
                                      carPlateTEC.text = carPlateTEC.text + "-" :
                                      carPlateTEC.text);

                                      (text.length==4 && text.contains("-") ?
                                      carPlateTEC.text = carPlateTEC.text.substring(0,3) :
                                      carPlateTEC.text);

                                      (text.length==6 && !text.contains("-") ?
                                      carPlateTEC.text = carPlateTEC.text.substring(0,3) + "-" + carPlateTEC.text.substring(3,6) :
                                      carPlateTEC.text);
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'[A-Z,0-9,-]')),
                                      LengthLimitingTextInputFormatter(7)
                                    ],
                                    decoration: InputDecoration(
                                      labelText: "Placa Vehículo",
                                      hintText: "ABC-123",
                                      labelStyle: TextStyle(
                                          fontSize: 14.0,
                                          fontFamily: "Brand-Bold"
                                      ),
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10.0,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey)
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey)
                                      ),
                                    ),
                                    style: TextStyle(fontSize: 16.0,fontFamily: "Brand-Regular"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ),
                      ElevatedButton(
                        child: Container(
                          height: 50.0,
                          child: Center(
                            child: Text(
                              "Crear Cuenta",
                              style: TextStyle(fontSize: 18.0,fontFamily: "Brand-Bold"),
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.yellow,
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(24.0)
                            )
                        ),
                        onPressed: () {
                          if(nameTEC.text.length < 4){
                            displayToastMessages("Nombre debe ser mayor a 4 caracteres",context);
                          }else
                          if(!emailTEC.text.isValidEmail()){
                            displayToastMessages("Ingrese un E-mail válido",context);
                          }else
                          if(phoneTEC.text.length < 10){
                            displayToastMessages("Ingrese un Número de Teléfono Válido",context);
                          }else
                          if(passwordTEC.text.length < 6){
                            displayToastMessages("Password debe tener al menos 6 caracteres",context);
                          }else{
                            if(dropdownValue=="Conductor"){
                              if(carMakeTEC.text.length < 3){
                                displayToastMessages("Ingrese una Marca Valida",context);
                              }else
                              if(carModelTEC.text.length < 3){
                                displayToastMessages("Ingrese un Modelo Valido",context);
                              }else
                              if(carColorTEC.text.length < 3){
                                displayToastMessages("Ingrese un Color Válido",context);
                              }else
                              if(carPlateTEC.text.length < 7){
                                displayToastMessages("Ingrese una Placa Válida",context);
                              }else{
                                registerNewDriver(context,nameTEC.text,emailTEC.text,phoneTEC.text,passwordTEC.text,dropdownValue!,carMakeTEC.text,carModelTEC.text,carColorTEC.text,carPlateTEC.text);
                              }
                            }else
                            if(dropdownValue=="Usuario"){
                              registerNewUser(context,nameTEC.text,emailTEC.text,phoneTEC.text,passwordTEC.text,dropdownValue!);
                            }
                          }
                        },
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10.0,),
                TextButton(
                  onPressed: (){
                    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
                  },
                  child: Text(
                    "Ya tienes una cuenta?... Ingrese Aquí...",
                    style: TextStyle(fontSize: 12.0,fontFamily: "Brand-Bold"),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                    backgroundColor: Colors.white,
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}
