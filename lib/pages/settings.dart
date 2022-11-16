import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'More',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: 'Poppins'),
        ),
        elevation: 5,
        backgroundColor: Colors.red,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
              child: Image(
                image: AssetImage('assets/icon.png'),
                height: 50,
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
              child: Text(
                "Version 2.0.0 \n github.com/mrsfoundations/Flutter-for-Wordpress-App \n Demo flutter app for wordpress news website",
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.6, color: Colors.black87),
              ),
            ),
            Divider(
              height: 10,
            ),
            ListView(shrinkWrap: true, children: <Widget>[
              ListTile(
                title: Text('Contact'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        launchWhatsapp(
                            number: "+919790055058", message: "Hi");
                      },
                      child: Text("WhatsApp",style: TextStyle(color: Colors.black54),
                    )),
                    TextButton(
                        onPressed: () {
                        launchYoutube(
                            Url: "https://www.youtube.com/channel/UCgB4uane1_urtf4gyKNJ10A/about");
                      },
                      child: Text("YouTube",style: TextStyle(color: Colors.black54),
                      )),
                  ],
                ),
              ),
              Divider(
                height: 5,
              ),
              InkWell(
                onTap: () {
                  Share.share(
                      'https://github.com/mrsfoundations/Flutter-for-Wordpress-App');
                },
                child: ListTile(
                  title: Text('Share'),
                  subtitle: Text("Spread the words of flutter blog VMT_Wordpress"),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
  void launchWhatsapp({@required number, @required message}) async {
    String url = "whatsapp://send?phone=$number&text=$message";
    await launchUrlString(url) ? (url) : print("can't open whatsapp");
  }

  void launchYoutube({required String Url}) async{
    var url = Uri.parse("https://www.youtube.com/channel/UCgB4uane1_urtf4gyKNJ10A/about");
    if(await canLaunchUrl(url)){
      await launchUrl(url);
    }else{
      throw"Could't Launch $url";
    }
  }
}

