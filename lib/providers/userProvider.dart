import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class userProvider with ChangeNotifier {
  List<String> _userArticles = [];
  List<String> _userTags = [];
  String _name;
  String _email;
  String _bio;
  String id;
  String imageUrl;
  List<String> _bookmarks = [];

//  String dpUrl;
  Image userImage;

//  List<String>

  double _totalEarnings = 0.0;

  //getters and setters
  List<String> get userArticles => _userArticles;

  List<String> get userTags => _userTags;

  List<String> get bookmarks => _bookmarks;

  String get userName => _name;

  String get userEmail => _email;

  String get userBio => _bio;

  double get userEarnings => _totalEarnings;

  Future<void> updateTags(List<String> newTags) {
    this._userTags = newTags;
    notifyListeners();
  }

  Future<void> updateUserDetails(
      String name, String email, String bio, File img) async {
    _name = name;
    _email = email;
    _bio = bio;
    if (img != null) {
      StorageReference ref = FirebaseStorage.instance.ref();
      var task = ref.child(this.id).child('dp').putFile(img);
      await task.onComplete;
      String url = await ref.child(this.id).child('dp').getDownloadURL();
      this.imageUrl = url;
      this.userImage = Image.file(img);
      await Firestore.instance
          .collection('users')
          .document(this.id)
          .updateData({
        'Name': this._name,
        'Email': this._email,
        'Bio': this._bio,
        'dpUrl': url,
      });
    } else {
      await Firestore.instance
          .collection('users')
          .document(this.id)
          .updateData({
        'Name': this._name,
        'Email': this._email,
        'Bio': this._bio,
      });
    }
  }

  //Setting user Details
  void setUserDetails(String name, String bio, String email, double earnings) {
    this._name = name;
    this._bio = bio;
    this._email = email;
    this._totalEarnings = earnings;
  }

  void removeBookmark(String id) {
    _bookmarks.removeWhere((element) => element == id);
    notifyListeners();
  }

  //Adding article to the user List
  void addArticle(String articleId) {
    print('adding article: $articleId');
    _userArticles.add(articleId); //Adding article Id created by the user
    notifyListeners();
  }

  //Adding an article to the list of articles bookmarked by the user
  void addBookmarks(String id) {
    _bookmarks.add(id); //Adding id of the article that is the bookmark
    notifyListeners();
  }

  //Adding an article to the list of tags followed by the user
  void addTag(String tag) {
    _userTags.add(tag); //Adding id of the article that is the bookmark
    notifyListeners();
  }

  //Erasing all user details on logout
  void empty() {
    _userArticles = [];
    _userTags = [];
    _name = "";
    _email = "";
    _bio = "";
    _bookmarks = [];
    _totalEarnings = 0.0;
  }
}
