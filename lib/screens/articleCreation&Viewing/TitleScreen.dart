import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:script/screens/articleCreation&Viewing/DataScreen.dart';

// import 'package:script/screens/edit_screen/DataScreen.dart';
import 'package:zefyr/zefyr.dart';

class TitleScreen extends StatefulWidget {
  static const routeName = '/title-screen';

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return TitleState();
  }
}

class TitleState extends State<TitleScreen> {
  TextEditingController controller = new TextEditingController();
  TextEditingController sub_controller = new TextEditingController();
  FocusNode nn = new FocusNode();
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

  List<dynamic> selectedTags = [];

  @override
  Widget build(BuildContext context) {
    var arguments =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    if (arguments != null) {
      controller.text = arguments['title'];
      selectedTags = arguments['tags'];
      sub_controller.text = arguments['subtitle'];
    }
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton.extended(
          backgroundColor: Colors.black,
          label: Text(
            "Proceed",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          onPressed: () {
            print(selectedTags);
            if (controller.text.length > 0 && selectedTags.length != 0)
              Navigator.of(context).pushNamed(
                DataScreen.routeName,
                arguments: arguments == null
                    ? {
                        'title': controller.text,
                        'tags': selectedTags,
                        'subtitle': sub_controller.text,
                      }
                    : {
                        'id': arguments['id'],
                        'subtitle': sub_controller.text,
                        'title': controller.text,
                        'data': arguments['data'],
                        'tags': selectedTags,
                      },
              );
            else {
              Scaffold.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.black87,
                  content: controller.text.length == 0
                      ? Text('Please Enter title to proceed!')
                      : Text('Please add at least one tag to continue'),
                  duration: Duration(seconds: 1)));
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 25,
            ),
            Text(
              "Enter the title for your article",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 15,
            ),
            TextFormField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Enter Title",
                hintText: "Enter your title here!",
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2.0),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            TextFormField(
              controller: sub_controller,
              autofocus: false,
              decoration: InputDecoration(
                labelText: "Enter Subtitle",
                hintText: "Enter your subtitle here!",
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2.0),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            GridView(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                maxCrossAxisExtent: 3,
                childAspectRatio: 3,
                crossAxisCount: 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
//              scrollDirection: Axis.horizontal,
              children: tagsList
                  .map((e) => Container(
                      margin: EdgeInsets.all(2),
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: selectedTags.contains(e)
                            ? Colors.black54
                            : Colors.black12,
                        onPressed: () {
                          if (selectedTags.contains(e)) {
                            setState(() {
                              selectedTags.remove(e);
                            });
                          } else {
                            setState(() {
                              selectedTags.add(e);
                            });
                          }
                          print(selectedTags);
                        },
                        child: Center(
                            child: Text(
                          e,
                          textAlign: TextAlign.center,
                        )),
                      )))
                  .toList(),
            )
          ],
        ),
      ),
    );
  }
}
