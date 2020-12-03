import 'dart:async';

import 'package:flutter/material.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/story_view.dart';
import 'package:video_player/video_player.dart';

class CustomStoryItem extends StoryItem {
  CustomStoryItem(
    String url, {
    @required StoryController controller,
    Duration duration,
    BoxFit imageFit = BoxFit.fitWidth,
    String caption,
    bool shown = false,
  }) : super(
            Container(
              color: Colors.black,
              child: Stack(
                children: <Widget>[
                  GalupStoryVideo(
                    url: url,
                    storyController: controller,
                  ),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 24),
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        color: caption != null
                            ? Colors.black54
                            : Colors.transparent,
                        child: caption != null
                            ? Text(
                                caption,
                                style: TextStyle(
                                    fontSize: 15, color: Colors.white),
                                textAlign: TextAlign.center,
                              )
                            : SizedBox(),
                      ),
                    ),
                  )
                ],
              ),
            ),
            shown: shown,
            duration: duration ?? Duration(seconds: 10));
}

class GalupStoryVideo extends StatefulWidget {
  final StoryController storyController;
  final String url;

  GalupStoryVideo({this.url, this.storyController, Key key})
      : super(key: key ?? UniqueKey());

  @override
  State<StatefulWidget> createState() {
    return StoryVideoState();
  }
}

class StoryVideoState extends State<GalupStoryVideo> {
  Future<void> playerLoader;

  StreamSubscription _streamSubscription;

  VideoPlayerController playerController;

  @override
  void initState() {
    super.initState();

    widget.storyController.pause();

    this.playerController = VideoPlayerController.network(widget.url);

    playerController.initialize().then((v) {
      setState(() {});
      widget.storyController.play();
    });

    if (widget.storyController != null) {
      _streamSubscription =
          widget.storyController.playbackNotifier.listen((playbackState) {
        if (playbackState == PlaybackState.pause) {
          playerController.pause();
        } else {
          playerController.play();
        }
      });
    }
  }

  Widget getContentView() {
    if (playerController.value.initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: playerController.value.aspectRatio,
          child: VideoPlayer(playerController),
        ),
      );
    }

    return Center(
      child: Container(
        width: 70,
        height: 70,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: double.infinity,
      width: double.infinity,
      child: getContentView(),
    );
  }

  @override
  void dispose() {
    playerController.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }
}
