import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:script/providers/userProvider.dart';

import '../../home_screen.dart';

class ViewAllTags extends StatefulWidget {
  static const routeName = '/ViewTags';

  @override
  _ViewAllTagsState createState() => _ViewAllTagsState();
}

class _ViewAllTagsState extends State<ViewAllTags> {
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
  void didChangeDependencies() {
    userProvider provider = Provider.of<userProvider>(context, listen: false);
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    int i;
    for (i = 0; i < provider.userTags.length; i++) {
      selectedTags.add(provider.userTags[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tags"),
        centerTitle: true,
        actions: <Widget>[
          MaterialButton(
              onPressed: ()  {
                userProvider user = Provider.of<userProvider>(context, listen: false);
                user.updateTags(selectedTags);
                Fluttertoast.showToast(msg: 'Tags updated');
                Firestore.instance.collection('users').document(user.id).updateData({
                  'Tags Followed': selectedTags,
                });
                Navigator.of(context).pushNamedAndRemoveUntil(
                HomeScreen.routeName, (Route<dynamic> route) => false);
              },
              child: Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      body: loading
          ? CircularProgressIndicator()
          : Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
              ),
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 10,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Text(
                      "Edit the tags you follow!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 10,
                    ),
                  ),
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
