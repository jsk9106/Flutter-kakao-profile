import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';

class FirestorageRepository{
  UploadTask uploadImageFile(String uid, String fileName, File file){
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('user/$uid')
        .child('/$fileName.jpg');

    return ref.putFile(file);
  }
}