import 'package:flutter/material.dart';
import 'package:flutter_wordpress_app/pages/authentication/email/login.dart';
import 'package:flutter_wordpress_app/pages/authentication/phone/phone_number_login.dart';
import 'package:flutter_wordpress_app/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = FirebaseAuth.instance;
  String? email;
  String? password;
  //our form key
  final _formkey = GlobalKey<FormState>();
  //editing Controller
  final emailEditingController = new TextEditingController();
  final PasswordEditingController = new TextEditingController();
  @override

  Widget build(BuildContext context) {
    //Email Id Field
    final emailField = TextFormField(
      onChanged: (value) {
        email = value;
      },
      autofocus: false,
      //validation:{} {},
      onSaved: (value) {},
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefix: Icon(Icons.mail),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Email",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    //Password Field
    final PasswordField = TextFormField(
      onChanged: (value) {
        password = value;
      },
      autofocus: false,
//validation:{} {},
      onSaved: (value) {},
      obscureText: true,
      decoration: InputDecoration(
        prefix: Icon(Icons.vpn_key),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Password",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    //Sign-up
    final SignupButton = Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(30),
        child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () async {
            print(email);
            print(password);
            try {
              final newUser = await _auth.createUserWithEmailAndPassword(
                  email: email!, password: password!);
              print(newUser);
              if (newUser != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) =>MyHomePage(),
                  ),
                );
              }
              else{
                print('newUser is null');
              }
            }catch(e){
              print(e);
            }
           },
            child: Text(
              "Register",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
            )
        )
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
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
                      SizedBox(height: 25),
                      SignupButton,
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("If You Already Have a Account"),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()));
                            },
                            child: Text(
                              "Log-in",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          )
                        ],
                      ),
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }
}