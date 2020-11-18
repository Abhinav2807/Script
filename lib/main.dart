import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:script/providers/articles_list.dart';
import 'package:script/providers/authorization.dart';
import 'package:script/providers/userProvider.dart';
import 'package:script/screens/AuthScreen.dart';
import 'package:script/screens/articleCreation&Viewing/AuthorDetails.dart';
import 'package:script/screens/articleCreation&Viewing/DataScreen.dart';
import 'package:script/screens/articleCreation&Viewing/ShowArticle.dart';
import 'package:script/screens/articleCreation&Viewing/TitleScreen.dart';
import 'package:script/screens/bottomNavigationScreens/dashboard/viewAllTags.dart';
import 'package:script/screens/bottomNavigationScreens/explore/tagArticle.dart';

import 'package:script/screens/home_screen.dart';
import 'package:script/screens/selection_screen.dart';
import 'package:script/screens/settingsScreen/account.dart';
import 'package:script/screens/settingsScreen/settingsScreen.dart';
import 'package:script/screens/userDetails&tags/tagsChoice.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Authenticate()),
        ChangeNotifierProvider.value(value: ArticleList()),
        ChangeNotifierProvider.value(value: userProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
            textTheme: TextTheme(
                title: TextStyle(
              color: Colors.black,
            )),
            appBarTheme: AppBarTheme(
              textTheme: TextTheme(
                title: TextStyle(
                    // fontWeight: FontWeight.bold,
                    fontFamily: "Poppins",
                    fontSize: 22),
              ),
            ),
            primarySwatch: Colors.grey,
            primaryColor: Colors.black,
            fontFamily: "Poppins"),
        home: Consumer<Authenticate>(
          builder: (ctx, auth, _) => StreamBuilder<FirebaseUser>(
            stream: auth.getStream(),
            builder: (context, snapshot) =>
                snapshot.connectionState == ConnectionState.waiting
                    ? Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : snapshot.hasData ? SelectScreen() : AuthScreen(),
          ),
        ),
        routes: {
          HomeScreen.routeName: (ctx) => HomeScreen(),
          TitleScreen.routeName: (ctx) => TitleScreen(),
          DataScreen.routeName: (ctx) => DataScreen(),
          ShowArticle.routeName: (ctx) => ShowArticle(),
          SettingsScreen.routeName: (ctx) => SettingsScreen(),
          TagsChoice.routeName: (ctx) => TagsChoice(),
          Account.routeName: (ctx) => Account(),
          ViewAllTags.routeName: (ctx) => ViewAllTags(),
          SelectScreen.routeName: (ctx) => SelectScreen(),
          '/tagArticle': (ctx)=> TagArticles(),
          '/authorDetails': (ctx)=> AuthorDetails(),
        },
      ),
    );
  }
}
