import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

class DatabaseServices {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  CollectionReference? _userCollection;
  GetIt getIt = GetIt.instance;
  late AuthServices _authServices;
  DatabaseServices() {
    _authServices = getIt.get<AuthServices>();
  }

  void _setupCollectionReferances() {
    _userCollection = _firebaseFirestore
        .collection('users')
        .withConverter<UserProfile>(
            fromFirestore: (snapshot, _) =>
                UserProfile.fromJson(snapshot.data()!),
            toFirestore: (user, _) => user.toJson());

    // final CollectionReference messages = _firebaseFirestore.collection('messages');
  }

  Future<void> createUser(UserProfile user) async {
    if (_userCollection == null) {
      _setupCollectionReferances();
    }
    await _userCollection!.doc(user.uid).set(user);
  }

  Stream<QuerySnapshot<UserProfile>> getUsers() {
    if (_userCollection == null) {
      _setupCollectionReferances();
    }
    return _userCollection!
        .where("uid", isNotEqualTo: _authServices.user!.uid)
        .snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }
}
