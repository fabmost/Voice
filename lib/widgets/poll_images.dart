import 'package:cached_network_image/cached_network_image.dart';
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

  Widget _image(size, String image, pos) {
    final newImage = image.contains('firebasestorage')
        ? image
        : image.replaceAll('https', 'http');
    Radius topLeft = pos == 0 ? Radius.circular(24) : Radius.zero;
    Radius topRight = ((pos == 0 && images.length == 1) ||
            (pos == 1 && images.length == 2) ||
            (pos == 2 && images.length == 3))
        ? Radius.circular(24)
        : Radius.zero;
    Radius bottomLeft = pos == 0 ? Radius.circular(24) : Radius.zero;
    Radius bottomRight = ((pos == 0 && images.length == 1) ||
            (pos == 1 && images.length == 2) ||
            (pos == 2 && images.length == 3))
        ? Radius.circular(24)
        : Radius.zero;
    return CachedNetworkImage(
      imageUrl: newImage,
      imageBuilder: (context, imageProvider) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: topLeft,
            topRight: topRight,
            bottomLeft: bottomLeft,
            bottomRight: bottomRight,
          ),
          border: Border.all(color: Colors.black),
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      progressIndicatorBuilder: (context, url, downloadProgress) => Container(
        height: size,
        width: size,
        alignment: Alignment.center,
        child: CircularProgressIndicator(value: downloadProgress.progress),
      ),
      errorWidget: (context, url, error) => Container(
        height: size,
        width: size,
        child: Center(
          child: Text('Ocurrió un error al cargar la imagen $error'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width =
        (MediaQuery.of(context).size.width - 52 - (5 * images.length)) /
            images.length;
    double widthSingle = MediaQuery.of(context).size.width / 3 * 2;
    if (images.length == 1) {
      return Align(
          alignment: Alignment.center,
          child: isClickable
              ? InkWell(
                  onTap: () => _toGallery(context, 0),
                  child: Hero(
                      tag: '${images[0]}$reference',
                      child: _image(widthSingle, images[0], 0)),
                )
              : _image(
                  widthSingle,
                  images[0],
                  0,
                ));
    } else if (images.length == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          isClickable
              ? InkWell(
                  onTap: () => _toGallery(context, 0),
                  child: Hero(
                    tag: '${images[0]}$reference',
                    child: _image(
                      width,
                      images[0],
                      0,
                    ),
                  ),
                )
              : _image(
                  width,
                  images[0],
                  0,
                ),
          SizedBox(width: 5),
          isClickable
              ? InkWell(
                  onTap: () => _toGallery(context, 1),
                  child: Hero(
                    tag: '${images[1]}$reference',
                    child: _image(
                      width,
                      images[1],
                      1,
                    ),
                  ),
                )
              : _image(
                  width,
                  images[1],
                  1,
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
                    tag: '${images[0]}$reference',
                    child: _image(
                      width,
                      images[0],
                      0,
                    ),
                  ),
                )
              : _image(
                  width,
                  images[0],
                  0,
                ),
          SizedBox(width: 5),
          isClickable
              ? InkWell(
                  onTap: () => _toGallery(context, 1),
                  child: Hero(
                    tag: '${images[1]}$reference',
                    child: _image(
                      width,
                      images[1],
                      1,
                    ),
                  ),
                )
              : _image(
                  width,
                  images[1],
                  1,
                ),
          SizedBox(width: 5),
          isClickable
              ? InkWell(
                  onTap: () => _toGallery(context, 2),
                  child: Hero(
                    tag: '${images[2]}$reference',
                    child: _image(
                      width,
                      images[2],
                      2,
                    ),
                  ),
                )
              : _image(
                  width,
                  images[2],
                  2,
                ),
        ],
      );
    }
  }
}
