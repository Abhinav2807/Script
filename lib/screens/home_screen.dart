import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:script/providers/userProvider.dart';
import 'package:script/screens/bottomNavigationScreens/dashboard/dashboard.dart';

import 'package:script/screens/bottomNavigationScreens/profile.dart';
import 'package:script/screens/settingsScreen/settingsScreen.dart';

import 'articleCreation&Viewing/TitleScreen.dart';
import 'bottomNavigationScreens/explore/explore.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HomeState();
  }
}

class HomeState extends State<HomeScreen> {
  int selectedIdx = 0;

  PageController _myPage = PageController(initialPage: 0);

  List<String> tabNames = ["Script", "Explore", "Tasks", "Profile"];
  List<dynamic> tagsList = [
    "Architecture",
    "Art & Culture",
    "Athletics",
    "Business & Work",
    "Covid19",
    "Fashion",
    "Food & Drinks",
    "Health & Wellness",
    "History",
    "Movies",
    "Nature",
    "People",
    "Spirituality",
    "Tech",
    "Travel"
  ];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    var userTags = Provider.of<userProvider>(context).userTags;
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        // centerTitle: true,
        title: Text(tabNames[selectedIdx]),
        actions: <Widget>[
          selectedIdx < 2
              ? IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          )
              : SizedBox(),
          selectedIdx < 3
              ? IconButton(
            icon: Icon(
              Icons.notifications,
              color: Colors.white,
            ),
            onPressed: () {},
          )
              : IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(SettingsScreen.routeName);
              }),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.edit,
          color: Theme.of(context).primaryColor,
        ),
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context).pushNamed(TitleScreen.routeName);
        },
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 5,
        shape: CircularNotchedRectangle(),
        color: Theme.of(context).primaryColor,
        child: Container(
          height: 65,
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                iconSize: 30.0,
                icon: Icon(
                  Icons.dashboard,
                  color: selectedIdx == 0 ? Colors.amber : Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _myPage.jumpToPage(0);
                    selectedIdx = 0;
                  });
                },
              ),
              IconButton(
                iconSize: 30.0,
                icon: Icon(
                  Icons.explore,
                  color: selectedIdx == 1 ? Colors.amber : Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _myPage.jumpToPage(1);
                    selectedIdx = 1;
                  });
                },
              ),
              SizedBox(width: 30),
              IconButton(
                iconSize: 30.0,
                icon: Icon(
                  Icons.check_circle,
                  color: selectedIdx == 2 ? Colors.amber : Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _myPage.jumpToPage(2);
                    selectedIdx = 2;
                  });
                },
              ),
              IconButton(
                iconSize: 30.0,
                icon: Icon(
                  Icons.account_circle,
                  color: selectedIdx == 3 ? Colors.amber : Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _myPage.jumpToPage(3);
                    selectedIdx = 3;
                  });
                },
              )
            ],
          ),
        ),
      ),
      body: PageView(

        controller: _myPage,
        onPageChanged: (int) {
          print('Page Changes to index $int');
          setState(() {
            selectedIdx = int;
          });
        },
        children: <Widget>[


          Dashboard(height: height, tagsList: tagsList, userTags: userTags),
          Explore(),
          Center(
            child: Container(
              child: Text('Tasks'),
            ),
          ),
          ProfileScreen(),
        ],
        physics:
        NeverScrollableScrollPhysics(), // Comment this if you need to use Swipe.
      ),
    );
  }
}
