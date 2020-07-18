import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PollVideo extends StatefulWidget {
  final String videoUrl;
  final String videoThumb;

  PollVideo(this.videoThumb, this.videoUrl);

  @override
  _PollVideoState createState() => _PollVideoState();
}

class _PollVideoState extends State<PollVideo> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _startVideo() {
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
          _controller.play();
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_controller == null) {
          _startVideo();
        } else {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        }
      },
      child: AspectRatio(
        aspectRatio: (16 / 9),
        child: (_controller != null && _controller.value.initialized)
            ? Align(child: VideoPlayer(_controller))
            : Image.network(widget.videoThumb),
      ),
    );
  }
}
