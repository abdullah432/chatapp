import 'package:chatapp/loginpage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  if (!kIsWeb) {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  } else if (kIsWeb) {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyB5vFsMNsyzgvSPfdLnyzZhOG3_Zi0kWwA",
        appId: "1:185086142722:web:be8f6b7287802d9030ba1b",
        messagingSenderId: "185086142722",
        projectId: "chatapp-64003",
        storageBucket: "chatapp-64003.appspot.com",
      ),
    );
  }

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginScreen(),
  ));
}
