import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';

import 'poll_audio_position.dart';
import '../models/resource_model.dart';

class PollAudio extends StatefulWidget {
  final ResourceModel audio;

  PollAudio(this.audio);

  @override
  _PollVideoState createState() => _PollVideoState();
}

class _PollVideoState extends State<PollAudio> {
  FlutterSoundPlayer playerModule = FlutterSoundPlayer();
  StreamSubscription _playerSubscription;
  bool _hasLoaded = false;
  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;
  int _currentPosition = 0;

  void _play() async {
    try {
      await playerModule.startPlayer(
          fromURI: widget.audio.url,
          codec: Codec.aacADTS,
          whenFinished: () {
            print('Play finished');
            setState(() {
              _hasLoaded = false;
            });
          });
      _addListeners();
      setState(() {
        _currentPosition = 0;
        _hasLoaded = true;
      });
    } catch (err) {
      setState(() {});
      print('error: $err');
    }
  }

  void _pauseResumePlayer() async {
    if (playerModule.isPlaying) {
      await playerModule.pausePlayer();
    } else {
      await playerModule.resumePlayer();
    }
    setState(() {});
  }

  void _addListeners() {
    cancelPlayerSubscriptions();
    _playerSubscription = playerModule.onProgress.listen((e) {
      if (e != null) {
        maxDuration = e.duration.inMilliseconds.toDouble();
        if (maxDuration <= 0) maxDuration = 0.0;

        sliderCurrentPosition =
            min(e.position.inMilliseconds.toDouble(), maxDuration);
        if (sliderCurrentPosition < 0.0) {
          sliderCurrentPosition = 0.0;
        }
        print('Resta: ${widget.audio.duration - e.position.inMilliseconds}');
        setState(() {
          _currentPosition = e.position.inMilliseconds;
        });
      } else {
        print('Algo raro pasó');
      }
    });
  }

  void cancelPlayerSubscriptions() {
    if (_playerSubscription != null) {
      _playerSubscription.cancel();
      _playerSubscription = null;
    }
  }

  void seekToPlayer(int milliSecs) async {
    if (playerModule.isPlaying)
      await playerModule.seekToPlayer(Duration(milliseconds: milliSecs));
  }

  Future<void> init() async {
    await playerModule.closeAudioSession();
    await playerModule.openAudioSession(
      focus: AudioFocus.requestFocusAndStopOthers,
      category: SessionCategory.playback,
      mode: SessionMode.modeDefault,
      device: AudioDevice.speaker,
    );
    await playerModule.setSubscriptionDuration(Duration(milliseconds: 10));
  }

  Future<void> releaseFlauto() async {
    try {
      await playerModule.closeAudioSession();
    } catch (e) {
      print('Released unsuccessful');
      print(e);
    }
  }

  Widget placeHolder() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Slider(
              min: 0,
              max: 100,
              value: 0,
              onChanged: null,
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              durationToString(
                Duration(milliseconds: widget.audio.duration),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget playerWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Slider(
                min: 0,
                max: maxDuration,
                value: min(sliderCurrentPosition, maxDuration),
                onChanged: (double value) async {
                  seekToPlayer(value.toInt());
                },
                divisions: maxDuration == 0.0 ? 1 : maxDuration.toInt()),
          ),
          SizedBox(
            width: 40,
            child: Text(
              durationToString(
                Duration(
                  milliseconds: (widget.audio.duration - _currentPosition),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    cancelPlayerSubscriptions();
    releaseFlauto();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 16),
        Column(
          children: [
            GestureDetector(
              onTap: _hasLoaded ? _pauseResumePlayer : _play,
              child: CircleAvatar(
                child: Image.asset(
                  'assets/logo.png',
                  width: 32,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Presiona\npara escuchar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
              ),
            )
          ],
        ),
        Expanded(child: _hasLoaded ? playerWidget() : placeHolder()),
      ],
    );
  }
}
