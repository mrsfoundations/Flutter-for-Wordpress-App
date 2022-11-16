import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_custom_carousel_slider/flutter_custom_carousel_slider.dart';
import 'package:flutter_wordpress_app/pages/single_Article.dart';
import 'package:timelines/timelines.dart';
import 'package:http/http.dart' as http;
import '../common/constants.dart';
import '../models/Article.dart';
import '../widgets/articleBox.dart';

class TimeLineNews extends StatefulWidget {
  const TimeLineNews({Key? key}) : super(key: key);

  @override
  _TimeLineNewsState createState() => _TimeLineNewsState();
}

class _TimeLineNewsState extends State<TimeLineNews> {
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
          title: Text("TimeLine"),
        ),
        body: Timeline.tileBuilder(
            builder: TimelineTileBuilder.fromStyle(
          contentsAlign: ContentsAlign.reverse,
          contentsBuilder: (context, index) => Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ConstrainedBox(
                constraints: new BoxConstraints(
                  maxHeight: 400.0,
                ),
                child: Stack(
                  children: <Widget>[
                    latestPosts(_futureLastestArticles as Future<List<dynamic>>)
                  ],
                ),
              ),
            ),
          ),
          itemCount: 5,
        )));
  }

  Widget latestPosts(Future<List<dynamic>> latestArticles) {
    return FutureBuilder<List<dynamic>>(
      future: latestArticles,
      builder: (context, articleSnapshot) {
        if (articleSnapshot.hasData) {
          if (articleSnapshot.data!.length == 0) return Container();
          return Column(
            children: <Widget>[
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
