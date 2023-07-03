import 'package:chatapp/home.dart';
import 'package:chatapp/loginpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final RegExp regExp =
      RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$');
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  )),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ))),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            textToWritten("Welcome", 20.0),
            textToWritten("Sign Up To Continue!", 15.0),
            const SizedBox(height: 50.0),
            nameField(),
            const SizedBox(height: 5.0),
            emailField(),
            const SizedBox(height: 5.0),
            passwordField(),
            const SizedBox(height: 5.0),
            signUpButton(),
          ],
        ),
      ),
    );
  }

  Widget emailField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        controller: emailController,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter email";
          } else if (!regExp.hasMatch(value)) {
            return "Please enter valid Email";
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: "Email",
          prefixIcon: const Icon(Icons.email),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Widget passwordField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: passwordController,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter Password";
          } else if (value.length <= 6) {
            return "Password must have atleast 7 characters";
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: "Password",
          prefixIcon: const Icon(Icons.password),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Widget nameField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: nameController,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter Name";
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: "Name",
          prefixIcon: const Icon(Icons.person),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Widget textToWritten(String text, double size) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: size, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget signUpButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        height: 50.0,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              backgroundColor: Colors.blueAccent,
            ),
            onPressed: () {
              // if (_formKey.currentState!.validate()) {
              //  signUpButton(email, password);
              // }
              signUpMethod(emailController.text, passwordController.text);
            },
            child: const Text(
              "Sign Up",
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            )),
      ),
    );
  }

  Future<void> signUpMethod(String email, String password) async {
    debugPrint("email : $email");
    if (_formKey.currentState!.validate()) {
      //User? user;
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = FirebaseAuth.instance.currentUser;
      debugPrint("user : ${user!.uid}");
      user.updateDisplayName(nameController.text);

      if (userCredential.user != null) {
        try {
          await firebaseFirestore.collection("users").doc(user.uid).set({
            "name": nameController.text,
            "email": emailController.text,
            "status": "UnAvailable",
            "uid": user.uid,
          }).then((value) {
            Fluttertoast.showToast(msg: "Account created Successfully");
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
                (route) => false);

            // Navigator.pushReplacement(
            //     context, MaterialPageRoute(builder: (context) => const Home()));
          });
        } catch (e) {
          Fluttertoast.showToast(msg: e.toString());
        }
      } else {
        Fluttertoast.showToast(msg: "Something went wrong");
      }
    }
  }
}
