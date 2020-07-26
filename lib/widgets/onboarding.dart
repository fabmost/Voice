import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class OnBoarding extends StatelessWidget {
  final String title;
  final String img;
  final String content;
  final Function next;
  final Function skip;

  OnBoarding(this.title, this.img, this.content, this.next, this.skip);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        FractionallySizedBox(
          heightFactor: 0.5,
          child: Container(
            width: double.infinity,
            color: Color(0xFF581365),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                img,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: 0.5,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  SizedBox(height: 22),
                  Expanded(
                    child: AutoSizeText(
                      content,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                  SizedBox(height: 22),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          height: 52,
                          child: FlatButton(
                            onPressed: skip,
                            child: Text('Omitir'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 52,
                          child: RaisedButton(
                            textColor: Colors.white,
                            onPressed: next,
                            child: Text('Siguiente'),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
