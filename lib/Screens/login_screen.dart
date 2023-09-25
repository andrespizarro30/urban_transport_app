import 'package:flutter/material.dart';
import 'package:urban_transport_app/ViewModel/backEndHelper.dart';

import '../Utils/commonFunctions.dart';


class LoginScreen extends StatelessWidget {

  TextEditingController emailTEC = TextEditingController();
  TextEditingController passwordTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Bienvenido a Transportes Pereira"),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 20.0),
              Image(
                  image: AssetImage("images/logo.png"),
                  width: 250.0,
                  height: 250.0,
                  alignment: Alignment.bottomCenter,
              ),
              SizedBox(height: 15.0,),
              Text(
                "Login",
                style: TextStyle(fontSize: 24.0,fontFamily: "Brand-Bold"),
                textAlign: TextAlign.center,
              ),
              Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      SizedBox(height: 1.0,),
                      TextField(
                        controller: emailTEC,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: "E-Mail",
                            labelStyle: TextStyle(
                                fontSize: 14.0,
                                fontFamily: "Brand-Bold"
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )
                        ),
                        style: TextStyle(fontSize: 14.0,fontFamily: "Brand-Regular"),
                      ),
                      SizedBox(height: 1.0,),
                      TextField(
                        controller: passwordTEC,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: TextStyle(
                                fontSize: 14.0,
                                fontFamily: "Brand-Bold"
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )
                        ),
                        style: TextStyle(fontSize: 14.0,fontFamily: "Brand-Regular"),
                      ),
                      SizedBox(height: 10.0,),
                      ElevatedButton(
                          child: Container(
                            height: 50.0,
                            child: Center(
                              child: Text(
                                  "Login",
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
                            if(!emailTEC.text.isValidEmail()){
                              displayToastMessages("Ingrese un E-mail válido",context);
                            }else
                            if(passwordTEC.text.length < 6){
                              displayToastMessages("Password debe tener al menos 6 caracteres",context);
                            }else{
                              loginAuthenticateUser(context, emailTEC.text, passwordTEC.text);
                            }
                          },
                      )
                    ],
                  ),
              ),
              SizedBox(height: 10.0,),
              TextButton(
                  onPressed: (){
                    Navigator.pushNamedAndRemoveUntil(context, 'register', (route) => false);
                  },
                  child: Text(
                      "No está registrado??... Regístrese Aquí!!",
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

