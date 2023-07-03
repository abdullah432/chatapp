import 'package:chatapp/creategroup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddMembersInGroup extends StatefulWidget {
  const AddMembersInGroup({super.key});

  @override
  State<AddMembersInGroup> createState() => _AddMembersInGroupState();
}

class _AddMembersInGroupState extends State<AddMembersInGroup> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  final RegExp regExp =
      RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$');
  bool isLoading = false;
  List<Map<String, dynamic>> membersList = [];
  Map<String, dynamic>? userMap;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUserDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: membersList.length >= 2
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return CreateGroup(
                      membersList: membersList,
                    );
                  }));
                },
                child: const Icon(Icons.forward),
              )
            : const SizedBox(),
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text("Add memebers"),
        ),
        body: SingleChildScrollView(
            child: Column(children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: membersList.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  memberDelete(index);
                },
                leading: const Icon(
                  Icons.account_circle,
                ),
                title: Text(membersList[index]["name"]),
                subtitle: Text(membersList[index]["email"]),
                trailing: const Icon(Icons.close),
              );
            },
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20.0),
                searchField(),
                const SizedBox(height: 15.0),
                searchButton(),
                const SizedBox(height: 10.0),
                userMap != null
                    ? ListTile(
                        onTap: () {
                          onPressedMember();
                        },
                        leading: const Icon(Icons.account_circle),
                        title: Text(userMap!["name"]),
                        subtitle: Text(userMap!["email"]),
                        trailing: const Icon(Icons.add),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ])));
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
    return !isLoading
        ? Padding(
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
          )
        : const CircularProgressIndicator();
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

  onPressedMember() {
    setState(() {
      // membersList.add(userMap!);
      //userMap = {};
      bool isAlreadyExist = false;
      for (int i = 0; i < membersList.length; i++) {
        if (membersList[i]["uid"] == userMap!["uid"]) {
          isAlreadyExist = true;
        }
      }
      if (!isAlreadyExist) {
        membersList.add({
          "name": userMap!["name"],
          "email": userMap!["email"],
          "uid": userMap!["uid"],
          "admin": "false",
        });
      }
      userMap = null;
    });
    // membersList.add(userMap);
    //userMap = {};
  }

  getCurrentUserDetail() async {
    final firebaseFirestore = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (firebaseFirestore != null) {
      setState(() {
        membersList.add({
          "name": firebaseFirestore["name"],
          "email": firebaseFirestore["email"],
          "uid": firebaseFirestore["uid"],
          "admin": "true",
        });
      });
    }
  }

  memberDelete(int index) {
    setState(() {
      if (membersList[index]["uid"] != FirebaseAuth.instance.currentUser!.uid) {
        membersList.removeAt(index);
      }
    });
  }
}
