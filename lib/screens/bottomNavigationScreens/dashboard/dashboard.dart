import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:provider/provider.dart';
import 'package:script/providers/articles_list.dart';
import 'package:script/providers/authorization.dart';
import 'package:script/providers/userProvider.dart';
import 'package:script/screens/articleCreation&Viewing/ShowArticle.dart';
import 'package:script/screens/bottomNavigationScreens/dashboard/viewAllTags.dart';
import 'package:zefyr/zefyr.dart';

// import '../../providers/articles_list.dart';
// import '../ShowArticle.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({
    Key key,
    @required this.height,
    @required this.tagsList,
    @required this.userTags,
  }) : super(key: key);

  final double height;
  final List<dynamic> tagsList;
  final List<dynamic> userTags;

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with AutomaticKeepAliveClientMixin<Dashboard> {
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
        .where('tags', arrayContainsAny: widget.userTags)
        .orderBy("id")
        .limit(_per_page);
    setState(() {
      _loadingProducts = true;
    });
    QuerySnapshot querySnapshot = await q.getDocuments();
    _articles = querySnapshot.documents;
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
        .where('tags', arrayContainsAny: widget.userTags)
        .orderBy("id")
        .startAfterDocument(_lastDocument)
        .limit(_per_page);

    QuerySnapshot querySnapshot = await q.getDocuments();

    if (querySnapshot.documents.length == 0) {
//      Firestore.instance.collection("").snapshots().
      _moreProductsAvailable = false;
    }

    _lastDocument = querySnapshot.documents[querySnapshot.documents.length - 1];

    _articles.addAll(querySnapshot.documents);
    _gettingMoreProducts = false;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getArticles();

    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;

      if (maxScroll - currentScroll <= delta) {
        _getMoreArticles();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      physics: BouncingScrollPhysics(),
//            shrinkWrap: true,
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 15, left: 15, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Tags you follow",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(ViewAllTags.routeName);
                    setState(() {});
                    // Fluttertoast.showToast(msg: "View All Page to be made");
                  },
                  child: Text(
                    "View all",
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  ),
                )
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            height: widget.height * .12,
            child: ListView.builder(
                itemCount: widget.tagsList.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return widget.userTags.contains(widget.tagsList[index])
                      ? TagsCard(
                          height: widget.height,
                          tagsList: widget.tagsList,
                          index: index,
                        )
                      : SizedBox();
                }),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(bottom: 10, left: 15),
            child: Text(
              "My Feed",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        // PaginationLogic(height: height)
        _loadingProducts == true
            ? SliverToBoxAdapter(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : _articles.length == 0
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Text("No Articles"),
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
                                int days = DateTime(
                                        date.year, date.month, date.day)
                                    .difference(
                                        DateTime(now.year, now.month, now.day))
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
                                        : _articles[index].data['views'] ?? [],
                                    likes: _articles[index].data['likes'] ?? [],
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
                  )
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class TagsCard extends StatelessWidget {
  const TagsCard({
    Key key,
    @required this.height,
    @required this.tagsList,
    @required this.index,
  }) : super(key: key);

  final double height;
  final int index;
  final List<dynamic> tagsList;

  @override
  Widget build(BuildContext context) {
    var width=MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 8, left: 8, right: 2),
      child: Stack(
        children: <Widget>[
          Container(
            width:  width*.4,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5), color: Colors.black),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.asset(
                "assets/images/tags/" +
                    tagsList[index].toLowerCase().replaceAll(" ", "") +
                    ".jpg",
                color: Colors.black54,
                colorBlendMode: BlendMode.darken,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
              ),
              child: Text(
                tagsList[index],
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ArticleCard extends StatefulWidget {
  const ArticleCard({Key key, @required this.height, @required this.snap})
      : super(key: key);

  final double height;
  final Map<String, dynamic> snap;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ArticleState();
  }
}

class ArticleState extends State<ArticleCard> {
  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.parse(widget.snap['dateTime']);
    userProvider user = Provider.of<userProvider>(context, listen: false);
    DateTime now = DateTime.now();
    int days = DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.bottomRight,
          child: IconButton(
            icon: user.bookmarks.contains(widget.snap['id'])
                ? Icon(Icons.bookmark)
                : Icon(Icons.bookmark_border),
            onPressed: () {
              if (user.bookmarks.contains(widget.snap['id'])) {
                user.removeBookmark(widget.snap['id']);
                Fluttertoast.showToast(msg: "Removed from bookmarks");
              } else {
                user.addBookmarks(widget.snap['id']);
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
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          width: double.infinity,
          height: widget.height * .19,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      "assets/images/tags/" +
                          widget.snap['tags'][0]
                              .toLowerCase()
                              .replaceAll(" ", "") +
                          ".jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                  height: widget.height * .19,
                  width: 100,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * .52,
                    child: Text(
                      widget.snap['title'].toString().length < 60
                          ? widget.snap['title'].toString()[0].toUpperCase() +
                              widget.snap['title'].toString().substring(
                                    1,
                                  )
                          : widget.snap['title'].toString()[0].toUpperCase() +
                              widget.snap['title'].toString().substring(1, 54) +
                              " ...",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Spacer(),
                  Row(
                    children: <Widget>[
                      Text(
                        widget.snap['authorName'] ?? "Author Name",
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                          days == 0
                              ? "Today"
                              : days > -2 && days < 0
                                  ? (-days).toString() + " days ago"
                                  : DateFormat.yMMMd().format(date),
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  Text(
                      (widget.snap['data'].toString().length / 1920)
                              .toStringAsFixed(0) +
                          " mins read",
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Row(
                    children: <Widget>[
                      Text(
                          "${widget.snap['views'].runtimeType == int ? 0 : widget.snap['views'].length ?? 0} Views"),
                      SizedBox(
                        width: 10,
                      ),
                      Text("${(widget.snap['likes'] ?? []).length} Votes")
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
