import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:script/providers/authorization.dart';
import 'package:script/providers/userProvider.dart';
import 'package:script/screens/articleCreation&Viewing/ShowArticle.dart';
import 'package:zefyr/zefyr.dart';
import '../../providers/articles_list.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ProfileState();
  }
}

class ProfileState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    controller = new TabController(length: 3, vsync: this);
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    userProvider provider = Provider.of<userProvider>(context);
    print(provider.bookmarks);
    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
        headerSliverBuilder: (ctx, _) {
          return [
            SliverToBoxAdapter(
              child: UserProfileDetails(provider: provider),
            ),
          ];
        },
        body: Column(
          children: <Widget>[
            TabBar(
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.black,
              labelStyle: TextStyle(fontSize: 16, fontFamily: "Poppins"),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: Colors.transparent,
              tabs: <Widget>[
                Tab(
                  text: "Scripts",
                ),
                Tab(
                  text: "Bookmarks",
                )
              ],
            ),
            Expanded(
              child: TabBarView(children: [
                UserScriptsProfilePage(provider: provider),
                UserBookmarksProfilePage(provider: provider),
              ]),
            )
          ],
        ),
      ),
    );
  }
}

class UserProfileDetails extends StatelessWidget {
  const UserProfileDetails({
    Key key,
    @required this.provider,
  }) : super(key: key);

  final userProvider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height * .18,
          child: Row(children: [
            Container(
              width: MediaQuery.of(context).size.width * .40,
              child: Center(
                child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    child: provider.userImage == null
                        ? Icon(
                            Icons.account_circle,
                            color: Colors.white,
                            size: 80,
                          )
                        : SizedBox(),
                    backgroundImage: provider.userImage == null
                        ? null
                        : provider.userImage.image),
              ),
            ),
            Container(
              height: double.infinity,
              width: MediaQuery.of(context).size.width * .5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '${provider.userArticles.length}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        "Scripts",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '${provider.userEarnings}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        "Earning",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      )
                    ],
                  )
                ],
              ),
            )
          ]),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 25),
              width: MediaQuery.of(context).size.width * .6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    provider.userName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Text('${provider.userEmail}'),
                  Text('${provider.userBio}')
                ],
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * .3,
            )
          ],
        ),
        Divider()
      ],
    );
  }
}

class UserBookmarksProfilePage extends StatelessWidget {
  const UserBookmarksProfilePage({
    Key key,
    @required this.provider,
  }) : super(key: key);

  final userProvider provider;

  @override
  Widget build(BuildContext context) {
    return provider.bookmarks.length == 0
        ? Center(
            child: Text("You haven't bookmarked any"),
          )
        : StreamBuilder(
            stream: Firestore.instance
                .collection('Articles')
                .where('id', whereIn: provider.bookmarks)
                .orderBy('dateTime', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data == null) {
                Container(child: Text('No articles yet...'));
              }
              QuerySnapshot snap = snapshot.data;
              return snapshot.connectionState == ConnectionState.waiting
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, idx) => Column(
                        children: snap.documents
                            .map((snap) => Column(
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        DateTime date =
                                            DateTime.parse(snap['dateTime']);
                                        DateTime now = DateTime.now();
                                        int days = DateTime(
                                                date.year, date.month, date.day)
                                            .difference(DateTime(
                                                now.year, now.month, now.day))
                                            .inDays;
                                        Navigator.of(context).pushNamed(
                                            ShowArticle.routeName,
                                            arguments: Article(
                                              id: snap.documentID,
                                              title: snap['title'],
                                              data: NotusDocument.fromJson(
                                                json.decode(snap['data']),
                                              ),
                                              tags: snap['tags'],
                                              date: days == 0
                                                  ? "Today"
                                                  : days > -2 && days < 0
                                                      ? (-days).toString() +
                                                          " days ago"
                                                      : DateFormat.yMMMd()
                                                          .format(date),
                                              views: snap['views'] ?? 0,
                                              likes: snap['likes'] ?? [],
                                              subtitle: snap['subtitle'] ?? '',
                                              userId: snap.data['author'],
                                              authorBio: snap.data['authorBio'],
                                              authorDp: snap.data['authorDP']
                                                          .length ==
                                                      0
                                                  ? null
                                                  : snap.data['authorDP'],
                                              authorName:
                                                  snap.data['authorName'],
                                            ));
                                      },
                                      child: ArticleCard2(
                                        choice: 1,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        snap: snap,
                                      ),
                                    ),
                                    Divider()
                                  ],
                                ))
                            .toList(),
                      ),
                      itemCount: 1,
                    );
            },
          );
  }
}

class ArticleCard2 extends StatefulWidget {
  const ArticleCard2(
      {Key key,
      @required this.height,
      @required this.snap,
      @required this.choice})
      : super(key: key);

  final double height;
  final DocumentSnapshot snap;
  final int choice;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ArticleState();
  }
}

class ArticleState extends State<ArticleCard2> {
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
        widget.choice == 1
            ? Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: user.bookmarks.contains(widget.snap['id'])
                      ? Icon(Icons.bookmark)
                      : Icon(Icons.bookmark_border),
                  onPressed: () {
                    if (user.bookmarks.contains(widget.snap['id'])) {
                      user.removeBookmark(widget.snap['id']);
                      Fluttertoast.showToast(msg: "Removed from bookmarks");
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
              )
            : SizedBox(),
        Container(
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
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

class UserScriptsProfilePage extends StatelessWidget {
  const UserScriptsProfilePage({
    Key key,
    @required this.provider,
  }) : super(key: key);

  final userProvider provider;

  @override
  Widget build(BuildContext context) {
    return provider.userArticles.length == 0
        ? Center(
            child: Text("You haven't posted anything yet"),
          )
        : StreamBuilder(
            stream: Firestore.instance
                .collection('Articles')
                .where('id', whereIn: provider.userArticles)
                .orderBy('dateTime', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data == null) {
                Container(child: Text('No articles yet...'));
              }

              QuerySnapshot snap = snapshot.data;
              return snapshot.connectionState == ConnectionState.waiting
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, idx) => Column(
                        children: snap.documents
                            .map((snap) => Column(
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        DateTime date =
                                            DateTime.parse(snap['dateTime']);
                                        DateTime now = DateTime.now();
                                        int days = DateTime(
                                                date.year, date.month, date.day)
                                            .difference(DateTime(
                                                now.year, now.month, now.day))
                                            .inDays;
                                        Navigator.of(context).pushNamed(
                                            ShowArticle.routeName,
                                            arguments: Article(
                                              userId: snap['author'],
                                              authorName: snap['authorName'],
                                              authorDp: snap['authorDP']
                                                          .toString()
                                                          .length ==
                                                      0
                                                  ? null
                                                  : snap['authorDp'],
                                              authorBio: snap['authorBio'],
                                              id: snap.documentID,
                                              title: snap['title'],
                                              data: NotusDocument.fromJson(
                                                json.decode(snap['data']),
                                              ),
                                              tags: snap['tags'],
                                              date: days == 0
                                                  ? "Today"
                                                  : days > -2 && days < 0
                                                      ? (-days).toString() +
                                                          " days ago"
                                                      : DateFormat.yMMMd()
                                                          .format(date),
                                              views:
                                                  snap['views'].runtimeType ==
                                                          int
                                                      ? []
                                                      : snap['views'] ?? [],
                                              likes: snap['likes'] ?? [],
                                              subtitle: snap['subtitle'] ?? '',
                                            ));
                                      },
                                      child: ArticleCard2(
                                        choice: 0,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        snap: snap,
                                      ),
                                    ),
                                    Divider()
                                  ],
                                ))
                            .toList(),
                      ),
                      itemCount: 1,
                    );
            },
          );
  }
}
