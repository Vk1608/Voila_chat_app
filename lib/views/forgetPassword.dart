import 'package:chat_app/widgets/widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String _email;
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: SingleChildScrollView(
      child: Container(
          height: MediaQuery.of(context).size.height - 150,
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: ExactAssetImage('assets/images/Voila-logo.png'),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Column(
                  children: [
                    Text("Reset Password",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, color: Colors.white))
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Column(children: [
                  TextField(
                      key: Key('Email3'),
                      keyboardType: TextInputType.emailAddress,
                      style: simpleTextStyle(),
                      decoration: textFieldInputDecoration("Email"),
                      onChanged: (value) {
                        setState(() {
                          _email = value.trim();
                        });
                      })
                ]),
                SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Container(
                      margin: const EdgeInsets.only(left: 10, right: 20),
                    )),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    auth.sendPasswordResetEmail(email: _email);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    key: Key('Reset3'),
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          const Color(0xffdc1b22),
                          const Color(0xfff84f4f)
                        ]),
                        borderRadius: BorderRadius.circular(30)),
                    child: Text("Send Reset Link", style: mediumTextStyle()),
                  ),
                ),
              ],
            ),
          )),
    ));
  }
}
