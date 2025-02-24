import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_wordpress_app/common/constants.dart';
import 'package:flutter_wordpress_app/models/Article.dart';
import 'package:flutter_wordpress_app/pages/single_Article.dart';
import 'package:flutter_wordpress_app/widgets/articleBox.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;

class CategoryArticles extends StatefulWidget {
  final int id;
  final String name;
  CategoryArticles(this.id, this.name, {Key? key}) : super(key: key);
  @override
  _CategoryArticlesState createState() => _CategoryArticlesState();
}

class _CategoryArticlesState extends State<CategoryArticles> {
  List<dynamic> categoryArticles = [];
  Future<List<dynamic>>? _futureCategoryArticles;
  ScrollController? _controller;
  int page = 1;
  bool _infiniteStop = false;

  @override
  void initState() {
    super.initState();
    _futureCategoryArticles = fetchCategoryArticles(1);
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

  Future<List<dynamic>> fetchCategoryArticles(int page) async {
    try {
      var response = await http.get(
          Uri.parse("$WORDPRESS_URL/wp-json/wp/v2/posts?categories[]=" +
              widget.id.toString() +
              "&page=$page&per_page=10&_fields=id,date,title,content,custom,link"));

      if (this.mounted) {
        if (response.statusCode == 200) {
          setState(() {
            categoryArticles.addAll(json
                .decode(response.body)
                .map((m) => Article.fromJson(m))
                .toList());
            if (categoryArticles.length % 10 != 0) {
              _infiniteStop = true;
            }
          });

          return categoryArticles;
        }
        setState(() {
          _infiniteStop = true;
        });
      }
    } on SocketException {
      throw 'No Internet connection';
    }
    return categoryArticles;
  }

  _scrollListener() {
    var isEnd = _controller!.offset >= _controller!.position.maxScrollExtent &&
        !_controller!.position.outOfRange;
    if (isEnd) {
      setState(() {
        page += 1;
        _futureCategoryArticles = fetchCategoryArticles(page);
      });
    }
  }
  var isLoaded = false;
  BannerAd? bannerAd;
  InterstitialAd? interstitialAd;
  var clickcount = 0;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    bannerAd=BannerAd(size:AdSize.banner,
        adUnitId:"ca-app-pub-3940256099942544/6300978111",
        listener:BannerAdListener(
            onAdLoaded:(ad){
              setState(() {
                isLoaded=true;
              });
              print("Banner Loaded");
            },
            onAdFailedToLoad:(ad, error) {
              ad.dispose();
            }),
        request: AdRequest()
    );
    bannerAd!.load();

    InterstitialAd.load(
      adUnitId:"ca-app-pub-3940256099942544/1033173712",
      request:AdRequest( ),
      adLoadCallback:InterstitialAdLoadCallback(
        onAdLoaded: (ad){
          setState(() {
            isLoaded=true;
            this.interstitialAd=ad;

          });
          print("Ad");
        },
        onAdFailedToLoad: (error){
          print("Interstitial Ad");
        },
      ),
    );
  }

  void showInterstitial()async{
    interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('Ad Showed'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) =>
          ad.dispose(),
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        Navigator.of(context).pop();
        ad.dispose();
      },
      onAdImpression: (InterstitialAd ad) => print('Impression'),
    );
    interstitialAd?.show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(widget.name,
            textAlign: TextAlign.left,
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: 'Poppins')),
        elevation: 5,
        backgroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: SingleChildScrollView(
            controller: _controller,
            scrollDirection: Axis.vertical,
            child: Column(
                children: <Widget>[categoryPosts(_futureCategoryArticles as Future<List<dynamic>>),
                  isLoaded?Container(
                    height: 50,
                    child: AdWidget(ad: bannerAd!,),):SizedBox(),])),
      ),
    );
  }

  Widget categoryPosts(Future<List<dynamic>> categoryArticles) {
    return FutureBuilder<List<dynamic>>(
      future: categoryArticles,
      builder: (context, articleSnapshot) {
        if (articleSnapshot.hasData) {
          if (articleSnapshot.data!.length == 0) return Container();
          return Column(
            children: <Widget>[
              Column(
                  children: articleSnapshot.data!.map((item) {
                final heroId = item.id.toString() + "-categorypost";
                return InkWell(
                  onTap: () {
                    setState(() {
                      clickcount = clickcount +1 ;
                      if (clickcount > 2) {
                        showInterstitial();
                        clickcount = 0;
                      }
                    });
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
        } else if(articleSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (articleSnapshot.hasError) {
          return Container(
              height: 500,
              alignment: Alignment.center,
              child: Text("${articleSnapshot.error}"));
        }
        return Container(
          alignment: Alignment.center,
          height: 400,
          
        );
      },
    );
  }
}
