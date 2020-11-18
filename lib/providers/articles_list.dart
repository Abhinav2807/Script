import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:script/providers/userProvider.dart';
import 'package:zefyr/zefyr.dart';

class utils {
  static final Random _random = Random.secure();

  static String CreateCryptoRandomString([int length = 32]) {
    var values = List<int>.generate(length, (i) => _random.nextInt(256));

    return base64Url.encode(values);
  }
}

class Article {
  final String id;
  final String subtitle;
  final String title;
  final NotusDocument data;
  final String date;
  final String userId;
  final String authorName;
  final String authorBio;
  final String authorDp;
  final List<dynamic> views;
  List<dynamic> tags;
  List<dynamic> likes;

  Article({
    @required this.id,
    @required this.title,
    @required this.subtitle,
    @required this.data,
    @required this.tags,
    @required this.date,
    @required this.views,
    @required this.likes,
    @required this.userId,
    @required this.authorName,
    @required this.authorBio,
    @required this.authorDp,
  });
}

class ArticleList with ChangeNotifier {
  var inst = Firestore.instance;
  List<dynamic> list = [];

  Future<void> addArticle(
      String title,
      String subtitle,
      NotusDocument data,
      FirebaseUser user,
      List<dynamic> selectedTags,
      userProvider provider) async {
    print(title + data.toPlainText());
    // list.add(new Article(title: title, data: data));
    print(list);
    print('String: ' + data.toString());
    print('Json: ${data.toJson()}');
    print('Delta: ${data.toDelta()}');
    print('List: ${data.toDelta().toList()}');
    notifyListeners();
    var key = utils.CreateCryptoRandomString(32);
    await inst.collection('Articles').document(key).setData({
      'title': title,
      'subtitle': subtitle,
      'data': json.encode(data.toJson()),
      'id': key,
      'tags': selectedTags,
      'dateTime': DateTime.now().toString(),
      'views': 0,
      'likes': [],
      'author': user.uid,
      'authorName': provider.userName,
      'authorBio': provider.userBio,
      'authorDP': provider.imageUrl??""
    });
    await Firestore.instance.collection('users').document(user.uid).updateData({
      'Articles': FieldValue.arrayUnion([
        key,
      ])
    });
    provider.addArticle(key);
  }

  void update(String id, String title, NotusDocument data,
      List<dynamic> selectedTags) async {
    await inst.collection('Articles').document(id).updateData({
      'title': title,
      'data': json.encode(data.toJson()),
      'tags': selectedTags,
    });
  }
}
