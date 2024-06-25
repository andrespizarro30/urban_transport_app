import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          Container(
            height: 230,
            child: Center(
              child: Image.asset("images/car_logo.png"),
            ),
          ),
          Text(
            "Transport App Pereira",
            style: TextStyle(
                fontSize: 50,
                color: Colors.white,
                fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Expanded(
            child: Text(
              "Desarrollado por AF Software Solutions",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.italic
              ),
            ),
          ),
          SizedBox(
            height: 30.0,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white54,
                  elevation: 0,
                  minimumSize: Size(100, 50)
              ),
              child: Text(
                "Cerrar",
                style: TextStyle(
                    color: Colors.black
                ),
              )
          )
        ],
      ),
    );

  }
}
