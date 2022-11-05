import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;
import 'package:flutter/material.dart';
import 'package:flutter_wordpress_app/common/constants.dart';
import 'package:flutter_wordpress_app/models/Article.dart';
import 'package:flutter_wordpress_app/pages/settings.dart';
import 'package:flutter_wordpress_app/pages/single_Article.dart';
import 'package:flutter_wordpress_app/widgets/articleBox.dart';
import 'package:flutter_wordpress_app/widgets/articleBoxFeatured.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'authentication/email/login.dart';
void main() async {
  runApp(Articles());
}

class Articles extends StatefulWidget {
  @override
  _ArticlesState createState() => _ArticlesState();
}

class _ArticlesState extends State<Articles> {
  List<dynamic> featuredArticles = [];
  List<dynamic> latestArticles = [];
  Future<List<dynamic>>? _futureLastestArticles;
  Future<List<dynamic>>? _futureFeaturedArticles;
  ScrollController? _controller;
  int page = 1;
  bool _infiniteStop = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {

    super.dispose();
    _controller!.dispose();
  }

  Future<List<dynamic>> fetchLatestArticles(int page) async {
    try {
      var response = await http.get(Uri.parse(
          '$WORDPRESS_URL/wp-json/wp/v2/posts/?page=$page&per_page=10&_fields=id,date,title,content,custom,link'));
      if (this.mounted) {
        if (response.statusCode == 200) {
          setState(() {
            latestArticles.addAll(json
                .decode(response.body)
                .map((m) => Article.fromJson(m))
                .toList());
            if (latestArticles.length % 10 != 0) {
              _infiniteStop = true;
            }
          });
          return latestArticles;
        }
        setState(() {
          _infiniteStop = true;
        });
      }
    } on SocketException {
      throw 'No Internet connection';
    }
    return latestArticles;
  }

  Future<List<dynamic>> fetchFeaturedArticles(int page) async {
    try {
      var response = await http.get(Uri.parse(
          "$WORDPRESS_URL/wp-json/wp/v2/posts/?categories[]=$FEATURED_ID&page=$page&per_page=10&_fields=id,date,title,content,custom,link"));

      if (this.mounted) {
        if (response.statusCode == 200) {
          setState(() {
            featuredArticles.addAll(json
                .decode(response.body)
                .map((m) => Article.fromJson(m))
                .toList());
          });

          return featuredArticles;
        } else {
          setState(() {
            _infiniteStop = true;
          });
        }
      }
    } on SocketException {
      throw 'No Internet connection';
    }
    return featuredArticles;
  }

  _scrollListener() {
    var isEnd = _controller!.offset >= _controller!.position.maxScrollExtent &&
        !_controller!.position.outOfRange;
    if (isEnd) {
      setState(() {
        page += 1;
        _futureLastestArticles = fetchLatestArticles(page);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text("Narasimman"),
              accountEmail: Text("narasimman@gmail.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text(
                  "N",
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text("Profile"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Settings()));
              },
            ),
            ListTile(

              title: Text("Youtube"),
              onTap: () {
                launchYoutube(
                    Url:
                    "https://www.youtube.com/channel/UCgB4uane1_urtf4gyKNJ10A/about");
              },
            ),
            ListTile(
              title: Text("What's App"),
              onTap: () {
                launchWhatsapp(number: "+919790055058", message: "Hi");
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => LoginScreen()));
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Image(
          image: AssetImage('assets/icon.png'),
          height: 45,
        ),
        elevation: 5,
        backgroundColor: Colors.red,
      ),

      body: Container(
        decoration: BoxDecoration(color: Colors.white70),
        child: SingleChildScrollView(
          controller: _controller,
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              featuredPost(_futureFeaturedArticles as Future<List<dynamic>>),
              latestPosts(_futureLastestArticles as Future<List<dynamic>>)
            ],
          ),
        ),
      ),

    );
  }

  Widget latestPosts(Future<List<dynamic>> latestArticles) {
    return FutureBuilder<List<dynamic>>(
      future: latestArticles,
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
              !_infiniteStop ? Container() : Container()
            ],
          );
        } else if (articleSnapshot.hasError) {
          return Container();
        }
        return Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          height: 150,
        );
      },
    );
  }

  Widget featuredPost(Future<List<dynamic>> featuredArticles) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: FutureBuilder<List<dynamic>>(
        future: featuredArticles,
        builder: (context, articleSnapshot) {
          if (articleSnapshot.hasData) {
            if (articleSnapshot.data!.length == 0) return Container();
            return Row(
                children: articleSnapshot.data!.map((item) {
                  final heroId = item.id.toString() + "-featured";
                  return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SingleArticle(item, heroId),
                          ),
                        );
                      },
                      child: articleBoxFeatured(context, item, heroId));
                }).toList());
          } else if (articleSnapshot.hasError) {
            return Container(
              alignment: Alignment.center,
              margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: <Widget>[
                  Image.asset(
                    "assets/no-internet.png",
                    width: 250,
                  ),
                  Text("No Internet Connection."),
                  TextButton.icon(
                    icon: Icon(Icons.refresh),
                    label: Text("Reload"),
                    onPressed: () {
                      _futureLastestArticles = fetchLatestArticles(1);
                      _futureFeaturedArticles = fetchFeaturedArticles(1);
                    },
                  )
                ],
              ),
            );
          }
          return Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            height: 280,
          );
        },
      ),
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
      throw"Could't Launch $url";
    }
  }
}
