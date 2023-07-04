import 'package:chatapp/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CreateGroup extends StatefulWidget {
  final List<Map<String, dynamic>> membersList;
  const CreateGroup({required this.membersList, super.key});

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final TextEditingController _groupNameController = TextEditingController();
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  //final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool isLoading = false;
  void createGroup() async {
    setState(() {
      isLoading = true;
    });
    String groupId = const Uuid().v1();
    await _firebaseFirestore.collection("groups").doc(groupId).set({
      "members": widget.membersList,
      "id": groupId,
    });
    for (int i = 0; i < widget.membersList.length; i++) {
      String uid = widget.membersList[i]["uid"];
      await _firebaseFirestore
          .collection("users")
          .doc(uid)
          .collection('groups')
          .doc(groupId)
          .set({
        "name": _groupNameController.text,
        "id": groupId,
      });
      await _firebaseFirestore
          .collection("groups")
          .doc(groupId)
          .collection("chats")
          .add({
        "message":
            "${FirebaseAuth.instance.currentUser!.displayName} created this group",
        "type": "notify",
        "time": FieldValue.serverTimestamp(),
      });
    }
    setState(() {
      isLoading = false;
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const Home(),
          ),
          (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Group Name"),
      ),
      body: !isLoading
          ? Column(children: [
              const SizedBox(height: 20.0),
              groupField(),
              const SizedBox(height: 15.0),
              createButton(),
            ])
          : const CircularProgressIndicator(),
    );
  }

  Widget groupField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _groupNameController,
        decoration: const InputDecoration(
          hintText: "Enter Group Name",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          )),
        ),
      ),
    );
  }

  Widget createButton() {
    return Padding(
      padding: const EdgeInsets.only(
          left: 35.0, right: 35.0, top: 12.5, bottom: 12.5),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(),
          ),
          onPressed: () {
            createGroup();
          },
          child: const Text(
            "Create Group",
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          )),
    );
  }
}
