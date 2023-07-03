// import 'dart:html';

import 'package:chatapp/chatroom.dart';
import 'package:chatapp/groupchat.dart';
import 'package:chatapp/loginpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus("Online");
  }

  Future<void> setStatus(String status) async {
    await firebaseFirestore
        .collection("users")
        .doc(firebaseAuth.currentUser!.uid)
        .update({"status": status});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    debugPrint('Lifecycle changed');
    if (state == AppLifecycleState.resumed) {
      //online
      setStatus("Online");
    } else {
      //offline
      setStatus("Offline");
    }
  }

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  Map<String, dynamic> userMap = {};
  final RegExp regExp =
      RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$');

  @override
  Widget build(BuildContext context) {
    debugPrint("isLoading : $isLoading");
    debugPrint("userMap : $userMap");
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const GroupChat()));
        },
        child: const Icon(Icons.group),
      ),
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                // User? user =  FirebaseAuth.instance.currentUser;
                // debugPrint("user : " + user!.uid.toString());
                debugPrint("user : ${FirebaseAuth.instance.currentUser}");

                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
              },
              icon: const Icon(Icons.logout))
        ],
        centerTitle: true,
        title: const Text(
          "Home Screen",
          style: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20.0),
                  searchField(),
                  const SizedBox(height: 15.0),
                  searchButton(),
                  const SizedBox(height: 10.0),
                  userMap.isEmpty ? Container() : userData(),
                ],
              )),
    );
  }

  Widget searchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextFormField(
        controller: _searchController,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please emter something";
          } else if (!regExp.hasMatch(value)) {
            return "Please enter valid email";
          }
          return null;
        },
        decoration: const InputDecoration(
          hintText: "Search",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          )),
        ),
      ),
    );
  }

  Widget searchButton() {
    return Padding(
      padding: const EdgeInsets.only(
          left: 35.0, right: 35.0, top: 12.5, bottom: 12.5),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(),
          ),
          onPressed: () {
            onSearch();
          },
          child: const Text(
            "Search",
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          )),
    );
  }

  Future<void> onSearch() async {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      setState(() {
        isLoading = true;
      });

      await firebaseFirestore
          .collection("users")
          .where("email", isEqualTo: _searchController.text)
          .get()
          .then((value) {
        setState(() {
          userMap = value.docs[0].data();
          isLoading = false;
        });
        debugPrint("userMap : $userMap");
      });
    }
  }

  Widget userData() {
    return ListTile(
      onTap: () {
        String roomId = chatRoomId(
            FirebaseAuth.instance.currentUser!.displayName.toString(),
            userMap["name"]);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ChatRoom(chatRoomId: roomId, userMap: userMap),
            ));
      },
      title: Text(userMap["name"]),
      subtitle: Text(
        userMap["email"],
      ),
      trailing: const Icon(Icons.chat, color: Colors.black),
    );
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2[0].toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }
}
