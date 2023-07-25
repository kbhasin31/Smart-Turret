// ignore_for_file: prefer_const_constructors

import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'main.dart';
import 'package:flutter/material.dart';
import 'components/welcome_button.dart';
import 'constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final email = TextEditingController();
  final password = TextEditingController();
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: SizedBox(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                  controller: email,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                  decoration:
                      khintStyle.copyWith(hintText: 'Enter Your Email')),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                  controller: password,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                  obscureText: true,
                  decoration:
                      khintStyle.copyWith(hintText: 'Enter Your Password')),
              SizedBox(
                height: 24.0,
              ),
              welcome_button(() async {
                try {
                  setState(() {
                    showSpinner = true;
                  });
                  final user = await _auth.signInWithEmailAndPassword(
                      email: email.text, password: password.text);

                  setState(() {
                    showSpinner = false;
                  });
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MyHomePage(
                            title: "Terrainexus",
                          )));
                } on FirebaseAuthException catch (e) {
                  print(e);
                  setState(() {
                    showSpinner = false;
                  });
                  if (e.code == "user-not-found") {
                    showDialog(
                        context: context,
                        builder: (context) => error("User not found",
                            "The email address is not registered"));
                    password.text = "";
                    email.text = "";
                  }
                  if (e.code == "wrong-password" && password.text.length >= 6) {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text("Wrong Password"),
                              content:
                                  Text("The password entered was incorrect"),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('ok'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ));
                    password.text = "";
                  }
                }
              }, Colors.lightBlueAccent, 'Log in'),
            ],
          ),
        ),
      ),
    );
  }
}

class error extends StatelessWidget {
  String title;
  String vlaue;
  error(this.title, this.vlaue);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(vlaue),
      actions: <Widget>[
        TextButton(
          child: const Text('ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
