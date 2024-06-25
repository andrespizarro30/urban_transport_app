import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../AllWidgets/user_info_design_ui.dart';
import '../../../Utils/configMaps.dart';
import '../../../main.dart';

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({super.key});

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              (firebaseAuth.currentUser!.displayName == "Usuario" ? currentUserInfo!.name! : currentDriverInfo!.name!),
              style: TextStyle(
                  fontSize: 50.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(
              height: 20,
              width: 200,
              child: Divider(
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 38.0,
            ),
            UserInfoDesignUI(
              textInfo: (firebaseAuth.currentUser!.displayName == "Usuario" ? currentUserInfo!.phone! : currentDriverInfo!.phone!),
              iconData: Icons.phone_android,
            ),
            UserInfoDesignUI(
              textInfo: (firebaseAuth.currentUser!.displayName == "Usuario" ? currentUserInfo!.email! : currentDriverInfo!.email!),
              iconData: Icons.email,
            ),
            SizedBox(
              height: 40,
              width: 200,
              child: Divider(
                color: Colors.white,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white54,
                  elevation: 0,
                  minimumSize: Size(200, 50)
              ),
              child: Text("Sign out"),
            ),
          ],
        ),
      ),
    );

  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}
