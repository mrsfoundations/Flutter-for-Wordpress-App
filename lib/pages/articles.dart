import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;
import 'package:flutter/material.dart';
import 'package:flutter_custom_carousel_slider/flutter_custom_carousel_slider.dart';
import 'package:flutter_wordpress_app/common/constants.dart';
import 'package:flutter_wordpress_app/models/Article.dart';
import 'package:flutter_wordpress_app/pages/settings.dart';
import 'package:flutter_wordpress_app/pages/single_Article.dart';
import 'package:flutter_wordpress_app/widgets/articleBox.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';
import 'authentication/email/login.dart';
import 'package:url_launcher/url_launcher.dart';

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
  ScrollController? _controller;
  int page = 1;
  bool _infiniteStop = false;

  @override
  void initState() {
    super.initState();
    _futureLastestArticles = fetchLatestArticles(1);
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

  Future<List<dynamic>> fetchLatestArticles(int page) async {
    try {
      var response = await http.get(Uri.parse(
          '$WORDPRESS_URL/wp-json/wp/v2/posts/?page=$page&per_page=10&_fields=id,date,title,content,custom,link'));
      if (this.mounted) {
        if (response.statusCode == 200) {
          latestArticles.addAll(json
              .decode(response.body)
              .map((m) => Article.fromJson(m))
              .toList());

          if (latestArticles.length % 10 != 0) {
            _infiniteStop = true;
          }
          latestArticles.forEach((item) {
            itemList.add(
              CarouselItem(
                image: NetworkImage(
                  item.image,
                ),
                onImageTap: (i) {
                  print(item.link);
                },
              ),
            );
          });

          print(itemList.length);
          setState(() {});
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

  OnRefIndicator(int page) async {
    try {
      var response = await http.get(Uri.parse(
          '$WORDPRESS_URL/wp-json/wp/v2/posts/?page=$page&per_page=10&_fields=id,date,title,content,custom,link'));
      if (this.mounted) {
        if (response.statusCode == 200) {
          latestArticles = (json
              .decode(response.body)
              .map((m) => Article.fromJson(m))
              .toList());

          if (latestArticles.length % 10 != 0) {
            _infiniteStop = true;
          }
          itemList = latestArticles.map((item) {
            return CarouselItem(
              image: NetworkImage(
                item.image,
              ),
              onImageTap: (i) {
                print(item.link);
              },
            );
          }).toList();

          print(itemList.length);
          setState(() {});
        }
      }
    } on SocketException {
      throw 'No Internet connection';
    }
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

  List<CarouselItem> itemList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              // featuredPost(
              //     _futureFeaturedArticles as Future<List<dynamic>>),
              latestPosts(_futureLastestArticles as Future<List<dynamic>>)
            ],
          ),
        ),
      ),
      //Drawer
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Settings()));
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
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
            ),
          ],
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
              CustomCarouselSlider(
                items: itemList,
                height: 150,
                subHeight: 50,
                showSubBackground: false,
                width: MediaQuery.of(context).size.width * .9,
                autoplay: true,
              ),
              RefreshIndicator(
                onRefresh: () async {
                  OnRefIndicator(page);
                },
                child: ListView(
                    shrinkWrap: true,
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
              ),
              !_infiniteStop ? Container() : Container()
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
          width: MediaQuery.of(context).size.width,
          height: 150,
        );
      },
    );
  }
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
