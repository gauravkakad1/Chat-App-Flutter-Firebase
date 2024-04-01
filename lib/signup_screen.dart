import 'dart:io';

import 'package:chat_app/consts.dart';
import 'package:chat_app/login_screen.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:chat_app/services/database_services.dart';
import 'package:chat_app/services/storage_services.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> _loginFromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _nameKey = GlobalKey<FormState>();
  bool isvisibile = true;
  XFile? _image;

  GetIt getIt = GetIt.instance;
  late AuthServices _authServices;
  late StorageServices _storageServices;
  late DatabaseServices _databaseServices;
  bool isloading = false;
  @override
  void initState() {
    super.initState();
    _authServices = getIt.get<AuthServices>();
    _storageServices = getIt.get<StorageServices>();
    _databaseServices = getIt.get<DatabaseServices>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                _headerText(),
                SizedBox(height: 40),
                _inputField(),
                SizedBox(height: 20),
                _signupBtn(),
                SizedBox(height: 20),
                _alreadyHaveAccount(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const <Widget>[
        Text('Lets, get going! ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        Text('Register an account to get started',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey)),
      ],
    );
  }

  Widget _profilePicture() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: _image != null
                ? FileImage(File(_image!.path)) as ImageProvider<Object>?
                : NetworkImage(PLACEHOLDER_PFP) as ImageProvider<Object>?,
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              final ImagePicker _picker = ImagePicker();
              final XFile? image = await _picker.pickImage(
                source: ImageSource.gallery,
              );
              if (image != null) {
                setState(() {
                  _image = image;
                });
              }
            },
            child: const Text('Add Profile Picture'),
          ),
        ],
      ),
    );
  }

  Widget _inputField() {
    return Form(
      key: _loginFromKey,
      child: Column(
        children: [
          _profilePicture(),
          const SizedBox(height: 50),
          TextFormField(
            key: _nameKey,
            controller: nameController,
            onFieldSubmitted: (value) {
              _nameKey.currentState?.validate();
            },
            validator: (value) {
              if (value != null &&
                  value.isNotEmpty &&
                  NAME_VALIDATION_REGEX.hasMatch(value)) {
                return null;
              }
              return 'Please enter a valid name\n'
                  'Name should start with an uppercase letter\n'
                  'and can include lowercase letters, hyphens, commas, periods, spaces, or apostrophes';
            },
            decoration: InputDecoration(
              hintText: 'Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 25),
          TextFormField(
            controller: emailController,
            validator: (value) {
              if (value != null &&
                  value.isNotEmpty &&
                  EMAIL_VALIDATION_REGEX.hasMatch(value)) {
                return null;
              }
              return 'Please enter valid email';
            },
            decoration: InputDecoration(
              hintText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            validator: (value) {
              if (value != null &&
                  value.isNotEmpty &&
                  PASSWORD_VALIDATION_REGEX.hasMatch(value)) {
                return null;
              }
              return 'Password must be at least 8 characters long \n'
                  'one digit, one lowercase letter,\n'
                  'and one uppercase letter';
            },
            controller: passwordController,
            obscureText: isvisibile,
            obscuringCharacter: "*",
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: () {
                  isvisibile = !isvisibile;
                  setState(() {});
                },
                icon: !isvisibile
                    ? Icon(Icons.visibility)
                    : Icon(Icons.visibility_off),
              ),
              hintText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _signupBtn() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          if (_image == null) {
            DelightToastBar(
              snackbarDuration: Duration(seconds: 1),
              position: DelightSnackbarPosition.top,
              autoDismiss: true,
              builder: (context) => ToastCard(
                leading: Icon(
                  Icons.error,
                  size: 28,
                ),
                color: Colors.red,
                title: Text(
                  "Please select a profile picture!",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ).show(context);
            return;
          }
          if (_loginFromKey.currentState!.validate() ?? false) {
            setState(() {
              isloading = true;
            });
            print('Login Clicked!');
            _loginFromKey.currentState!.save();
            var result = await _authServices.signUpWithEmailAndPassword(
              emailController.text,
              passwordController.text,
            );
            if (result == true) {
              String? ProfileUrl = await _storageServices.uploadImage(
                  imageFile: File(_image!.path),
                  userId: _authServices.user!.uid);
              if (ProfileUrl != null) {
                _databaseServices.createUser(UserProfile(
                    uid: _authServices.user!.uid,
                    name: nameController.text,
                    pfpURL: ProfileUrl));
              }
              DelightToastBar(
                snackbarDuration: Duration(seconds: 1),
                position: DelightSnackbarPosition.top,
                autoDismiss: true,
                builder: (context) => ToastCard(
                  leading: Icon(
                    Icons.check_circle_rounded,
                    size: 28,
                  ),
                  color: Colors.green,
                  title: Text(
                    "Account Created Successfully!",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ).show(context);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            } else {
              DelightToastBar(
                snackbarDuration: Duration(seconds: 1),
                position: DelightSnackbarPosition.top,
                autoDismiss: true,
                builder: (context) => ToastCard(
                  leading: Icon(
                    Icons.error,
                    size: 28,
                  ),
                  color: Colors.red,
                  title: Text(
                    "You Already have an account!",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ).show(context);
            }
          }
          setState(() {
            isloading = false;
          });
        },
        child: isloading
            ? CircularProgressIndicator(
                color: Colors.blue,
              )
            : const Text('Sign Up'),
      ),
    );
  }

  Widget _alreadyHaveAccount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Already have an account? '),
        GestureDetector(
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            child: Text('Login', style: TextStyle(color: Colors.blue))),
      ],
    );
  }
}
