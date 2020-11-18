import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:script/providers/authorization.dart';
import 'package:script/screens/home_screen.dart';
import 'package:script/screens/selection_screen.dart';
import 'package:script/screens/userDetails&tags/user_details_screen.dart';

import '../../providers/userProvider.dart';
import '../../providers/userProvider.dart';

class TagsChoice extends StatefulWidget {
  static const routeName = "/tagsChoice";

  @override
  _TagsChoiceState createState() => _TagsChoiceState();
}

class _TagsChoiceState extends State<TagsChoice> {
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

  List<String> selectedTags = [];
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    UserDetailsArguments args = ModalRoute.of(context).settings.arguments;
    userProvider provider=Provider.of<userProvider>(context);
    return Scaffold(
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton.extended(
          onPressed: () async {
            if (selectedTags.length < 2) {
              Scaffold.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.black87,
                  content: Text('Please select at least 3 tags to proceed!'),
                  duration: Duration(seconds: 1)));
            }
            if (selectedTags.length > 2) {
              setState(() {
                loading = true;
              });
//              for (int i = 0; i < selectedTags.length; i++)
//              provider.addTag(selectedTags[i]);
              FirebaseUser user =
                  await Provider.of<Authenticate>(context, listen: false)
                      .getCurrentUser();
              Firestore.instance
                  .collection('users')
                  .document(user.uid)
                  .setData({
                'Name': args.name,
                'Email': user.email,
                'Bio': args.bio,
                'Tags Followed': selectedTags,
                'Bookmarks': [],
                'TotalEarnings': 0.0,
                'Articles': [],
              });
              setState(() {
                loading = false;
              });
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed(SelectScreen.routeName);
            }
          },
          backgroundColor: Colors.black,
          label: Text(
            "Proceed",
            style: TextStyle(color: Colors.white,fontSize: 18),
          ),
          
        ),
      ),
      body: loading
          ? CircularProgressIndicator()
          : Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 8),
              child: CustomScrollView(
                slivers: <Widget>[
                  _titleOfthePage(),
                  SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 5 / 3,
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedTags.contains(tagsList[index])
                                  ? selectedTags.remove(tagsList[index])
                                  : selectedTags.add(tagsList[index]);
                              print(selectedTags);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.black),
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  height: 200.0,
                                  width: 200,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.asset(
                                      "assets/images/tags/" +
                                          tagsList[index]
                                              .toLowerCase()
                                              .replaceAll(" ", "") +
                                          ".jpg",
                                      color: Colors.black54,
                                      colorBlendMode: BlendMode.darken,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(right: 4, top: 4),
                                    child: Icon(
                                      Icons.check_circle,
                                      color:
                                          selectedTags.contains(tagsList[index])
                                              ? Colors.green
                                              : Colors.grey,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, bottom: 10),
                                    child: Text(
                                      tagsList[index],
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: tagsList.length,
                    ),
                  )
                ],
              ),
            ),
    );
  }
}

SliverToBoxAdapter _titleOfthePage() {
  return SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.only(top: 55.0, bottom: 20),
      child: Text(
        "Please select tags to continue",
        style: TextStyle(fontSize: 24),
      ),
    ),
  );
}
