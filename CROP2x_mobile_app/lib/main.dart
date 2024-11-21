import 'package:cropx/connection.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyAR_6lVgkJbRBaD1keo9b3a1c6z1CD2rio",
          appId: "1:394129669406:android:a5c665369b7af6bb6e1d0f",
          messagingSenderId: "394129669406",
          projectId: "cropx-6f03a",
          authDomain: 'cropx-6f03a.firebaseapp.com',
          databaseURL: 'https://cropx-6f03a-default-rtdb.firebaseio.com',
          storageBucket: "cropx-6f03a.appspot.com"));
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Connection(),
    );
  }
}
