import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:script/helper/ImageDelegate.dart';
import 'package:script/providers/articles_list.dart';
import 'package:script/providers/authorization.dart';
import 'package:script/providers/userProvider.dart';
import 'package:script/screens/articleCreation&Viewing/TitleScreen.dart';

// import 'package:script/screens/edit_screen/TitleScreen.dart';
import 'package:zefyr/zefyr.dart';

import '../home_screen.dart';

// import 'home_screen.dart';

class ShowArticle extends StatefulWidget {
  static const routeName = '/show-article';

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ShowState();
  }
}

class ShowState extends State<ShowArticle> {
  Future<void> addView(Article article) {
    Firestore.instance.collection('Articles').document(article.id).updateData({
      'views': article.views,
    });
  }

  String userId = "";

  Article article;
  bool liked = false;
  bool viewed = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var height =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    var width = MediaQuery.of(context).size.width;

    article = ModalRoute.of(context).settings.arguments as Article;
//    getUser(article);
    userProvider user = Provider.of<userProvider>(context, listen: false);
    if (!article.views.contains(user.id)) {
      article.views.add(user.id);
      addView(article);
    }
    this.liked = article.likes.contains(userId);
    ZefyrController controller = new ZefyrController(article.data);
    print(article.data.length);
    FocusNode nn = new FocusNode();
    // TODO: implement build
    return ZefyrScaffold(
      child:  Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              // Navigator.of(context).pushNamedAndRemoveUntil(
              //     HomeScreen.routeName, (Route<dynamic> route) => false);
              Navigator.of(context).pop();
            }),
        actions: <Widget>[
          Provider.of<userProvider>(context, listen: false)
                  .userArticles
                  .contains(article.id)
              ? IconButton(
                  icon: Icon(Icons.mode_edit),
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(TitleScreen.routeName, arguments: {
                      'id': article.id,
                      'title': article.title,
                      'data': article.data,
                      'tags': article.tags,
                      'subtitle': article.subtitle,
                    });
                  },
                )
              : Container(),
          IconButton(
            icon: user.bookmarks.contains(article.id)
                ? Icon(Icons.bookmark)
                : Icon(Icons.bookmark_border),
            onPressed: () {
              if (user.bookmarks.contains(article.id)) {
                user.removeBookmark(article.id);
                Fluttertoast.showToast(msg: "Removed from bookmarks");
              } else {
                user.addBookmarks(article.id);
                Fluttertoast.showToast(msg: "Added to bookmarks");
              }
              setState(() {});
              Provider.of<Authenticate>(context, listen: false)
                  .getCurrentUser()
                  .then((value) => Firestore.instance
                      .collection('users')
                      .document(value.uid)
                      .updateData({'Bookmarks': user.bookmarks}));
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigator.of(context).pushNamedAndRemoveUntil(
          //     HomeScreen.routeName, (Route<dynamic> route) => false);
          Navigator.of(context).pop();
        },
        backgroundColor: Colors.black,
        child: Icon(
          Icons.clear,
          color: Colors.white,
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 10),
              child: Container(
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width * .85,
                child: Text(
                  article.title[0].toUpperCase() +
                      article.title.substring(
                        1,
                      ) +
                      " .",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                '${article.subtitle}',
                textAlign: TextAlign.left,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: height * .02),
          ),
          SliverToBoxAdapter(
            child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: article.tags
                        .map((e) => Container(
                            margin: EdgeInsets.only(right: 10),
                            child: Chip(
                              avatar: CircleAvatar(
                                child: Text(
                                  e[0],
                                  style: TextStyle(fontFamily: "Poppins"),
                                ),
                              ),
                              label: Text(
                                e,
                              ),
                              labelStyle: TextStyle(
                                  color: Colors.black, fontFamily: "Poppins"),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            )))
                        .toList(),
                  ),
                )),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: height * .02),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed('/authorDetails', arguments: article.userId);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        height: height * 0.07,
                        width: height * 0.07,
                        child: article.authorDp == null
                            ? Icon(
                                Icons.account_circle,
                                color: Colors.black,
                                size: 50,
                              )
                            : Image.network(
                                article.authorDp,
                                fit: BoxFit.cover,
                              )),
                    SizedBox(
                      width: width * .05,
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(article.authorBio),
                          Text(
                            article.authorName,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ])
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                children: <Widget>[
                  Text(
                      (article.data.toString().length / 1920)
                              .toStringAsFixed(0) +
                          " mins read",
                      style: TextStyle(color: Colors.grey, fontSize: 15)),
                  SizedBox(
                    width: 10,
                  ),
                  Text(article.date,
                      style: TextStyle(color: Colors.grey, fontSize: 15)),
                  Spacer(),
                  IconButton(
                      icon: Icon(
                        Icons.thumb_up,
                        color: article.likes.contains(user.id)
                            ? Colors.black
                            : Colors.grey,
                      ),
                      onPressed: () {
                        if (article.likes.contains(user.id)) {
                          article.likes.removeWhere((us) => us == user.id);
                        } else {
                          article.likes.add(user.id);
                        }
                        setState(() {});

                        print('liking: ${user.id}${article.likes}');
                        Firestore.instance
                            .collection('Articles')
                            .document(article.id)
                            .updateData({
                          'likes': article.likes,
                        });
                        print('liked');
                      })
                ],
              ),
            ),
          ),
        ],
//        physics: AlwaysScrollableScrollPhysics(),
        body: SingleChildScrollView(child: Container(

          height: controller.document.length+0.0,
          child: ZefyrEditor(
//              padding: EdgeInsets.only(bottom: 100),
              imageDelegate: MyAppZefyrImageDelegate(article.title),
              mode:
                  ZefyrMode(canEdit: false, canFormat: false, canSelect: true),
              focusNode: nn,
              controller: controller,
              physics: NeverScrollableScrollPhysics(),
            ),
        ),
        ),
        ),
      ),
    );
  }
}
