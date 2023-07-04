import 'dart:io';

import 'package:chatapp/fullimage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import "package:uuid/uuid.dart";

class ChatRoom extends StatefulWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;

  const ChatRoom({super.key, required this.userMap, required this.chatRoomId});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  File? imageFile;
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(widget.userMap["uid"])
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return Column(
                children: [
                  Text(widget.userMap["name"]),
                  Text(
                    snapshot.data!["status"],
                    style: const TextStyle(fontSize: 14.0),
                  )
                ],
              );
            } else {
              return (Container());
            }
          },
        ),
        centerTitle: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseFirestore
            .collection("chatroom")
            .doc(widget.chatRoomId)
            .collection("chats")
            .orderBy("time", descending: false)
            .snapshots(),
        builder: (_, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data != null) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final map = snapshot.data!.docs[index].data();
                return message(map);
              },
            );
          } else {
            return Container();
          }
        },
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
                        onPressed: () {
                          getImage();
                        },
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
      ),
    );
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    final xFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (xFile != null) {
      imageFile = File(xFile.path);
      uploadImage();
    }
  }

  Future uploadImage() async {
    String fileName = const Uuid().v1();
    int status = 1;
    await firebaseFirestore
        .collection("chatroom")
        .doc(widget.chatRoomId)
        .collection("chats")
        .doc(fileName)
        .set({
      "sendby": FirebaseAuth.instance.currentUser!.displayName,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });
    Reference ref =
        FirebaseStorage.instance.ref().child("images").child("$fileName.jpg");
    TaskSnapshot uploadTask =
        await ref.putFile(imageFile!).catchError((error) async {
      status = 0;
      return await firebaseFirestore
          .collection("chatroom")
          .doc(widget.chatRoomId)
          .collection("chats")
          .doc(fileName)
          .delete();
    });
    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();
      await firebaseFirestore
          .collection("chatroom")
          .doc(widget.chatRoomId)
          .collection("chats")
          .doc(fileName)
          .update({
        "message": imageUrl,
      });
      debugPrint("imageUrl : $imageUrl");
    }
  }

  void onSendMessage() async {
    Map<String, dynamic> messages = {
      "sendby": FirebaseAuth.instance.currentUser!.displayName,
      "message": _messageController.text,
      "type": "text",
      "time": FieldValue.serverTimestamp(),
    };
    debugPrint(
        "display Name : ${FirebaseAuth.instance.currentUser!.displayName}");
    await firebaseFirestore
        .collection("chatroom")
        .doc(widget.chatRoomId)
        .collection("chats")
        .add(messages);
    _messageController.text = "";
  }

  // Map<String, dynamic>
  message(map) {
    return map["type"] == "text"
        ? Container(
            alignment:
                map["sendby"] == FirebaseAuth.instance.currentUser!.displayName
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
            child: Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
              decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(15.0)),
              child: Text(
                map["message"],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 150.0,
              height: 150.0,
              alignment: map["sendby"] ==
                      FirebaseAuth.instance.currentUser!.displayName
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return FullImage(
                      imageUrl: map["message"],
                    );
                  }));
                },
                child: Container(
                  width: 150.0,
                  height: 150.0,
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: map["message"] != ""
                      ? Image.network(
                          map["message"],
                          fit: BoxFit.cover,
                        )
                      : const CircularProgressIndicator(),
                ),
              ),
            ),
          );
  }
}
