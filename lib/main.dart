import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_wordpress_app/pages/authentication/email/login.dart';
import 'package:flutter_wordpress_app/pages/home.dart';
import 'firebase_options.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

final auth = FirebaseAuth.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,);
      runApp(OneSignalScreen());
}
class OneSignalScreen extends StatefulWidget {
  const OneSignalScreen({Key? key}) : super(key: key);

  @override
  _OneSignalScreenState createState() => _OneSignalScreenState();
}

class _OneSignalScreenState extends State<OneSignalScreen> {
  @override
  void initState(){
    super.initState();
    initPlateformState();
  }
  static final String oneSignalAppId="40fadcd5-0010-42b7-9d90-8487b8421490";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: App(),
    );
  }
  Future<void> initPlateformState()async{
    OneSignal.shared.setAppId(oneSignalAppId);
  }
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(// Initialize FlutterFire
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // Check for errors

          return MyApp();
        }
        // Otherwise, show something whilst waiting for initialization to complete
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: auth.currentUser == null? const LoginScreen() : MyHomePage(),
    );
  }
}


