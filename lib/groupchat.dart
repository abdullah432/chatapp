import 'package:chatapp/addmembers.dart';
import 'package:chatapp/groupchatroom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupChat extends StatefulWidget {
  const GroupChat({super.key});

  @override
  State<GroupChat> createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGroupList();
  }

  List groupList = [];

  bool isLoading = true;
  getGroupList() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("groups")
        .get()
        .then((value) {
      setState(() {
        groupList = value.docs;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: !isLoading
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const AddMembersInGroup();
                }));
              },
              tooltip: "Create Group",
              child: const Icon(Icons.create),
            )
          : const SizedBox(),
      appBar: AppBar(
        title: const Text("Groups"),
      ),
      body: !isLoading
          ? ListView.builder(
              itemCount: groupList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => GroupChatRoom(
                              groupChatId: groupList[index]["id"],
                            )));
                  },
                  title: Text(groupList[index]["name"]),
                  leading: const Icon(Icons.group),
                );
              })
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
