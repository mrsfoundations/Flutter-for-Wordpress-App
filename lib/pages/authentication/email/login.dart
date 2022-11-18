import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_wordpress_app/pages/authentication/email/register.dart';
import 'package:flutter_wordpress_app/pages/authentication/phone/phone_number_login.dart';
import 'package:flutter_wordpress_app/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      color: Colors.white,
        elevation: 5,
        borderRadius: BorderRadius.circular(10),
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
            "Sign-In",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
            )
          )
    );
    final signInWithGoogle= Material(

      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      child:IconButton(
        icon: FaIcon(FontAwesomeIcons.google),
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

    final Phonenumber = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
        child:IconButton(
      icon: FaIcon(FontAwesomeIcons.phone),
          onPressed: () { Navigator.push(
              context,
              MaterialPageRoute(
              builder: (context) => phonenumber())); },),
    );

    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.cyanAccent,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Form(
                key: _formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("Welcome",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 45),),
                    Container(
                      height: 100,
                        child: Image.asset("assets/User_Avathar.png",height: 100,)),
                    SizedBox(height: 15),
                    emailField,
                    SizedBox(height: 15),
                    PasswordField,
                    SizedBox(height: 15,width:10),
                    LoginButton,

                    Text("Or",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 1, 0),
                          child: SizedBox(height: 15),
                        ),
                        signInWithGoogle,
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                          child: SizedBox(height: 25),
                        ),
                        Phonenumber,
                      ],
                    ),
                    SizedBox(height: 6,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Need a account?",style: TextStyle(fontSize:16 ),),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignupScreen()));
                          },
                          child: Text(
                            "Sign-Up",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                      ],
                    ),
            ]),
          ),
        ),
      ),
    ));
  }
}