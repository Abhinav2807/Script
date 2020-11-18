import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:script/providers/authorization.dart';
import 'package:script/screens/userDetails&tags/tagsChoice.dart';

class userDetails extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return userState();
  }
}

class userState extends State<userDetails> {
  // List<String> tagsFollowed = [];
  Map<String, String> map = {
    'name': "",
    'bio': "",
  };
  var form = GlobalKey<FormState>();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        label: loading
            ? Text('')
            : Text(
                "Proceed",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
        onPressed: () async {
          if (form.currentState.validate()) {
            form.currentState.save();
            // setState(() {
            //   loading = true;
            // });
            FirebaseUser user =
                await Provider.of<Authenticate>(context, listen: false)
                    .getCurrentUser();
            // Firestore.instance.collection('users').document(user.uid).setData({
            //   'Name': map['name'],
            //   'Email': user.email,
            //   'Bio': map['bio'],
            //   'Tags Followed': tagsFollowed,
            //   'Bookmarks': [],
            //   'TotalEarnings': 0.0,
            //   'Articles': [],
            // });
            // setState(() {
            //   loading = false;
            // });
            // Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
            Navigator.of(context).pushNamed(TagsChoice.routeName,
                arguments: UserDetailsArguments(
                  name: map['name'],
                  email: user.email,
                  bio: map['bio'],
                  tagsFollowed: [],
                  bookmarks: [],
                  totalEarnings: 0.0,
                  articles: [],
                ));
          }
        },
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Form(
          key: form,
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: 30,
              ),
              Text(
                "What would you like us to call you ?",
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'You Name',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2.0),
                  ),
                ),
                validator: (value) {
                  if (value.length == 0) {
                    return 'Name cannot be empty';
                  }
                  return null;
                },
                onSaved: (value) {
                  map['name'] = value;
                },
              ),
              SizedBox(height: 40),
              Text(
                "Give a one liner that describes you.",
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Add a bio',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2.0),
                  ),
                ),
                onSaved: (value) {
                  map['bio'] = value;
                },
                validator: (value) {
                  if (value.length == 0) {
                    return 'Please Enter Something';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserDetailsArguments {
  String name;
  String email;
  String bio;
  List<String> tagsFollowed;
  List bookmarks;
  double totalEarnings;
  List articles;
  UserDetailsArguments({
    this.name,
    this.email,
    this.bio,
    this.tagsFollowed,
    this.bookmarks,
    this.totalEarnings,
    this.articles,
  });
}
