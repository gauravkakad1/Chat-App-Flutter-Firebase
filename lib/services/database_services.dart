import 'package:chat_app/models/chat_model.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:chat_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

class DatabaseServices {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  CollectionReference? _userCollection;
  CollectionReference? _chatCollection;
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

    _chatCollection = _firebaseFirestore
        .collection('chats')
        .withConverter<Chat>(
            fromFirestore: (snapshot, _) => Chat.fromJson(snapshot.data()!),
            toFirestore: (chat, options) => chat.toJson());
  }

  Future<void> createUser(UserProfile user) async {
    if (_userCollection == null) {
      _setupCollectionReferances();
    }
    await _userCollection!.doc(user.uid).set(user);
  }

  Future<void> createChat(String uid1, String uid2) async {
    if (_chatCollection == null) {
      _setupCollectionReferances();
    }
    String chatId = generateChatId(userId1: uid1, userId2: uid2);
    await _chatCollection?.doc(chatId).set(Chat(
          id: chatId,
          participants: [uid1, uid2],
          messages: [],
        ));
  }

  Stream<QuerySnapshot<UserProfile>> getUsers() {
    if (_userCollection == null) {
      _setupCollectionReferances();
    }
    return _userCollection!
        .where("uid", isNotEqualTo: _authServices.user!.uid)
        .snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }

  Future<bool> checkChatExist(String uid1, String uid2) async {
    String chatId = generateChatId(userId1: uid1, userId2: uid2);
    final DocumentSnapshot<Map<String, dynamic>> chat =
        await _firebaseFirestore.collection('chats').doc(chatId).get();
    if (chat != null && chat.exists) {
      return true;
    }
    return false;
  }

  Stream<QuerySnapshot<Chat>> getChats() {
    if (_chatCollection == null) {
      _setupCollectionReferances();
    }
    return _chatCollection!
        .where("chats", arrayContains: _authServices.user!.uid)
        .snapshots() as Stream<QuerySnapshot<Chat>>;
  }

  Future<void> sendMessage(String uid1, String uid2, Message message) async {
    String chatId = generateChatId(userId1: uid1, userId2: uid2);

    final docRef = await _firebaseFirestore.collection('chats').doc(chatId);

    await docRef.update({
      'messages': FieldValue.arrayUnion([
        message.toJson(),
      ])
    });
  }

  Stream<DocumentSnapshot<Chat>> getChatMessages(String uid1, String uid2) {
    String chatId = generateChatId(userId1: uid1, userId2: uid2);
    return _chatCollection!.doc(chatId).snapshots()
        as Stream<DocumentSnapshot<Chat>>;
  }
}
