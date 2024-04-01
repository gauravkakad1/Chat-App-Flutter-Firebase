import 'package:chat_app/consts.dart';
import 'package:chat_app/home_screen.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:chat_app/signup_screen.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:delightful_toast/delight_toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _loginFromKey = GlobalKey<FormState>();
  bool isvisibile = true;
  final AuthServices _authServices = AuthServices();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Spacer(
                flex: 1,
              ),
              _headerText(),
              Spacer(
                flex: 1,
              ),
              _inputField(),
              SizedBox(height: 20),
              _loginButton(),
              SizedBox(height: 20),
              _dontHaveAccount(),
              Spacer(
                flex: 3,
              ),
            ],
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
        Text('Hi, Welcome Back! ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        Text('Hello again, you have been missed ',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey)),
      ],
    );
  }

  Widget _inputField() {
    return Form(
      key: _loginFromKey,
      child: Column(
        children: [
          TextFormField(
            controller: emailController,
            validator: (value) {
              if (value != null &&
                  value.isNotEmpty &&
                  EMAIL_VALIDATION_REGEX.hasMatch(value)) {
                return null;
              }
              return 'Please enter email';
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

  Widget _loginButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          if (_loginFromKey.currentState!.validate() ?? false) {
            print('Login Clicked!');
            _loginFromKey.currentState!.save();
            var result = await _authServices.loginInWithEmailAndPassword(
                emailController.text, passwordController.text);
            print(result);
            if (result == true) {
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
                    "Login Successfull",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ).show(context);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            } else {
              print('Login Failed');
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
                    "Login Failed! Please try again.",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ).show(context);
            }
          }
        },
        child: const Text('Login'),
      ),
    );
  }

  Widget _dontHaveAccount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Don\'t have an account? '),
        GestureDetector(
            onTap: () {
              print('Sign Up Clicked!');
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => SignupScreen()));
            },
            child: Text('Sign Up', style: TextStyle(color: Colors.blue))),
      ],
    );
  }
}
