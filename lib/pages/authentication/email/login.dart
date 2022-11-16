import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_wordpress_app/pages/authentication/email/register.dart';
import 'package:flutter_wordpress_app/pages/authentication/phone/phone_number_login.dart';
import 'package:flutter_wordpress_app/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  String? email;
  String? password;
  //our form key
  final _formkey = GlobalKey<FormState>();
  //editing Controller
  final TextEditingController emailController = TextEditingController();
  final TextEditingController PasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    //Email Id Field
    final emailField = TextFormField(
      onChanged: (value) {
        email = value;
      },
      autofocus: false,
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      validator:(value)=>value!.isEmpty? 'Enter an email':null,
      onSaved: (value) {
        emailController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefix: Icon(Icons.mail),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        labelText:"Email",
        hintText: "Email",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    //Password Field
    final PasswordField = TextFormField(
      autofocus: false,
      controller: PasswordController,
      obscureText: true,
      validator:(value)=>value!.length < 6?'':null,
      onChanged: (value) {
        password = value;
      },
      onSaved: (value) {
        PasswordController.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        prefix: Icon(Icons.vpn_key),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        labelText:"Password",
        hintText: "Password",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    //Sign-up
    final LoginButton = Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(30),
        child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: 20,
          onPressed: () async {
            print(email);
            print(password);
            try {
              final oldUser = await _auth.signInWithEmailAndPassword(
                  email: email!, password: password!);
              print(oldUser);
              if (oldUser != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => MyHomePage(),
                  ),
                );
              }
              else{
                print('oldUser is null');
              }
            }catch(e){
              print(e);
            }
            },

          child:const Text(
            "Login",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
            )
          )
    );
    final signInWithGoogle= Material(

      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      child:MaterialButton(
      minWidth:10,
        child: Text('Sign in with Google'),
      onPressed: () async{
        GoogleSignInAccount? googleUser=await GoogleSignIn().signIn();
        GoogleSignInAuthentication? googleAuth=await googleUser?.authentication;
        AuthCredential credential=GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
        UserCredential userCredential=await _auth.signInWithCredential(credential);

        print(userCredential.user?.email);
        if(userCredential.user!=null){
          Navigator.push(context, MaterialPageRoute(builder: (context)=> MyHomePage()));
        }


      },));

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                  key: _formkey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 25),
                      emailField,
                      SizedBox(height: 25),
                      PasswordField,
                      SizedBox(height: 25,width:10),
                      LoginButton,
                      SizedBox(height: 25),
                      signInWithGoogle,

                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("If You Don't Have a Account",style: TextStyle(fontSize:16 ),),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignupScreen()));
                            },
                            child: Text(
                              "Register",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Login With Phone",style: TextStyle(fontSize:16 ),),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => phonenumber()));
                            },
                            child: Icon(Icons.phone,color:Colors.redAccent),
                          )
                        ],
                      )
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }
}