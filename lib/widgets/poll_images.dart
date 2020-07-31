import 'package:flutter/material.dart';

import '../screens/poll_gallery_screen.dart';

class PollImages extends StatelessWidget {
  final reference;
  final List images;
  final bool isClickable;

  PollImages(this.images, this.reference, {this.isClickable = true});

  void _toGallery(context, position) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PollGalleryScreen(
          reference: reference,
          galleryItems: images,
          initialIndex: position,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width =
        (MediaQuery.of(context).size.width - 52 - (5 * images.length)) /
            images.length;
    if (images.length == 1) {
      return Align(
        alignment: Alignment.center,
        child: InkWell(
          onTap: () => isClickable ? _toGallery(context, 0) : null,
          child: Hero(
            tag: images[0],
            child: Container(
              width: 144,
              height: 144,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black),
                  image: DecorationImage(
                    image: NetworkImage(images[0]),
                    fit: BoxFit.cover,
                  )),
            ),
          ),
        ),
      );
    } else if (images.length == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InkWell(
            onTap: () => isClickable ? _toGallery(context, 0) : null,
            child: Hero(
              tag: images[0],
              child: Container(
                width: width,
                height: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                  ),
                  border: Border.all(color: Colors.black),
                  image: DecorationImage(
                    image: NetworkImage(images[0]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 5),
          InkWell(
            onTap: () => isClickable ? _toGallery(context, 1) : null,
            child: Hero(
              tag: images[1],
              child: Container(
                width: width,
                height: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  border: Border.all(color: Colors.black),
                  image: DecorationImage(
                    image: NetworkImage(images[1]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          )
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InkWell(
            onTap: () => isClickable ? _toGallery(context, 0) : null,
            child: Hero(
              tag: images[0],
              child: Container(
                width: width,
                height: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                  ),
                  border: Border.all(color: Colors.black),
                  image: DecorationImage(
                    image: NetworkImage(images[0]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 5),
          InkWell(
            onTap: () => isClickable ? _toGallery(context, 1) : null,
            child: Hero(
              tag: images[1],
              child: Container(
                width: width,
                height: width,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  image: DecorationImage(
                    image: NetworkImage(images[1]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 5),
          InkWell(
            onTap: () => isClickable ? _toGallery(context, 2) : null,
            child: Hero(
              tag: images[2],
              child: Container(
                width: width,
                height: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  border: Border.all(color: Colors.black),
                  image: DecorationImage(
                    image: NetworkImage(images[2]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          )
        ],
      );
    }
  }
}
