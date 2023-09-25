import 'package:flutter/material.dart';
import 'package:urban_transport_app/ZDriveApp/Screens/tab_pages/earing_tab.dart';
import 'package:urban_transport_app/ZDriveApp/Screens/tab_pages/home_tab.dart';
import 'package:urban_transport_app/ZDriveApp/Screens/tab_pages/profile_tab.dart';
import 'package:urban_transport_app/ZDriveApp/Screens/tab_pages/rating_tab.dart';

class D_MainScreen extends StatefulWidget {
  const D_MainScreen({super.key});

  @override
  State<D_MainScreen> createState() => _D_MainScreenState();
}

class _D_MainScreenState extends State<D_MainScreen> with SingleTickerProviderStateMixin{

  TabController? tabController;
  int selectedIndex = 0;

  onItemClicked(int index){
    setState(() {
      selectedIndex = index;
      tabController!.index = selectedIndex;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tabController = TabController(length: 4,vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: tabController,
        physics: NeverScrollableScrollPhysics(),
        children:  const [
          HomeTabPage(),
          EaringTabPage(),
          RatingTabPage(),
          ProfileTabPage()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card),
              label: "Earing"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label: "Rating"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Account"
          )
        ],
        unselectedItemColor: Colors.amber,
        selectedItemColor: Colors.white,
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 14),
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),
    );
  }
}
