// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:robotics_app/loginPage.dart';
import 'package:robotics_app/screen.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp firebaseApp = await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.dark().copyWith(),
        home: LoginScreen());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isScreen = false;
  late DatabaseReference _dbref;
  final _store = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  var detection;
  var shoot;
  late Timer timer;

  _database() {
    if (detection == true && shoot == 0) {
      showDialog(
          context: context,
          builder: ((context) => AlertDialog(
                content:
                    const Text("Person has been Detected. Permission to shoot"),
                actions: [
                  TextButton(
                      onPressed: () {
                        setState(() {
                          shoot = 0;
                          _dbref.child("ESP").update({"Shoot": shoot});
                          Navigator.of(context).pop();
                        });
                      },
                      child: const Text("No")),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          shoot = 1;
                          _dbref.child("ESP").update({"Shoot": shoot});
                          Navigator.of(context).pop();
                        });
                      },
                      child: const Text("Yes")),
                ],
              )));
    }
  }

  _realdb_once() async {
    _dbref.child('ESP').onValue.listen((event) {
      print(event.snapshot.value.toString());
      if (event.snapshot.exists) {
        Map data = event.snapshot.value as Map;
        data.forEach((key, value) {
          setState(() {
            detection = data['Detection'];
            shoot = data['Shoot'];
          });
        });
      }
    });
  }

  Future<dynamic> storage() async {
    String uid = const Uuid().v1();
    http.Response response = await http.get(
      Uri.parse('http://192.168.110.84/jpg'),
    );
    print(response.bodyBytes);

    UploadTask ref =
        _storage.ref('Snap').child(uid).putData(response.bodyBytes);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timer =
        Timer.periodic(const Duration(seconds: 30), (Timer t) => _database());
    _dbref = FirebaseDatabase.instance.ref();
    _realdb_once();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: (Column(
          children: [
            Screen(isScreen),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {
                      if (isScreen == true) {
                        setState(() {
                          isScreen = false;
                        });
                      } else {
                        setState(() {
                          isScreen = true;
                        });
                      }
                    },
                    child: isScreen ? const Text("Hide") : const Text("Show")),
                const SizedBox(width: 30),
                IconButton(
                    onPressed: () async {
                      String uid = const Uuid().v1();
                      http.Response response = await http.get(
                        Uri.parse('http://192.168.110.84/jpg'),
                      );
                      print(response.bodyBytes);

                      UploadTask ref = _storage
                          .ref('Snap')
                          .child(uid)
                          .putData(response.bodyBytes);
                    },
                    icon: const Icon(Icons.photo_camera_sharp)),
              ],
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Detection :',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: detection,
                  activeColor: Colors.green,
                  inactiveTrackColor: Colors.red,
                  onChanged: (value) {},
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Shoot :',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: (shoot == 1) ? true : false,
                  activeColor: Colors.green,
                  inactiveTrackColor: Colors.red,
                  onChanged: (value) {
                    if (detection == true && value == false) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                content: const Text(
                                    "There is no detection,cannot shoot"),
                                actions: [
                                  TextButton(
                                    onPressed: (() {
                                      setState(() {
                                        Navigator.of(context).pop();
                                      });
                                    }),
                                    child: const Text("OK"),
                                  )
                                ],
                              ));
                    }

                    if (detection == true && value == true) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                content:
                                    const Text("You are turning on shooting"),
                                actions: [
                                  TextButton(
                                    onPressed: (() {
                                      setState(() {
                                        Navigator.of(context).pop();
                                      });
                                    }),
                                    child: const Text("No"),
                                  ),
                                  TextButton(
                                    onPressed: (() {
                                      setState(() {
                                        shoot = 1;
                                        _dbref
                                            .child("ESP")
                                            .update({"Shoot": shoot});
                                        Navigator.of(context).pop();
                                      });
                                    }),
                                    child: const Text("Yes"),
                                  )
                                ],
                              ));
                    }
                    if (detection == true && value == false) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                content:
                                    const Text("You are turning off shooting"),
                                actions: [
                                  TextButton(
                                    onPressed: (() {
                                      setState(() {
                                        Navigator.of(context).pop();
                                      });
                                    }),
                                    child: const Text("No"),
                                  ),
                                  TextButton(
                                    onPressed: (() {
                                      setState(() {
                                        shoot = 0;
                                        _dbref
                                            .child("ESP")
                                            .update({"Shoot": shoot});
                                        Navigator.of(context).pop();
                                      });
                                    }),
                                    child: const Text("Yes"),
                                  )
                                ],
                              ));
                    }
                  },
                ),
              ],
            ),
          ],
        )),
      ),
    );
  }
}
