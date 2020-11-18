import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:script/providers/articles_list.dart';
import 'package:script/screens/articleCreation&Viewing/ShowArticle.dart';
import 'package:script/screens/bottomNavigationScreens/dashboard/dashboard.dart';
import 'package:zefyr/zefyr.dart';

class TagArticles extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return TagState();
  }
}

class TagState extends State<TagArticles> {
  var args;

  Firestore _firestore = Firestore.instance;
  List<DocumentSnapshot> _articles = [];
  bool _loadingProducts = true;
  int _per_page = 10;
  DocumentSnapshot _lastDocument;
  ScrollController _scrollController = ScrollController();
  bool _gettingMoreProducts = false;
  bool _moreProductsAvailable = true;

  _getArticles() async {
    Query q = _firestore
        .collection('Articles')
        .where('tags', arrayContains: args)
        .orderBy('dateTime', descending: true)
        .limit(_per_page);
    setState(() {
      _loadingProducts = true;
    });
    QuerySnapshot querySnapshot = await q.getDocuments();

    _articles = querySnapshot.documents;
    if (querySnapshot.documents.length == 0) {
      setState(() {
        _loadingProducts = false;
      });
      return;
    }
    _lastDocument = querySnapshot.documents[querySnapshot.documents.length - 1];
    setState(() {
      _loadingProducts = false;
    });
  }

  _getMoreArticles() async {
    print("Getting Products");
    if (_moreProductsAvailable == false) {
      print("No More Articles");
      return;
    }
    if (_gettingMoreProducts == true) {
      return;
    }
    _gettingMoreProducts = true;
    Query q = _firestore
        .collection('Articles')
        .where('tags', arrayContains: args)
        .orderBy('dateTime', descending: true)
//        .orderBy("dateTime")
        .startAfterDocument(_lastDocument)
        .limit(_per_page);

    QuerySnapshot querySnapshot = await q.getDocuments();

    if (querySnapshot.documents.length == 0) {
      _moreProductsAvailable = false;
    }

    _lastDocument = querySnapshot.documents[querySnapshot.documents.length - 1];

    _articles.addAll(querySnapshot.documents);
    _gettingMoreProducts = false;
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    args = ModalRoute.of(context).settings.arguments;
    _getArticles();

    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;

      if (maxScroll - currentScroll <= delta) {
        _getMoreArticles();
      }
    });
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(args),
      ),
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: <Widget>[
          _loadingProducts == true
              ? SliverToBoxAdapter(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: height * .3,
                      ),
                      Center(
                        child: CircularProgressIndicator(),
                      ),
                    ],
                  ),
                )
              : _articles.length == 0
                  ? SliverToBoxAdapter(
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: height * .3),
                          Center(
                            child: Text(
                              "Oops no Articles to view !",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, index) {
                          return Column(
                            children: <Widget>[
                              (index % 4 == 0 && index != 0)
                                  ? Text("Ads")
                                  : SizedBox(),
                              InkWell(
                                onTap: () {
                                  DateTime date = DateTime.parse(
                                      _articles[index].data['dateTime']);
                                  DateTime now = DateTime.now();
                                  int days =
                                      DateTime(date.year, date.month, date.day)
                                          .difference(DateTime(
                                              now.year, now.month, now.day))
                                          .inDays;
                                  Navigator.of(context).pushNamed(
                                    ShowArticle.routeName,
                                    arguments: Article(
                                      id: _articles[index].data['id'],
                                      title: _articles[index].data['title'],
                                      data: NotusDocument.fromJson(
                                        json.decode(
                                            _articles[index].data['data']),
                                      ),
                                      tags: _articles[index].data['tags'],
                                      date: days == 0
                                          ? "Today"
                                          : days > -2 && days < 0
                                              ? (-days).toString() + " days ago"
                                              : DateFormat.yMMMd().format(date),
                                      views: _articles[index]
                                                  .data['views']
                                                  .runtimeType ==
                                              int
                                          ? []
                                          : _articles[index].data['views'] ??
                                              [],
                                      likes:
                                          _articles[index].data['likes'] ?? [],
                                      subtitle:
                                          _articles[index].data['subtitle'] ??
                                              " ",
                                      userId: _articles[index].data['author'],
                                      authorBio:
                                          _articles[index].data['authorBio'],
                                      authorDp: _articles[index]
                                                  .data['authorDP']
                                                  .length ==
                                              0
                                          ? null
                                          : _articles[index].data['authorDP'],
                                      authorName:
                                          _articles[index].data['authorName'],
                                    ),
                                  );
                                },
                                child: ArticleCard(
                                  height: MediaQuery.of(ctx).size.height,
                                  snap: _articles[index].data,
                                ),
                              ),
                            ],
                          );
                        },
                        childCount: _articles.length,
                      ),
                    ),
          _articles.length > 0
              ? SliverToBoxAdapter(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: height * .05,
                      ),
                      Text(
                        "Thats all folks !",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: height * .05,
                      )
                    ],
                  ),
                )
              : SliverToBoxAdapter()
        ],
      ),
    );
  }
}
