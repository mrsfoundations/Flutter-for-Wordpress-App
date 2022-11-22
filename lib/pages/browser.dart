import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Browser extends StatelessWidget {
  final url;
  Browser(this.url);

  @override
  Widget build(BuildContext context) {
    print(url);
   return Scaffold(
     appBar: AppBar(
       backgroundColor: Colors.red,),
     body:WebView(
        initialUrl: url,
        javascriptMode:  JavascriptMode.unrestricted,
      ),
   );
  }
}
