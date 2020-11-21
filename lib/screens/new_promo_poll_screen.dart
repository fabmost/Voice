import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:video_compress/video_compress.dart';
//import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_trimmer/video_trimmer.dart';

import 'gallery_screen.dart';
import 'trim_video_screen.dart';
import 'new_content_category_screen.dart';
import 'new_promo_info_screen.dart';
import '../translations.dart';
import '../widgets/video_overlay.dart';
import '../providers/preferences_provider.dart';
import '../models/category_model.dart';
import '../mixins/text_mixin.dart';
import '../custom/galup_font_icons.dart';
import '../custom/my_special_text_span_builder.dart';
import '../custom/suggestion_textfield.dart';

const int SAMPLE_RATE = 8000;

class NewPromoPollScreen extends StatefulWidget {
  static const routeName = '/new-promo-poll';

  @override
  _NewPollScreenState createState() => _NewPollScreenState();
}

class _NewPollScreenState extends State<NewPromoPollScreen> with TextMixin {
  bool _isLoading = false;
  bool _isVideo = false;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _firstController = TextEditingController();
  TextEditingController _secondController = TextEditingController();
  TextEditingController _thirdController = TextEditingController();
  TextEditingController _fourthController = TextEditingController();
  TextEditingController _fifthController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  FlutterSoundPlayer playerModule = FlutterSoundPlayer();
  FlutterSoundRecorder recorderModule = FlutterSoundRecorder();
  StreamSubscription _recorderSubscription;
  StreamSubscription _playerSubscription;
  String _recorderTxt = '0';
  String _audioPath;
  Duration _recordingDuration;
  Codec _codec = Codec.aacADTS;
  bool _isRecording = false;
  bool _isPlaying = false;
  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;

  final Trimmer _trimmer = Trimmer();
  final MySpecialTextSpanBuilder _mySpecialTextSpanBuilder =
      MySpecialTextSpanBuilder();
  int moreOptions = 0;
  File _option1, _option2, _option3, _option4, _option5;
  List<File> pollImages = [];
  CategoryModel category;
  File _videoFile;
  File _videoThumb;
  int _pollType = 0;

  final double size = 82;

  void _deleteFile(file, isOption) {
    Navigator.of(context).pop();
    if (!isOption) {
      setState(() {
        pollImages.removeAt(file);
      });
    }
    switch (file) {
      case 0:
        setState(() {
          _option1 = null;
        });
        break;
      case 1:
        setState(() {
          _option2 = null;
        });
        break;
      case 2:
        setState(() {
          _option3 = null;
        });
        break;
    }
  }

  void _videoOptions() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          color: Colors.transparent,
          child: Wrap(
            children: <Widget>[
              ListTile(
                onTap: () {
                  Navigator.of(bc).pop();
                  setState(() {
                    _isVideo = false;
                    _videoFile = null;
                    _videoThumb = null;
                  });
                },
                leading: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: Text(
                  "Eliminar",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _imageOptions(file, isOption) {
    bool showDelete = false;
    switch (file) {
      case 0:
        if (isOption) {
          if (_option1 != null) showDelete = true;
        } else {
          if (_isVideo && _videoFile != null) {
            showDelete = true;
          } else if (pollImages.length > 0) showDelete = true;
        }
        break;
      case 1:
        if (isOption) {
          if (_option2 != null) showDelete = true;
        } else {
          if (pollImages.length > 1) showDelete = true;
        }
        break;
      case 2:
        if (isOption) {
          if (_option3 != null) showDelete = true;
        } else {
          if (pollImages.length > 2) showDelete = true;
        }
        break;
    }
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          color: Colors.transparent,
          child: Wrap(
            children: <Widget>[
              if (isOption || file != 0)
                ListTile(
                  onTap: () => _openCamera(file, isOption),
                  leading: Icon(
                    Icons.camera_alt,
                  ),
                  title: Text("Cámara"),
                ),
              if (!isOption && file == 0)
                ListTile(
                  onTap: () => _openCamera(file, isOption),
                  leading: Icon(
                    Icons.camera_alt,
                  ),
                  title: Text("Foto"),
                ),
              if (!isOption && file == 0)
                ListTile(
                  onTap: () => _takeVideo(file, isOption),
                  leading: Icon(
                    Icons.videocam,
                  ),
                  title: Text("Video"),
                ),
              ListTile(
                onTap: () => _openGallery(file, isOption),
                leading: Icon(
                  Icons.image,
                ),
                title: Text("Galería"),
              ),
              if (showDelete)
                ListTile(
                  onTap: () => _deleteFile(file, isOption),
                  leading: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  title: Text(
                    "Eliminar",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _openCamera(file, isOption) {
    Navigator.of(context).pop();
    _takePicture(file, isOption);
  }

  void _openGallery(file, isOption) {
    Navigator.of(context).pop();
    if (isOption || file > 0)
      _getPicture(file, isOption);
    else {
      Navigator.of(context)
          .pushNamed(GalleryScreen.routeName)
          .then((value) async {
        if (value != null) {
          AssetEntity asset = value as AssetEntity;
          if (asset.type == AssetType.video) {
            File videoFile = await asset.file;
            _trimVideo(videoFile);
          } else {
            File imgFile = await asset.file;
            _cropBigImage(file, imgFile.path);
          }
        }
      });
    }
  }

  Future<void> _takeVideo(file, isOption) async {
    Navigator.of(context).pop();
    final videoFile = await ImagePicker().getVideo(
      source: ImageSource.camera,
      maxDuration: Duration(seconds: 60),
    );
    if (videoFile != null) {
      _trimVideo(File(videoFile.path));
    }
  }

  Future<void> _takePicture(file, isOption) async {
    final imageFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );
    if (imageFile != null) {
      if (isOption)
        _cropImage(file, imageFile.path);
      else
        _cropBigImage(file, imageFile.path);
    }
  }

  Future<void> _getPicture(file, isOption) async {
    final imageFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );
    if (imageFile != null) {
      if (isOption)
        _cropImage(file, imageFile.path);
      else
        _cropBigImage(file, imageFile.path);
    }
  }

  void _cropBigImage(file, pathFile) async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: pathFile,
    );
    if (cropped != null) {
      setState(() {
        if (pollImages.length <= file || pollImages.isEmpty) {
          pollImages.add(cropped);
        } else {
          pollImages[file] = cropped;
        }
      });
    }
  }

  void _trimVideo(videoFile) async {
    await _trimmer.loadVideo(videoFile: File(videoFile.path));
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return TrimmerView(_trimmer);
      }),
    ).then((value) async {
      if (value != null) {
        //final mFile = await FlutterVideoCompress().getThumbnailWithFile(
        final mFile = await VideoCompress.getFileThumbnail(
          value,
          //imageFormat: ImageFormat.JPEG,
          quality: 50,
        );
        setState(() {
          _videoThumb = mFile;
          _videoFile = File(value);
          _isVideo = true;
        });
      }
    });
  }

  void _cropImage(file, pathFile) async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: pathFile,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
    );
    if (cropped != null) {
      setState(() {
        switch (file) {
          case 0:
            _option1 = cropped;
            break;
          case 1:
            _option2 = cropped;
            break;
          case 2:
            _option3 = cropped;
            break;
          case 3:
            _option1 = cropped;
            break;
        }
      });
    }
  }

  void _addOption(bool add) {
    setState(() {
      if (add)
        moreOptions++;
      else
        moreOptions--;
    });
    if (moreOptions == 2) _fifthController.clear();
    if (moreOptions == 1) _fourthController.clear();
    if (moreOptions == 0) _thirdController.clear();
  }

  void seekToPlayer(int milliSecs) async {
    if (playerModule.isPlaying)
      await playerModule.seekToPlayer(Duration(milliseconds: milliSecs));
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
        setState(() {});
      } else {
        print('Algo raro pasó');
      }
    });
  }

  void _startRecording() async {
    try {
      // Request Microphone permission if needed
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException("Microphone permission not granted");
      }
      String path = '';
      Directory tempDir = await getTemporaryDirectory();
      path = '${tempDir.path}/flutter_sound${_codec.index}';

      await recorderModule.startRecorder(
          toFile: path,
          codec: _codec,
          bitRate: 8000,
          numChannels: 1,
          sampleRate: SAMPLE_RATE);

      _recorderSubscription = recorderModule.onProgress.listen((e) {
        if (e != null && e.duration != null) {
          DateTime date = new DateTime.fromMillisecondsSinceEpoch(
              e.duration.inMilliseconds,
              isUtc: true);
          String txt = DateFormat('ss:SS', 'en_GB').format(date);

          _recordingDuration = e.duration;

          maxDuration = 60000;
          if (maxDuration <= 0) maxDuration = 0.0;

          sliderCurrentPosition =
              min(e.duration.inMilliseconds.toDouble(), maxDuration);
          if (sliderCurrentPosition < 0.0) {
            sliderCurrentPosition = 0.0;
          }
          setState(() {});

          this.setState(() {
            _recorderTxt = txt.substring(0, 5);
          });
        }
      });

      FlutterBeep.beep();

      this.setState(() {
        _isRecording = true;
        _audioPath = path;
      });
    } catch (err) {
      print('startRecorder error: $err');
      setState(() {
        _stopRecording();
        _isRecording = false;
      });
    }
  }

  void _stopRecording() async {
    await recorderModule.stopRecorder();
    if (_recorderSubscription != null) {
      _recorderSubscription.cancel();
      _recorderSubscription = null;
    }
    _recordingDuration = await flutterSoundHelper.duration(_audioPath);
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(
        _recordingDuration.inMilliseconds,
        isUtc: true);
    String txt = DateFormat('ss:SS', 'en_GB').format(date);
    setState(() {
      _recorderTxt = txt.substring(0, 5);
      _isRecording = false;
    });
  }

  void _startPlayer() async {
    try {
      await playerModule.startPlayer(
          fromURI: _audioPath,
          codec: _codec,
          sampleRate: SAMPLE_RATE,
          whenFinished: () {
            print('Play finished');
            setState(() {
              _isPlaying = false;
            });
          });
      _addListeners();
      setState(() {
        _isPlaying = true;
      });
    } catch (err) {
      setState(() {
        _isPlaying = false;
      });
      print('error: $err');
    }
  }

  void _selectCategory() {
    FocusScope.of(context).unfocus();
    Navigator.of(context)
        .pushNamed(NewContentCategoryScreen.routeName)
        .then((value) {
      if (value != null) {
        setState(() {
          category = value;
        });
      }
    });
  }

  void _validate() {
    if ((_pollType == 0 && _titleController.text.isNotEmpty ||
            _pollType == 1 && _audioPath != null) &&
        _firstController.text.isNotEmpty &&
        _secondController.text.isNotEmpty &&
        category != null) {
      bool pass = true;
      if (moreOptions == 1 && _thirdController.text.isEmpty) pass = false;
      if (moreOptions == 2 && _fourthController.text.isEmpty) pass = false;
      if (moreOptions == 3 && _fifthController.text.isEmpty) pass = false;

      if (pass) _validationAlert();
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Translations.of(context).text('error_missing')),
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

  void _validationAlert() {
    FocusScope.of(context).unfocus();
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Translations.of(context).text('dialog_validation')),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            textColor: Colors.red,
            child: Text(Translations.of(context).text('button_check')),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
              _nextStep();
            },
            child: Text(Translations.of(context).text('button_next')),
          )
        ],
      ),
    );
  }

  void _nextStep() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewPromoInfoScreen(
          poll: _titleController.text,
          category: category.id,
          description: _descriptionController.text,
          optionsCount: moreOptions + 2,
          options: [
            _firstController.text,
            _secondController.text,
            _thirdController.text,
            _fourthController.text,
            _fifthController.text,
          ],
          optionImages: [
            _option1 != null ? _option1.path : null,
            _option2 != null ? _option2.path : null,
            _option3 != null ? _option3.path : null,
            _option4 != null ? _option4.path : null,
            _option5 != null ? _option5.path : null,
          ],
          pollImages: pollImages,
          videoFile: _videoFile != null ? _videoFile.path : null,
          audio: _pollType == 0 ? null : _audioPath,
          duration: _pollType == 0 ? null : _recordingDuration.inMilliseconds,
        ),
      ),
    );
  }

  Widget _title(text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }

  Widget _optionField(controller, text) {
    return TextField(
      controller: controller,
      maxLength: 30,
      decoration: InputDecoration(
        hintText: text,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _firstOption() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: _optionField(_firstController, 'Opción 1')),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => _imageOptions(0, true),
          child: Container(
            width: 42,
            height: 42,
            margin: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black),
              image: _option1 != null
                  ? DecorationImage(image: FileImage(_option1))
                  : null,
            ),
            child: Icon(Icons.camera_alt),
          ),
        ),
      ],
    );
  }

  Widget _secondOption() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: _optionField(_secondController, 'Opción 2')),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => _imageOptions(1, true),
          child: Container(
            width: 42,
            height: 42,
            margin: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black),
              image: _option2 != null
                  ? DecorationImage(image: FileImage(_option2))
                  : null,
            ),
            child: Icon(Icons.camera_alt),
          ),
        ),
      ],
    );
  }

  Widget _thirdOption() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: _optionField(_thirdController, 'Opción 3')),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => _imageOptions(2, true),
          child: Container(
            width: 42,
            height: 42,
            margin: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black),
              image: _option3 != null
                  ? DecorationImage(image: FileImage(_option3))
                  : null,
            ),
            child: Icon(Icons.camera_alt),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: IconButton(
            icon: Icon(Icons.remove_circle_outline),
            onPressed: () => _addOption(false),
          ),
        )
      ],
    );
  }

  Widget _fourthOption() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: _optionField(_fourthController, 'Opción 4')),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => _imageOptions(2, true),
          child: Container(
            width: 42,
            height: 42,
            margin: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black),
              image: _option3 != null
                  ? DecorationImage(image: FileImage(_option4))
                  : null,
            ),
            child: Icon(Icons.camera_alt),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: IconButton(
            icon: Icon(Icons.remove_circle_outline),
            onPressed: () => _addOption(false),
          ),
        )
      ],
    );
  }

  Widget _fifthOption() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: _optionField(_fifthController, 'Opción 5')),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => _imageOptions(2, true),
          child: Container(
            width: 42,
            height: 42,
            margin: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black),
              image: _option5 != null
                  ? DecorationImage(image: FileImage(_option5))
                  : null,
            ),
            child: Icon(Icons.camera_alt),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: IconButton(
            icon: Icon(Icons.remove_circle_outline),
            onPressed: () => _addOption(false),
          ),
        )
      ],
    );
  }

  Widget _userTile(context, content) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            content.icon == null ? null : NetworkImage(content.icon),
      ),
      title: Row(
        children: <Widget>[
          Text(
            content.userName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }

  Future<void> init() async {
    await recorderModule.openAudioSession(
      focus: AudioFocus.requestFocusAndStopOthers,
      category: SessionCategory.playAndRecord,
      mode: SessionMode.modeDefault,
      device: AudioDevice.speaker,
    );
    await playerModule.closeAudioSession();
    await playerModule.openAudioSession(
      focus: AudioFocus.requestFocusAndStopOthers,
      category: SessionCategory.playAndRecord,
      mode: SessionMode.modeDefault,
      device: AudioDevice.speaker,
    );
    await playerModule.setSubscriptionDuration(Duration(milliseconds: 10));
  }

  void _willShowTutorial() async {
    bool show = await Provider.of<Preferences>(context, listen: false)
        .getVideoKey('promo_video');
    if (show) {
      _checkTutorial(true);
    }
  }

  void _checkTutorial(init) {
    Future.delayed(Duration.zero, () {
      Navigator.of(context).push(TutorialOverlay(
        'promo_video',
        'assets/videos/patrocinada.mp4',
        init,
      ));
    });
  }

  @override
  void initState() {
    _willShowTutorial();
    init();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    cancelPlayerSubscriptions();
    releaseFlauto();
  }

  void cancelPlayerSubscriptions() {
    if (_playerSubscription != null) {
      _playerSubscription.cancel();
      _playerSubscription = null;
    }
  }

  Future<void> releaseFlauto() async {
    try {
      await playerModule.closeAudioSession();
      await recorderModule.closeAudioSession();
    } catch (e) {
      print('Released unsuccessful');
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Encuesta Publicitaria',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: Colors.black,
            ),
            onPressed: () => _checkTutorial(false),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _title(Translations.of(context).text('label_poll')),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 52),
                child: MaterialSegmentedControl(
                    children: {
                      0: Text('Escribir'),
                      1: Text('Grabar'),
                    },
                    selectionIndex: _pollType,
                    selectedColor: Theme.of(context).primaryColor,
                    unselectedColor: Colors.white,
                    borderColor: Theme.of(context).primaryColor,
                    onSegmentChosen: (index) {
                      setState(() {
                        _pollType = index;
                      });
                    }),
              ),
              const SizedBox(height: 16),
              if (_pollType == 0)
                SuggestionField(
                  textFieldConfiguration: TextFieldConfiguration(
                    spanBuilder: _mySpecialTextSpanBuilder,
                    controller: _titleController,
                    autofocus: true,
                    autocorrect: true,
                    maxLines: null,
                    maxLength: 120,
                    decoration: InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      hintText:
                          Translations.of(context).text('hint_poll_title'),
                    ),
                    style: TextStyle(fontSize: 22),
                  ),
                  suggestionsCallback: (pattern) {
                    return null;
                  },
                  itemBuilder: (context, itemData) {
                    return _userTile(context, itemData);
                  },
                  onSuggestionSelected: (suggestion) {},
                  autoFlipDirection: true,
                ),
              if (_pollType == 1) const SizedBox(height: 16),
              if (_pollType == 1)
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Color(0xFFF8F8FF),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _isRecording && _audioPath == null
                                  ? null
                                  : _isPlaying ? null : _startPlayer,
                              icon: Icon(Icons.play_arrow),
                            ),
                            Expanded(
                              child: Slider(
                                min: 0,
                                max: maxDuration,
                                value: min(sliderCurrentPosition, maxDuration),
                                onChanged: (double value) async {
                                  seekToPlayer(value.toInt());
                                },
                                divisions: maxDuration == 0.0
                                    ? 1
                                    : maxDuration.toInt(),
                              ),
                            ),
                            Text(
                              _recorderTxt == '0' ? '00:00' : _recorderTxt,
                              textAlign: TextAlign.center,
                            ),
                            if (!_isRecording && _audioPath != null)
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    _audioPath = null;
                                    _recorderTxt = '0';
                                    sliderCurrentPosition = 0;
                                  });
                                },
                              ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onLongPress: _audioPath != null ? null : _startRecording,
                      onLongPressUp: _stopRecording,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _audioPath != null
                              ? Colors.grey
                              : Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.mic,
                          size: 52,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              if (_pollType == 0) SizedBox(height: 16),
              if (_pollType == 0)
                _title(Translations.of(context).text('label_media_poll')),
              if (_pollType == 0) SizedBox(height: 16),
              if (_pollType == 0)
                if (_isVideo)
                  Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: _videoOptions,
                      child: Container(
                        width: 180,
                        height: 120,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.black),
                            image: DecorationImage(
                              image: FileImage(_videoThumb),
                              fit: BoxFit.cover,
                            )),
                        child: Icon(Icons.camera_alt),
                      ),
                    ),
                  ),
              if (_pollType == 0)
                if (!_isVideo)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: () => _imageOptions(0, false),
                        child: Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.black),
                            image: pollImages.length > 0
                                ? DecorationImage(
                                    image: FileImage(pollImages[0]))
                                : null,
                          ),
                          child: Icon(Icons.camera_alt),
                        ),
                      ),
                      SizedBox(width: 8),
                      if (pollImages.length > 0)
                        InkWell(
                          onTap: () => _imageOptions(1, false),
                          child: Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.black),
                              image: pollImages.length > 1
                                  ? DecorationImage(
                                      image: FileImage(pollImages[1]))
                                  : null,
                            ),
                            child: Icon(Icons.camera_alt),
                          ),
                        ),
                      SizedBox(width: 8),
                      if (pollImages.length > 1)
                        InkWell(
                          onTap: () => _imageOptions(2, false),
                          child: Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.black),
                              image: pollImages.length > 2
                                  ? DecorationImage(
                                      image: FileImage(pollImages[2]))
                                  : null,
                            ),
                            child: Icon(Icons.camera_alt),
                          ),
                        ),
                    ],
                  ),
              SizedBox(height: 16),
              _title('Respuestas'),
              SizedBox(height: 16),
              _firstOption(),
              SizedBox(height: 8),
              _secondOption(),
              if (moreOptions > 0) SizedBox(height: 8),
              if (moreOptions > 0) _thirdOption(),
              if (moreOptions > 1) SizedBox(height: 8),
              if (moreOptions > 1) _fourthOption(),
              if (moreOptions > 2) SizedBox(height: 8),
              if (moreOptions > 2) _fifthOption(),
              if (moreOptions < 3)
                FlatButton.icon(
                  onPressed: () => _addOption(true),
                  icon: Icon(GalupFont.add),
                  label: Text('Agregar opción'),
                ),
              SizedBox(height: 16),
              _title(Translations.of(context).text('hint_category')),
              SizedBox(height: 8),
              InkWell(
                onTap: _selectCategory,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black),
                  ),
                  child: (category == null)
                      ? Text('Selecciona una categoría')
                      : Text('${category.name}'),
                ),
              ),
              SuggestionField(
                textFieldConfiguration: TextFieldConfiguration(
                  spanBuilder: _mySpecialTextSpanBuilder,
                  controller: _descriptionController,
                  keyboardType: TextInputType.multiline,
                  autocorrect: true,
                  maxLines: null,
                  maxLength: 480,
                  decoration: InputDecoration(
                    labelText:
                        Translations.of(context).text('hint_description'),
                  ),
                ),
                suggestionsCallback: (pattern) {
                  return null;
                },
                itemBuilder: (context, itemData) {
                  return _userTile(context, itemData);
                },
                onSuggestionSelected: (suggestion) {},
                autoFlipDirection: true,
              ),
              SizedBox(height: 32),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                      width: double.infinity,
                      height: 42,
                      child: RaisedButton(
                        textColor: Colors.white,
                        color: Color(0xFFE56F0E),
                        child:
                            Text(Translations.of(context).text('button_next')),
                        onPressed: () => _validate(),
                      ),
                    ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
