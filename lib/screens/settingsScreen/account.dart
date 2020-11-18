import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:script/providers/authorization.dart';
import 'package:script/providers/userProvider.dart';

class Account extends StatefulWidget {
  static const routeName = '/accounts';

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AccountState();
  }
}

class AccountState extends State<Account> {
  var form = GlobalKey<FormState>();
  Map<String, String> details = {
    'name': '',
    'email': '',
    'bio': '',
  };
  bool loading = false;

//  Image image;
  File pickedImage = null;
  ImageSource source;

  Future<void> getImage() async {
    File selectedImage = await ImagePicker.pickImage(source: source);
    setState(() {
      pickedImage = selectedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    userProvider user = Provider.of<userProvider>(context, listen: false);
    details['name'] = user.userName;
    details['email'] = user.userEmail;
    details['bio'] = user.userBio;
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Details'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.check),
              onPressed: loading
                  ? null
                  : () async {
                      if (form.currentState.validate()) {
                        form.currentState.save();
                        setState(() {
                          loading = true;
                        });
                        await user.updateUserDetails(details['name'],
                            details['email'], details['bio'], this.pickedImage);
                        await Provider.of<Authenticate>(context, listen: false)
                            .updateUserEmail(details['email']);
                        setState(() {
                          loading = false;
                        });
                        Navigator.of(context).pop();
                      }
                    })
        ],
      ),
      body: loading
          ? Center(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(
                  height: 10,
                ),
                Text('Updating user details')
              ],
            ))
          : Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (ctx) => SimpleDialog(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      IconButton(
                                          icon: Icon(
                                            Icons.image,
                                            size: 40,
                                          ),
                                          onPressed: () async {
                                            source = ImageSource.gallery;
                                            await getImage();

                                            Navigator.of(ctx).pop();
                                          }),
                                      IconButton(
                                        icon: Icon(
                                          Icons.camera,
                                          size: 40,
                                        ),
                                        onPressed: () async {
                                          source = ImageSource.camera;
                                          await getImage();
                                          Navigator.of(ctx).pop();
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ));
                    },
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.black,
                      child: user.userImage == null && pickedImage == null
                          ? Text(
                              'No image chosen',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            )
                          : Container(),
                      backgroundImage: pickedImage == null
                          ? user.userImage == null ? null : user.userImage.image
                          : FileImage(pickedImage),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Form(
                    key: form,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          initialValue: user.userName,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            hintText: 'Enter Your Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 5,
                              ),
                            ),
                          ),
                          validator: (val) {
                            if (val.length < 5) {
                              return 'Name should at least be 5 Characters';
                            }
                            return null;
                          },
                          onSaved: (val) {
                            details['name'] = val;
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          initialValue: user.userEmail,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (val) {
                            if (val.length < 5 ||
                                !val.contains('@') ||
                                !val.contains(".com")) {
                              return 'Invalid Email';
                            }
                            return null;
                          },
                          onSaved: (val) {
                            details['email'] = val;
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          initialValue: user.userBio,
                          decoration: InputDecoration(
                            labelText: 'Bio',
                            hintText: 'Enter Your bio',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 5,
                              ),
                            ),
                          ),
                          validator: (val) {
                            if (val.length < 10) {
                              return 'Bio should be at least 10 characters';
                            }
                            return null;
                          },
                          onSaved: (val) {
                            details['bio'] = val;
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
