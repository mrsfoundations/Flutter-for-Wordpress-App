import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_wordpress_app/pages/authentication/email/login.dart';
import 'package:flutter_wordpress_app/pages/home.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'firebase_options.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

final auth = FirebaseAuth.instance;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,);
  MobileAds.instance.initialize();
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
      theme: ThemeData(

      ),
      home: AnimatedSplashScreen(
          splashIconSize: 120,
          duration: 1500,
          splash:"assets/thiral-icon.png",
          nextScreen: auth.currentUser == null? const LoginScreen() : MyHomePage(),
          splashTransition: SplashTransition.fadeTransition,
          backgroundColor: Colors.lightBlueAccent),
    );
  }
  Future<void> initPlateformState()async{
    OneSignal.shared.setAppId(oneSignalAppId);
  }
}



