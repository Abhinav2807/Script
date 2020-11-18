import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:script/providers/userProvider.dart';

class Authenticate extends ChangeNotifier {
  bool auth = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _currUser;
  bool verified;
  var userId;

  Stream<FirebaseUser> getStream() {
    return _auth.onAuthStateChanged;
  }

  Future<FirebaseUser> getCurrentUser() {
    return _auth.currentUser();
  }

  Future<bool> hasUserDetails(userProvider userDetails) async {
    FirebaseUser user = await _auth.currentUser();
    var data =
        await Firestore.instance.collection('users').document(user.uid).get();
//    print(data.data);
    if (data.data == null) {
      return false;
    } else {
      FirebaseUser user = await _auth.currentUser();
      userDetails.id = user.uid;
      var details = data.data;
      if (details.containsKey('dpUrl')){
        userDetails.imageUrl = details['dpUrl'];
        userDetails.userImage = Image.network(details['dpUrl']);}
      userDetails.setUserDetails(details['Name'], details['Bio'],
          details['Email'], details['TotalEarnings']);
      List<dynamic> list = details['Articles'];
      for (int i = 0; i < list.length; i++) userDetails.addArticle(list[i]);
      List<dynamic> tags = details['Tags Followed'];
      print('tags: $tags');
      for (int i = 0; i < tags.length; i++) userDetails.addTag(tags[i]);
      List<dynamic> bookmarks = details['Bookmarks'];
      for (int i = 0; i < bookmarks.length; i++)
        userDetails.addBookmarks(bookmarks[i]);

      print(details);
      return true;
    }
  }

  Future<void> updateUserEmail(String email) async {
    FirebaseUser user = await _auth.currentUser();
    await user.updateEmail(email);
  }

  bool isEmailVerified() {
    print('User verification: ${_currUser.uid} ${_currUser.isEmailVerified}');
    return _currUser.isEmailVerified;
  }

  verifyEmail() async {
    await _currUser.sendEmailVerification();
  }

  Future<void> signUp(String email, String password) async {
    AuthResult result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    _currUser = result.user;
    print(_currUser);
    auth = true;
    notifyListeners();
  }

  Future<void> signin(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      userId = result.user.uid.toString();
      _currUser = result.user;
    } catch (error) {
      throw (error);
    }
    auth = true;
    notifyListeners();
  }

  Future<void> signInAnonymously() async {
    try {
      AuthResult result = await _auth.signInAnonymously();
      _currUser = result.user;
      auth = true;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> google_signin() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    userId = await user.getIdToken().toString();
    _currUser = user;
    auth = true;
    notifyListeners();
  }

  Future<void> logout() {
    _auth.signOut();
    auth = false;
    userId = null;
    _currUser = null;
    notifyListeners();
  }
}
