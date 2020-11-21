import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';

import 'poll_audio_position.dart';
import '../models/resource_model.dart';

const int SAMPLE_RATE = 8000;

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
  bool _isPlaying = false;
  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;
  int _currentPosition = 0;

  void _play() async {
    await init();
    try {
      await playerModule.startPlayer(
          fromURI: widget.audio.url,
          codec: Codec.aacADTS,
          sampleRate: SAMPLE_RATE,
          whenFinished: () {
            print('Play finished');
            setState(() {
              _hasLoaded = false;
              _isPlaying = false;
            });
          });
      _addListeners();
      setState(() {
        _currentPosition = 0;
        _hasLoaded = true;
        _isPlaying = true;
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
    return Row(
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
    );
  }

  Widget playerWidget() {
    return Row(
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
            divisions: maxDuration == 0.0 ? 1 : maxDuration.toInt(),
          ),
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
    );
  }

  @override
  void initState() {
    //init();
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
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Color(0xFFF8F8FF),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _hasLoaded ? _pauseResumePlayer : _play,
            child: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              size: 32,
            ),
          ),
          Expanded(child: _hasLoaded ? playerWidget() : placeHolder()),
        ],
      ),
    );
  }
}
