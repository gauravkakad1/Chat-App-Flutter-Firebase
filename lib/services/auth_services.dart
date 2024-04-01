import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class AuthServices {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _user;
  User? get user => _user;
  set user(User? value) {
    _user = value;
  }

  AuthServices() {}

  Future<bool> loginInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<void> authStateChangesStream(User? user) async {
    _firebaseAuth.authStateChanges().listen((User? user) {
      if (user != null) {
        _user = user;
        print(_user!.email);
      } else {
        _user = null;
      }
    });
  }
}
