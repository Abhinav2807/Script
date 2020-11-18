import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:script/providers/articles_list.dart';

// import 'package:script/screens/ShowArticle.dart';
import 'package:script/screens/articleCreation&Viewing/ShowArticle.dart';

// import 'package:script/screens/bottomNavigationScreens/dashboard.dart';
import 'package:script/screens/bottomNavigationScreens/dashboard/dashboard.dart';
import 'package:zefyr/zefyr.dart';

class Explore extends StatefulWidget {
  const Explore({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ExploreState();
  }
}

class ExploreState extends State<Explore> {
  int selectedIdx = 0;
  List<String> tagsList = [
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
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var articleList = Provider.of<ArticleList>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: SizedBox(
              height:height*.02
            )
          ),
          SliverToBoxAdapter(
            child: Container(
              height: height * .13,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                     
                    },
                    child: ExploreSectionWidget(
                      width: width,
                      icon: Icons.whatshot,
                      title: "Featured",
                      selected: selectedIdx == 0,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      
                    },
                    child: ExploreSectionWidget(
                      width: width,
                      icon: Icons.adjust,
                      title: "New",
                      selected: selectedIdx == 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 10, bottom: 10),
              child: Text(
                "Read from the Tags",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ),

          // selectedIdx == 0
          //     ? FutureBuilder(
          //         future: _getArticles("views", true),
          //         builder: (ctx, snap) {
          //           if (snap.connectionState == ConnectionState.waiting)
          //             return SliverToBoxAdapter(
          //               child: Center(
          //                 child: CircularProgressIndicator(),
          //               ),
          //             );
          //           if (_articles.length == 0)
          //             return SliverToBoxAdapter(
          //               child: Center(
          //                 child: Text("No Articles"),
          //               ),
          //             );
          //           return ArticlesListExplore(
          //               articles: _articles);
          //         })
          //     : selectedIdx == 1
          //         ? SliverList(
          //             delegate: SliverChildListDelegate([Text('Quick Read')]),
          //           )
          //         : selectedIdx == 2
          //             ? FutureBuilder(
          //                 future: _getArticles("dateTime", true),
          //                 builder: (ctx, snap) {
          //                   if (snap.connectionState ==
          //                       ConnectionState.waiting)
          //                     return SliverToBoxAdapter(
          //                       child: Center(
          //                         child: CircularProgressIndicator(),
          //                       ),
          //                     );
          //                   if (_articles.length == 0)
          //                     return SliverToBoxAdapter(
          //                       child: Center(
          //                         child: Text("No Articles"),
          //                       ),
          //                     );

          //                   return ArticlesListExplore(
          //                       articles: _articles);
          //                 })
          //             :SliverToBoxAdapter(),

          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 1,
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed('/tagArticle', arguments: tagsList[index]);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10)),
                      child: Stack(
                        children: <Widget>[
                          Container(
                            height: 200.0,
                            width: 200,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    colorFilter: new ColorFilter.mode(
                                        Colors.black.withOpacity(0.6),
                                        BlendMode.dstATop),
                                    image: AssetImage(
                                      "assets/images/tags/" +
                                          tagsList[index]
                                              .toLowerCase()
                                              .replaceAll(" ", "") +
                                          ".jpg",
                                    ))),
                          ),
                          Center(
                            child: Text(
                              tagsList[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: tagsList.length,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 20),
          )
        ],
      ),
    );
  }

  List<DocumentSnapshot> _articles = [];
  DocumentSnapshot _lastDocument;

  Future<void> _getArticles(String order, [bool dec = false]) async {
    Query q = Firestore.instance
        .collection('Articles')
        .orderBy(order, descending: dec)
        .limit(20);
    QuerySnapshot querySnapshot = await q.getDocuments();
    _articles = querySnapshot.documents;
    _lastDocument = querySnapshot.documents[querySnapshot.documents.length - 1];
  }
}

class ArticlesListExplore extends StatelessWidget {
  const ArticlesListExplore({
    Key key,
    @required List<DocumentSnapshot> articles,
  })  : _articles = articles,
        super(key: key);

  final List<DocumentSnapshot> _articles;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, index) {
          return Column(
            children: <Widget>[
              (index % 4 == 0 && index != 0) ? Text("Ads") : SizedBox(),
              InkWell(
                onTap: () {
                  DateTime date =
                      DateTime.parse(_articles[index].data['dateTime']);
                  DateTime now = DateTime.now();
                  int days = DateTime(date.year, date.month, date.day)
                      .difference(DateTime(now.year, now.month, now.day))
                      .inDays;
                  Navigator.of(context).pushNamed(
                    ShowArticle.routeName,
                    arguments: Article(
                      id: _articles[index].data['id'],
                      title: _articles[index].data['title'],
                      data: NotusDocument.fromJson(
                        json.decode(_articles[index].data['data']),
                      ),
                      tags: _articles[index].data['tags'],
                      date: days == 0
                          ? "Today"
                          : days > -2 && days < 0
                              ? (-days).toString() + " days ago"
                              : DateFormat.yMMMd().format(date),
                      views: _articles[index].data['views'].runtimeType == int
                          ? []
                          : _articles[index].data['views'] ?? [],
                      likes: _articles[index].data['likes'] ?? [],
                      subtitle: _articles[index].data['subtitle'] ?? '',
                      userId: _articles[index].data['author'],
                      authorBio: _articles[index].data['authorBio'],
                      authorDp: _articles[index].data['authorDP'].length == 0
                          ? null
                          : _articles[index].data['authorDP'],
                      authorName: _articles[index].data['authorName'],
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
    );
  }
}

class ExploreSectionWidget extends StatelessWidget {
  const ExploreSectionWidget({
    Key key,
    @required this.width,
    @required this.icon,
    @required this.title,
    @required this.selected,
  }) : super(key: key);
  final bool selected;
  final double width;
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Container(
        width: width * .26,
        decoration: BoxDecoration(
          color:  Colors.black,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Icon(
                icon,
                size: 35,
                color:Colors.white,
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color:Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
