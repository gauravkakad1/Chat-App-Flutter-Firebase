import 'package:chat_app/home_screen.dart';
import 'package:chat_app/login_screen.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:chat_app/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  await setup();
  runApp(MyApp());
}

Future<void> setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupFirebase();
  await registerServices();
  late AuthServices _authServices;
  GetIt getIt = GetIt.instance;
  _authServices = getIt.get<AuthServices>();
  await _authServices.authStateChangesStream(FirebaseAuth.instance.currentUser);
}

class MyApp extends StatelessWidget {
  late AuthServices _authServices;
  GetIt getIt = GetIt.instance;
  MyApp({super.key}) {
    _authServices = getIt.get<AuthServices>();
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: GoogleFonts.montserratTextTheme(),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: _authServices.user != null ? HomeScreen() : LoginScreen());
  }
}
