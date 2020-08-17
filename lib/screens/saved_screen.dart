import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../widgets/saved_list.dart';

class SavedScreen extends StatelessWidget {
  static const routeName = '/saved';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Guardados'),
      ),
      body: SavedList(_playVideo),
    );
  }
}
