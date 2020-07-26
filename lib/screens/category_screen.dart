import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../widgets/filtered_content.dart';

class CategoryScreen extends StatelessWidget {
  static const routeName = '/category';
  VideoPlayerController _controller;

  void _playVideo(VideoPlayerController controller) {
    if (_controller != null) {
      _controller.pause();
    }
    _controller = controller;
    //stopVideo(_controller);
  }

  @override
  Widget build(BuildContext context) {
    String category = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: FilteredContent(category, _playVideo),
    );
  }
}
