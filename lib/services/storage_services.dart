import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class StorageServices {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  StorageServices() {}
  Future<String?> uploadImage(
      {required File imageFile, required String userId}) async {
    try {
      final String fileName = '${userId}${p.extension(imageFile.path)}';
      final Reference reference =
          _firebaseStorage.ref('users/profilePics').child(fileName);
      final UploadTask uploadTask = reference.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;
      return taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print(e);
    }
    return null;
  }
}
