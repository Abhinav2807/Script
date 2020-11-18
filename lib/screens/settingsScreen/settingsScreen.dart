import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:script/providers/userProvider.dart';
import 'package:script/screens/settingsScreen/account.dart';

import '../../providers/authorization.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = "/SettingsScreen";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Settings",
        ),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(
              "Account",
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.of(context).pushNamed(Account.routeName);
            },
          ),
          Divider(),
          ListTile(
            title: Text(
              "Earning",
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Fluttertoast.showToast(msg: "Full Earnings Page");
            },
          ),
          Divider(),
          ListTile(
            title: Text(
              "Invite",
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Fluttertoast.showToast(msg: "Full Earnings Page");
            },
          ),
          Divider(),
          ListTile(
            title: Text(
              "Watch & Earn",
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Fluttertoast.showToast(msg: "FPlay Interstital Ad");
            },
          ),
          Divider(),
          ListTile(
            title: Text(
              "Membership",
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Fluttertoast.showToast(msg: "Members Page");
            },
          ),
          Divider(),
          ListTile(
            title: Text(
              "Support",
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Fluttertoast.showToast(msg: "Support Page");
            },
          ),
          Divider(),
          
          ListTile(
            title: Text(
              "Logout",
              style: TextStyle(fontSize: 16),
            ),
            onTap: () async {
              Provider.of<userProvider>(context, listen: false).empty();
              await Provider.of<Authenticate>(context, listen: false).logout();
              Navigator.of(context).pop();
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
