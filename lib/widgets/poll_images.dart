import 'package:flutter/material.dart';

import '../screens/poll_gallery_screen.dart';

class PollImages extends StatelessWidget {
  final String reference;
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

  Widget _image(size, image) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        border: Border.all(color: Colors.black),
        image: DecorationImage(
          image: NetworkImage(image),
          fit: BoxFit.cover,
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
          child: isClickable
              ? InkWell(
                  onTap: () => _toGallery(context, 0),
                  child: Hero(
                      tag: '$images[0]$reference',
                      child: _image(
                        144.0,
                        images[0],
                      )),
                )
              : _image(144.0, images[0]));
    } else if (images.length == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          isClickable
              ? InkWell(
                  onTap: () => _toGallery(context, 0),
                  child: Hero(
                    tag: '$images[0]$reference',
                    child: _image(
                      width,
                      images[0],
                    ),
                  ),
                )
              : _image(
                  width,
                  images[0],
                ),
          SizedBox(width: 5),
          isClickable
              ? InkWell(
                  onTap: () => _toGallery(context, 1),
                  child: Hero(
                    tag: '$images[1]$reference',
                    child: _image(
                      width,
                      images[1],
                    ),
                  ),
                )
              : _image(
                  width,
                  images[1],
                ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          isClickable
              ? InkWell(
                  onTap: () => _toGallery(context, 0),
                  child: Hero(
                    tag: '$images[0]$reference',
                    child: _image(
                      width,
                      images[0],
                    ),
                  ),
                )
              : _image(
                  width,
                  images[0],
                ),
          SizedBox(width: 5),
          isClickable
              ? InkWell(
                  onTap: () => _toGallery(context, 1),
                  child: Hero(
                    tag: '$images[1]$reference',
                    child: _image(
                      width,
                      images[1],
                    ),
                  ),
                )
              : _image(
                  width,
                  images[1],
                ),
          SizedBox(width: 5),
          isClickable
              ? InkWell(
                  onTap: () => _toGallery(context, 2),
                  child: Hero(
                    tag: '$images[2]$reference',
                    child: _image(
                      width,
                      images[2],
                    ),
                  ),
                )
              : _image(
                  width,
                  images[2],
                ),
        ],
      );
    }
  }
}
