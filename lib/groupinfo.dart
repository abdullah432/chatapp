import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupInfo extends StatefulWidget {
  final String groupChatId;
  final String name;
  const GroupInfo({required this.name, required this.groupChatId, super.key});

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  bool isLoading = true;
  List membersList = [];
  getGroupMembers() async {
    await FirebaseFirestore.instance
        .collection("groups")
        .doc(widget.groupChatId)
        .get()
        .then((value) {
      setState(() {
        membersList = value["members"];
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGroupMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.black,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 15.0),
                            decoration: const BoxDecoration(
                              //borderRadius: BorderRadius.circular(20.0),
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                            child: const Icon(
                              Icons.group,
                              color: Colors.white,
                              size: 45.0,
                            ),
                          ),
                          const SizedBox(width: 15.0),
                          Expanded(
                              child: Text(
                            widget.name,
                            style: const TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          )),
                        ],
                      ),
                      const SizedBox(height: 15.0),
                      Text(
                        "${membersList.length}Members",
                        style: const TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.w500),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: membersList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(Icons.account_circle),
                            title: Text(membersList[index]["name"]),
                            subtitle: Text(membersList[index]["email"]),
                            trailing: Text(
                                membersList[index]["admin"] ? "Admin" : ""),
                          );
                        },
                      ),
                      const SizedBox(height: 10.0),
                      ListTile(
                        onTap: () {},
                        leading: const Icon(
                          Icons.logout,
                          color: Colors.red,
                        ),
                        contentPadding: const EdgeInsets.only(left: 5.0),
                        title: const Text(
                          "Leave group ",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const CircularProgressIndicator(),
    );
  }
}
