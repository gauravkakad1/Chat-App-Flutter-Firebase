import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/models/chat_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:chat_app/services/database_services.dart';
import 'package:chat_app/services/media_services.dart';
import 'package:chat_app/services/storage_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

Future<void> setupFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> registerServices() async {
  final GetIt getIt = GetIt.instance;
  getIt.registerSingleton<AuthServices>(AuthServices());
  getIt.registerSingleton<StorageServices>(StorageServices());
  getIt.registerSingleton<DatabaseServices>(DatabaseServices());
  getIt.registerSingleton<MediaServices>(MediaServices());
}

String generateChatId({required String userId1, required String userId2}) {
  List<String> userIds = [userId1, userId2];
  userIds.sort();
  String chatId = userIds.fold("", (id, uid) => '$id$uid');
  return chatId;
}
