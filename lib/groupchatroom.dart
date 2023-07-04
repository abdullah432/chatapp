import 'package:chatapp/groupinfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class GroupChatRoom extends StatefulWidget {
  final String groupChatId;
  const GroupChatRoom({required this.groupChatId, super.key});

  @override
  State<GroupChatRoom> createState() => _GroupChatRoomState();
}

class _GroupChatRoomState extends State<GroupChatRoom> {
  String currentUserName = "User1";
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Group Name"),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const GroupInfo()));
                },
                icon: const Icon(Icons.more_vert))
          ],
        ),
        body: SingleChildScrollView(
          child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("groups")
                  .doc(widget.groupChatId)
                  .collection("chats")
                  .orderBy("time", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    if (snapshot.hasData) {
                      Map<String, dynamic> map = snapshot.data!.docs[index]
                          .data() as Map<String, dynamic>;
                      return messageTile(map);
                    } else {
                      return const SizedBox();
                    }
                  },
                );
              }),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _messageController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Write something";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.photo),
                        ),
                        hintText: "Message",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          onSendMessage();
                        }
                      },
                      icon: const Icon(Icons.send))
                ],
              )),
        ));
  }

  onSendMessage() async {
    final currentUser = FirebaseAuth.instance.currentUser!.displayName;
    Map<String, dynamic> messageMap = {
      "sendby": currentUser,
      "message": _messageController.text,
      "type": "text",
      "time": FieldValue.serverTimestamp(),
    };
    _messageController.clear();
    await FirebaseFirestore.instance
        .collection("groups")
        .doc(widget.groupChatId)
        .collection("chats")
        .add(messageMap);
  }

  Widget messageTile(Map<String, dynamic> chatmap) {
    return Builder(
      builder: (context) {
        if (chatmap["type"] == "text") {
          return Container(
            alignment: chatmap["sendby"] ==
                    FirebaseAuth.instance.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              //width: 40.0,
              // height: 50.0,

              decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              margin:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
              child: Column(
                children: [
                  Text(
                    chatmap["sendby"],
                    style: const TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                  Text(
                    chatmap["message"],
                    style: const TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (chatmap["type"] == "img") {
          return Container(
            alignment: chatmap["sendby"] ==
                    FirebaseAuth.instance.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              //width: 40.0,
              // height: 50.0,

              decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              margin:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 5.0),
              child: Image.network(chatmap["message"]),
            ),
          );
        } else if (chatmap["type"] == "notify") {
          return Container(
            alignment: Alignment.center,
            child: Container(
              //width: 40.0,
              // height: 50.0,

              decoration: const BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              margin:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
              child: Text(
                chatmap["message"],
                style: const TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
