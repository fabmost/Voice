import 'dart:typed_data';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class PollVideo extends StatefulWidget {
  final String videoUrl;
  final Function _playVideo;

  PollVideo(
    this.videoUrl,
    this._playVideo,
  );

  @override
  _PollVideoState createState() => _PollVideoState();
}

class _PollVideoState extends State<PollVideo> {
  VideoPlayerController _controller;
  ChewieController _chewieController;
  Uint8List _thumbnailTemp;
  bool _isPlaying = false;

  void _getThumbnail() async {
    //int width = MediaQuery.of(context).size.width.floor();
    final mFile = await VideoThumbnail.thumbnailData(
      video: widget.videoUrl,
      quality: 50,
    );
    setState(() {
      _thumbnailTemp = mFile;
    });
  }

  @override
  void initState() {
    _getThumbnail();
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
                  : _thumbnailTemp != null
                      ? Image.memory(_thumbnailTemp)
                      : Center(child: CircularProgressIndicator()),
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
