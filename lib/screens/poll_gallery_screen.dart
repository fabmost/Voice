import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PollGalleryScreen extends StatefulWidget {
  static const String routeName = '/poll-gallery';

  final List galleryItems;
  final PageController pageController;
  final int initialIndex;
  final DocumentReference reference;
  final String userId;

  PollGalleryScreen(
      {this.reference, this.userId, this.galleryItems, this.initialIndex})
      : pageController = PageController(initialPage: initialIndex);

  @override
  _PhotoGalleryScreenState createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PollGalleryScreen> {
  int currentIndex;

  @override
  void initState() {
    currentIndex = widget.initialIndex;
    super.initState();
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (ctx, i) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(widget.galleryItems[i]),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 1.2,
                heroAttributes:
                    PhotoViewHeroAttributes(tag: widget.galleryItems[i]),
              );
            },
            itemCount: widget.galleryItems.length,
            backgroundDecoration: BoxDecoration(
              color: Colors.black,
            ),
            pageController: widget.pageController,
            onPageChanged: onPageChanged,
            scrollDirection: Axis.horizontal,
          )
        ],
      ),
    );
  }
}
