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
          heightFactor: 0.65,
          child: Container(
            width: double.infinity,
            child: Image.asset(
              img,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: 0.55,
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
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 22),
                  Expanded(
                    child: AutoSizeText(
                      content,
                      style: TextStyle(fontSize:42),
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
