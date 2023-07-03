import 'package:chatapp/createaccount.dart';
import 'package:chatapp/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RegExp regExp =
      RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text(
                "WELCOME",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text("Sign In to Continue!"),
            ),
            const SizedBox(height: 50.0),
            emailField(),
            const SizedBox(height: 5.0),
            passwordField(),
            const SizedBox(height: 10.0),
            loginButton(),
            const SizedBox(height: 5.0),
            Center(
                child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateAccount()));
              },
              child: const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget emailField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: emailcontroller,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter email";
          } else if (!regExp.hasMatch(value)) {
            return "Enter valid email";
          }
          return null;
        },
        decoration: const InputDecoration(
            hintText: "email",
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)))),
      ),
    );
  }

  Widget passwordField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: passwordcontroller,
        obscureText: false,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter password";
          } else if (value.length <= 6) {
            return "Password must have atleast 7 characters";
          }
          return null;
        },
        decoration: const InputDecoration(
          hintText: "password",
          prefixIcon: Icon(Icons.password),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
        ),
      ),
    );
  }

  Widget loginButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: double.infinity,
          height: 50.0,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onPressed: () {
              signInMethod(emailcontroller.text, passwordcontroller.text);
            },
            child: const Text(
              "Login",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future signInMethod(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await firebaseAuth
            .signInWithEmailAndPassword(email: email, password: password);
        Fluttertoast.showToast(msg: "Login Successfully");
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
            (route) => false);

        // Navigator.pushReplacement(
        //     context, MaterialPageRoute(builder: (_) => const Home()));
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
      }
    }
  }
}
