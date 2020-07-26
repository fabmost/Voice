import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PollVideo extends StatefulWidget {
  final String videoUrl;
  final String videoThumb;
  final Function _playVideo;

  PollVideo(
    this.videoThumb,
    this.videoUrl,
    this._playVideo,
  );

  @override
  _PollVideoState createState() => _PollVideoState();
}

class _PollVideoState extends State<PollVideo> {
  VideoPlayerController _controller;
  ChewieController _chewieController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (_controller != null) _controller.dispose();
    if (_chewieController != null) _chewieController.dispose();
  }

  void _startVideo() {
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        if (widget._playVideo != null) widget._playVideo(_controller);
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
          _isPlaying = true;
          _controller.play();
          _chewieController = ChewieController(
            videoPlayerController: _controller,
            aspectRatio: _controller.value.aspectRatio,
            autoPlay: true,
            looping: false,
          );
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
            //_isPlaying = !_controller.value.isPlaying;
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
              if (!_isPlaying)
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 18,
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.black,
                    size: 32,
                  ),
                ),
              if (_chewieController != null &&
                  _controller != null &&
                  _controller.value.initialized)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Chewie(
                    controller: _chewieController,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
