import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../providers/preferences_provider.dart';

class VideoTutorial extends StatefulWidget {
  final String shared;
  final String videoAsset;
  final bool fromStart;

  VideoTutorial(this.shared, this.videoAsset, this.fromStart);

  @override
  _VideoTutorialState createState() => _VideoTutorialState();
}

class _VideoTutorialState extends State<VideoTutorial> {
  VideoPlayerController _controller;
  bool _isChecked = false;

  void _startVideo() {
    _controller = VideoPlayerController.asset(widget.videoAsset)
      ..addListener(() {
        if (_controller.value.duration == _controller.value.position) {
          _closeVideo();
        }
      })
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
          _controller.play();
        });
      });
  }

  void _closeVideo() async {
    if (_isChecked) {
      await Provider.of<Preferences>(context, listen: false)
          .setVideoKey(widget.shared);
    }
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    _startVideo();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (_controller != null) _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          const SizedBox(height: 16),
          if (_controller != null && _controller.value.initialized)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
          const SizedBox(height: 8),
          if (widget.fromStart)
            CheckboxListTile(
              title: Text(
                'No volver a mostrar',
                style: TextStyle(color: Colors.white),
              ),
              value: _isChecked,
              onChanged: (value) {
                setState(() {
                  _isChecked = value;
                });
              },
            ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: RaisedButton(
              child: Text('Cerrar'),
              textColor: Colors.white,
              onPressed: _closeVideo,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
