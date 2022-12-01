import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_wordpress_app/models/Article.dart';
import 'package:share/share.dart';

Widget articleBox(BuildContext context, Article article, String heroId) {
  return ConstrainedBox(
    constraints: new BoxConstraints(
      maxHeight: 80.0,
    ),
    child: Stack(
      children: <Widget>[
        Container(
          alignment: Alignment.bottomRight,
          child: Card(
            elevation: 10,
            child: Padding(
              padding: EdgeInsets.fromLTRB(105, 0, 0, 0),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Html(
                      data: article.title!.length > 75
                          ? "<h2>" +
                              article.title!.substring(0, 75) +
                              "...</h2>"
                          : "<h2>" + article.title.toString() + "</h2>",
                      style: {
                        "h2": Style(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: FontSize.em(0.6),
                          padding: EdgeInsets.fromLTRB(25, 0, 0, 0),
                        )
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(0, 57, 4, 0),
          alignment: Alignment.topLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    color: Color(0xFFE3E3E3),
                    borderRadius: BorderRadius.circular(3)),
                padding: EdgeInsets.fromLTRB(3, 3, 3, 3),
                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Text(
                  article.category.toString(),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 7,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ),
        Container(
            padding: const EdgeInsets.fromLTRB(230, 59, 0, 0),
            child: Row(children: <Widget>[
              Icon(
                Icons.timer,
                color: Colors.black45,
                size: 10.0,
              ),
              Text(
                article.date.toString(),
                style:TextStyle(fontSize:10),
                textAlign: TextAlign.left,
              ),
            ])),
        Padding(
          padding: const EdgeInsets.fromLTRB(310, 45, 0, 0),
          child: IconButton(
            icon: Icon(Icons.share, color: Colors.black45, size: 15.0),
            onPressed: () {
              Share.share(article.link.toString());
            },
          ),
        ),
        SizedBox(
          height: 80,
          width: 145,
          child: Card(
            color: Colors.red,
            child: Hero(
              tag: heroId,
              child: ClipRRect(
                borderRadius: new BorderRadius.circular(8.0),
                child: Image.network(
                  article.image.toString(),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 0,
            margin: EdgeInsets.all(10),
          ),
        ),
        article.video != ""
            ? Positioned(
                left: 12,
                top: 12,
                child: Card(
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.transparent,
                    child: Image.asset("assets/play-button.png"),
                  ),
                  elevation: 8,
                  shape: CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                ),
              )
            : Container(),
      ],
    ),
  );
}
