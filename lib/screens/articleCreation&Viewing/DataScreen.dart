import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:script/helper/ImageDelegate.dart';
import 'package:script/providers/articles_list.dart';
import 'package:script/providers/authorization.dart';
import 'package:script/providers/userProvider.dart';
import 'package:zefyr/zefyr.dart';

import '../home_screen.dart';

class DataScreen extends StatefulWidget {
  static const routeName = '/data-screen';

  @override
  State<StatefulWidget> createState() {
    return DataState();
  }
}

class DataState extends State<DataScreen> {
  ZefyrController controller = new ZefyrController(NotusDocument());
  FocusNode nn = new FocusNode();
  String title;
  String subtitle;
  bool update = false;
  String id = "";
  List<dynamic> tags = [];
  
  @override
  void didChangeDependencies() {
    dynamic argument = ModalRoute.of(context).settings.arguments;
    if (argument.containsKey('id')) {
      controller = new ZefyrController(argument['data']);
      title = argument['title'];
      id = argument['id'];
      tags = argument['tags'];
      update = true;
    } else {
      tags = argument['tags'];
      title = argument['title'];
    }
    subtitle = argument['subtitle'];
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Builder(
            builder: (context) => FlatButton(
                onPressed: () async {
                  FirebaseUser user =
                      await Provider.of<Authenticate>(context, listen: false)
                          .getCurrentUser();
                  if (controller.document.length > 3) {
                    log(controller.document.toString());
                    if (update) {
                      Provider.of<ArticleList>(context, listen: false)
                          .update(id, title, controller.document, tags);
                    } else {
                      Provider.of<ArticleList>(context, listen: false)
                          .addArticle(
                              title,
                              subtitle,
                              controller.document,
                              user,
                              tags,
                              Provider.of<userProvider>(context,
                                  listen: false));
                    }

                   Navigator.of(context).pushNamedAndRemoveUntil(
                  HomeScreen.routeName, (Route<dynamic> route) => false);
                  } else {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.black87,
                        content: Text('Please Write Something to Post!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: Text(
                  "Done",
                  style: TextStyle(color: Colors.white, fontSize: 17),
                )),
          )
        ],
      ),
      body: ZefyrScaffold(
        child: ZefyrEditor(
          imageDelegate: MyAppZefyrImageDelegate(title),
          autofocus: true,
          controller: controller,
          focusNode: nn,
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
        ),
      ),
    );
  }
}
