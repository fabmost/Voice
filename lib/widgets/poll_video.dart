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
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (_controller != null) _controller.dispose();
  }

  void _startVideo() {
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
          _isPlaying = true;
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
            _isPlaying = !_controller.value.isPlaying;
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        }
      },
      child: Container(
        color: Colors.black,
        child: AspectRatio(
          aspectRatio: (16 / 9),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              (_controller != null && _controller.value.initialized)
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller))
                  : Image.network(widget.videoThumb),
              Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                size: 42,
              ),
              if (_controller != null && _controller.value.initialized)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
