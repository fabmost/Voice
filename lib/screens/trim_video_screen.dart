import 'package:flutter/material.dart';
import 'package:video_compress/video_compress.dart';
//import 'package:flutter_video_compress/flutter_video_compress.dart';
//import 'package:video_trimmer/storage_dir.dart';
//import 'package:video_trimmer/file_formats.dart';
import 'package:video_trimmer/video_trimmer.dart';

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

  //Android
  //final _compressor = FlutterVideoCompress();
  //iOs
  dynamic _subscription;
  double _progress = 0;

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

  Future<Map> _saveVideo() async {
    int duration;
    duration = (_endValue - _startValue).toInt();

    if (duration > 60000) {
      _alertError();
      return null;
    }
    setState(() {
      _progressVisibility = true;
    });

    //iOs
    /*
    final _path = await widget._trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      outputFormat: FileFormat.mp4,
    );
    */
    //Android
    final _path = widget._trimmer.getVideoFile().path;
    //await VideoCompress.deleteAllCache();
    //MediaInfo _originalInfo = await VideoCompress.getMediaInfo(_path);
    MediaInfo info = await VideoCompress.compressVideo(
      _path,
      quality: VideoQuality.MediumQuality,
      //quality: VideoQuality.HighestQuality,
      startTime: _startValue.toInt(),
      duration: duration,
      //deleteOrigin: true,
      includeAudio: true,
    );

    //Android
    /*
    final _path = await widget._trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      outputFormat: FileFormat.mp4,
      storageDir: StorageDir.temporaryDirectory,
    );
    final info = await _compressor.compressVideo(
      _path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: true,
    );
    */

    return {
      'path': info.path,
      'duration': info.duration,
      'ratio': info.height / info.width,
    };
    //return info.path;
  }

  @override
  void initState() {
    super.initState();

    //iOs
    _subscription = VideoCompress.compressProgress$.subscribe((progress) {
      print(progress);
      setState(() {
        _progress = progress;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.unsubscribe();
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
                  child: Stack(
                    children: [
                      LinearProgressIndicator(
                        backgroundColor: Colors.red,
                        value: _progress / 100,
                        minHeight: 12,
                      ),
                      //iOs
                      Align(
                        alignment: Alignment.center,
                        child: Text('${_progress.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            )),
                      ),
                    ],
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
