import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:script/screens/userDetails&tags/user_details_screen.dart';
import 'package:zefyr/zefyr.dart';

class MyAppZefyrImageDelegate implements ZefyrImageDelegate<ImageSource> {
  final String title;
  MyAppZefyrImageDelegate(this.title);

  @override
  Future<String> pickImage(ImageSource source) async {
    final file = await ImagePicker.pickImage(source: source);
    if (file == null) return null;
    // We simply return the absolute path to selected file.
    var task = FirebaseStorage.instance.ref().child(title).putFile(file);
    await task.onComplete;
    String url =
        await FirebaseStorage.instance.ref().child(title).getDownloadURL();
    return url;
  }

  @override
  Widget buildImage(BuildContext context, String key) {
    /// final file = File.fromUri(Uri.parse(key));
    /// Create standard [FileImage] provider. If [key] was an HTTP link
    /// we could use [NetworkImage] instead.
    return ImageInArticle(
      url: key,
    );
  }

  @override
  // TODO: implement cameraSource
  ImageSource get cameraSource => ImageSource.camera;
  @override
  // TODO: implement gallerySource
  ImageSource get gallerySource => ImageSource.gallery;
}

class ImageInArticle extends StatelessWidget {
  final String url;
  const ImageInArticle({
    this.url,
    Key key,
  }) : super(key: key);
  // final NetworkImage image;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Image.network(
        url,
        fit: BoxFit.fitWidth,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes
                  : null,
            ),
          );
        },
      ),
    );
  }
}
