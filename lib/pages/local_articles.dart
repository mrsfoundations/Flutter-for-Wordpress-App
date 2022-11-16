import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_wordpress_app/common/constants.dart';
import 'package:flutter_wordpress_app/models/Article.dart';
import 'package:flutter_wordpress_app/pages/filepicker.dart';
import 'package:flutter_wordpress_app/pages/settings.dart';
import 'package:flutter_wordpress_app/pages/single_Article.dart';
import 'package:flutter_wordpress_app/pages/timeline_news.dart';
import 'package:flutter_wordpress_app/widgets/articleBox.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'authentication/email/login.dart';


class LocalArticles extends StatefulWidget {
  @override
  _LocalArticlesState createState() => _LocalArticlesState();
}

class _LocalArticlesState extends State<LocalArticles> {
  List<dynamic> articles = [];
  Future<List<dynamic>>? _futureArticles;

  ScrollController? _controller;
  int page = 1;
  bool _infiniteStop = false;

  @override
  void initState() {
    super.initState();
    _futureArticles = fetchLocalArticles(1);
    _controller =
        ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);
    _controller!.addListener(_scrollListener);
    _infiniteStop = false;
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  Future<List<dynamic>> fetchLocalArticles(int page) async {
    try {
      http.Response response = await http.get(Uri.parse(
          "$WORDPRESS_URL/wp-json/wp/v2/posts/?categories[]=$PAGE2_CATEGORY_ID&page=$page&per_page=10&_fields=id,date,title,content,custom,link"));
      if (this.mounted) {
        if (response.statusCode == 200) {
          setState(() {
            articles.addAll(json
                .decode(response.body)
                .map((m) => Article.fromJson(m))
                .toList());
            if (articles.length % 10 != 0) {
              _infiniteStop = true;
            }
          });

          return articles;
        }
        setState(() {
          _infiniteStop = true;
        });
      }
    } on SocketException {
      throw 'No Internet connection';
    }

    return articles;
  }

  _scrollListener() {
    var isEnd = _controller!.offset >= _controller!.position.maxScrollExtent &&
        !_controller!.position.outOfRange;
    if (isEnd) {
      setState(() {
        page += 1;
        _futureArticles = fetchLocalArticles(page);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          PAGE2_CATEGORY_NAME,
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
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            controller: _controller,
            child: Column(
              children: <Widget>[
                categoryPosts(_futureArticles as Future<List<dynamic>>),

              ],
            )),
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          children: <Widget>[
            DrawerHeader(
              child:Text("VMT_WordPress",
                style:TextStyle(fontSize: 25),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text("Profile"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Settings()));
              },
            ),
            ListTile(
              leading:  Image.asset('assets/Whatsapp_icon.png',height: 25,),
              title: Text("What's App"),
              onTap: () {
                launchWhatsapp(number: "+919790055058", message: "Hi");
              },
            ),
            ListTile(
              leading:  Image.asset('assets/Youtubeicon.png',width: 25,),
              title: Text("Youtube"),
              onTap: () {
                launchYoutube(
                    Url:
                    "https://www.youtube.com/channel/UCgB4uane1_urtf4gyKNJ10A/about");
              },
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text("Share This App"),
              onTap: () {
                Share.share(
                    'https://github.com/mrsfoundations/Flutter-for-Wordpress-App');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget categoryPosts(Future<List<dynamic>> futureArticles) {
    return FutureBuilder<List<dynamic>>(
      future: futureArticles,
      builder: (context, articleSnapshot) {
        if (articleSnapshot.hasData) {
          if (articleSnapshot.data!.length == 0) return Container();
          return Column(
            children: <Widget>[
              Column(
                  children: articleSnapshot.data!.map((item) {
                final heroId = item.id.toString() + "-latest";
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SingleArticle(item, heroId),
                      ),
                    );
                  },
                  child: articleBox(context, item, heroId),
                );
              }).toList()),
              !_infiniteStop
                  ? Container(
                      alignment: Alignment.center,
                      height: 30,
                    )
                  : Container()
            ],
          );
        } else if (articleSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (articleSnapshot.hasError) {
          return Container();
        }
        return Container(
          alignment: Alignment.center,
          height: 400,
          width: MediaQuery.of(context).size.width - 30,
        );
      },
    );
  }

  void launchWhatsapp({@required number, @required message}) async {
    String url = "whatsapp://send?phone=$number&text=$message";
    await launchUrlString(url) ? (url) : print("can't open whatsapp");
  }

  void launchYoutube({required String Url}) async {
    var url = Uri.parse(
        "https://www.youtube.com/channel/UCgB4uane1_urtf4gyKNJ10A/about");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw "Could't Launch $url";
    }
  }
}
