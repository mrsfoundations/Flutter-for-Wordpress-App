import 'package:flutter/material.dart';
import 'package:flutter_wordpress_app/common/constants.dart';
import 'package:flutter_wordpress_app/pages/articles.dart';
import 'package:flutter_wordpress_app/pages/local_articles.dart';
import 'package:flutter_wordpress_app/pages/search.dart';
import 'package:flutter_wordpress_app/pages/settings.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = [
    Articles(),
    Search(),
    LocalArticles(),
    Settings(),
  ];

  @override
  void initState() {
    super.initState();
  }

  var isLoaded = false;
  BannerAd? bannerAd;
  InterstitialAd? interstitialAd;

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
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Expanded(child: _widgetOptions.elementAt(_selectedIndex)),
            isLoaded?Container(
              height: 50,
              child: AdWidget(ad: bannerAd!,),):SizedBox(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedLabelStyle:
          TextStyle(fontWeight: FontWeight.w500, fontFamily: "Soleil"),
          unselectedLabelStyle: TextStyle(fontFamily: "Soleil"),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Categories'),
            BottomNavigationBarItem(
                icon: Icon(Icons.flare), label: PAGE2_CATEGORY_NAME),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'More'),
          ],
          currentIndex: _selectedIndex,
          fixedColor: Theme.of(context).primaryColor,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}