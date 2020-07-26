import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_trimmer/trim_editor.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:video_trimmer/video_viewer.dart';

import '../translations.dart';

class TrimmerView extends StatefulWidget {
  final Trimmer _trimmer;
  TrimmerView(this._trimmer);
  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;

  void _alertError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text('Tu video debe durar menos de 60 segundos'),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Ok'),
          )
        ],
      ),
    );
  }

  Future<String> _saveVideo() async {
    int duration;
    if (Platform.isIOS) duration = (_endValue - _startValue).toInt();
    else{
      MediaInfo _originalInfo = await VideoCompress.getMediaInfo(widget._trimmer.getVideoFile().path);
      duration = _originalInfo.duration.toInt(); 
    }
    if (duration > 60000) {
      _alertError();
      return null;
    }
    setState(() {
      _progressVisibility = true;
    });

    //int duration = (_endValue - _startValue).toInt();
    MediaInfo info;
    if (Platform.isIOS) {
      final _path = await widget._trimmer
          .saveTrimmedVideo(startValue: _startValue, endValue: _endValue);
      await VideoCompress.deleteAllCache();
      MediaInfo _originalInfo = await VideoCompress.getMediaInfo(_path);
      info = await VideoCompress.compressVideo(
        _originalInfo.path,
        quality: VideoQuality.HighestQuality,
        //startTime: _startValue.toInt(),
        //duration: duration,
        deleteOrigin: false,
      );
    } else if (Platform.isAndroid) {
      info = await VideoCompress.compressVideo(
        widget._trimmer.getVideoFile().path,
        quality: VideoQuality.HighestQuality,
        //startTime: _startValue.toInt(),
        //duration: duration,
        deleteOrigin: false,
      );
    }
    setState(() {
      _progressVisibility = false;
    });

    return info.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('title_edit')),
      ),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
                RaisedButton(
                  onPressed: _progressVisibility
                      ? null
                      : () async {
                          _saveVideo().then((outputPath) {
                            if (outputPath != null)
                              Navigator.of(context).pop(outputPath);
                          });
                        },
                  child: Text(Translations.of(context).text('button_save')),
                ),
                Expanded(
                  child: VideoViewer(),
                ),
                if (Platform.isIOS)
                  Center(
                    child: TrimEditor(
                      viewerHeight: 50.0,
                      viewerWidth: MediaQuery.of(context).size.width,
                      onChangeStart: (value) {
                        _startValue = value;
                      },
                      onChangeEnd: (value) {
                        _endValue = value;
                      },
                      onChangePlaybackState: (value) {
                        setState(() {
                          _isPlaying = value;
                        });
                      },
                    ),
                  ),
                FlatButton(
                  child: _isPlaying
                      ? Icon(
                          Icons.pause,
                          size: 80.0,
                          color: Colors.white,
                        )
                      : Icon(
                          Icons.play_arrow,
                          size: 80.0,
                          color: Colors.white,
                        ),
                  onPressed: () async {
                    bool playbackState =
                        await widget._trimmer.videPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                    setState(() {
                      _isPlaying = playbackState;
                    });
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
