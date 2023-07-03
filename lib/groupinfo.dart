import 'package:flutter/material.dart';

class GroupInfo extends StatefulWidget {
  const GroupInfo({super.key});

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
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
      body: SafeArea(
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
                        child: Container(
                      child: const Text(
                        "Group Name",
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                    )),
                  ],
                ),
                const SizedBox(height: 15.0),
                const Text(
                  "60 Members",
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 20,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.account_circle),
                      title: Text("User 1 $index"),
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
      ),
    );
  }
}
