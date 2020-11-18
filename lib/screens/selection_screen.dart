import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:script/providers/articles_list.dart';
import 'package:script/providers/authorization.dart';
import 'package:script/providers/userProvider.dart';
import 'package:script/screens/home_screen.dart';
import 'package:script/screens/userDetails&tags/user_details_screen.dart';

class SelectScreen extends StatelessWidget {
  static const routeName = '/select-screen';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: FutureBuilder(
        future: Provider.of<Authenticate>(context, listen: false)
            .hasUserDetails(Provider.of<userProvider>(context, listen: false)),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : snapshot.data
                    ? HomeScreen()
                    : userDetails(),
      ),
    );
  }
}
