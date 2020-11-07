import 'dart:io';

import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
//import 'package:video_compress/video_compress.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:video_trimmer/video_trimmer.dart';

import 'gallery_screen.dart';
import 'trim_video_screen.dart';
import 'new_content_groups_screen.dart';
import '../translations.dart';
import '../models/group_model.dart';
import '../mixins/text_mixin.dart';
import '../providers/content_provider.dart';
import '../custom/galup_font_icons.dart';
import '../custom/my_special_text_span_builder.dart';
import '../custom/suggestion_textfield.dart';

class NewSecretPollScreen extends StatefulWidget {
  static const routeName = '/new-secret-poll';

  @override
  _NewPollScreenState createState() => _NewPollScreenState();
}

class _NewPollScreenState extends State<NewSecretPollScreen> with TextMixin {
  bool _isLoading = false;
  bool _isVideo = false;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _firstController = TextEditingController();
  TextEditingController _secondController = TextEditingController();
  TextEditingController _thirdController = TextEditingController();
  TextEditingController _fourthController = TextEditingController();
  TextEditingController _fifthController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  final Trimmer _trimmer = Trimmer();
  final MySpecialTextSpanBuilder _mySpecialTextSpanBuilder =
      MySpecialTextSpanBuilder();
  int moreOptions = 0;
  File _option1, _option2, _option3, _option4, _option5;
  List<File> pollImages = [];
  List<GroupModel> _groups = [];
  File _videoFile;
  File _videoThumb;

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
        final mFile = await FlutterVideoCompress().getThumbnailWithFile(
        //final mFile = await VideoCompress.getFileThumbnail(
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

  void _selectCategory() {
    FocusScope.of(context).unfocus();
    Navigator.of(context)
        .pushNamed(NewContentGroupsScreen.routeName)
        .then((value) {
      if (value != null) {
        setState(() {
          _groups.add(value);
        });
      }
    });
  }

  void _validate() {
    if (_titleController.text.isNotEmpty &&
        _firstController.text.isNotEmpty &&
        _secondController.text.isNotEmpty &&
        _groups.isNotEmpty) {
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
              _savePoll();
            },
            child: Text(Translations.of(context).text('button_publish')),
          )
        ],
      ),
    );
  }

  void _showAlert() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Tu encuesta se ha creado correctamente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: RaisedButton(
                  textColor: Colors.white,
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  void _showError() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Ocurrió un error al guardar tu encuesta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: RaisedButton(
                  textColor: Colors.white,
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _savePoll() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });
    var pollAnswers = [];
    if (_option1 != null) {
      String idResource =
          await Provider.of<ContentProvider>(context, listen: false)
              .uploadResource(
        _option1.path,
        'I',
        'PA',
      );

      pollAnswers.add({
        'text': serverSafe(_firstController.text),
        'image': idResource,
      });
    } else {
      pollAnswers.add({
        'text': serverSafe(_firstController.text),
        'image': null,
      });
    }
    if (_option2 != null) {
      String idResource =
          await Provider.of<ContentProvider>(context, listen: false)
              .uploadResource(
        _option2.path,
        'I',
        'PA',
      );
      pollAnswers.add({
        'text': serverSafe(_secondController.text),
        'image': idResource,
      });
    } else {
      pollAnswers.add({
        'text': serverSafe(_secondController.text),
        'image': null,
      });
    }
    if (moreOptions == 1) {
      if (_option3 != null) {
        String idResource =
            await Provider.of<ContentProvider>(context, listen: false)
                .uploadResource(
          _option3.path,
          'I',
          'PA',
        );
        pollAnswers.add({
          'text': serverSafe(_thirdController.text),
          'image': idResource,
        });
      } else {
        pollAnswers.add({
          'text': serverSafe(_thirdController.text),
          'image': null,
        });
      }
    }
    if (moreOptions == 2) {
      if (_option4 != null) {
        String idResource =
            await Provider.of<ContentProvider>(context, listen: false)
                .uploadResource(
          _option4.path,
          'I',
          'PA',
        );
        pollAnswers.add({
          'text': serverSafe(_fourthController.text),
          'image': idResource,
        });
      } else {
        pollAnswers.add({
          'text': serverSafe(_fourthController.text),
          'image': null,
        });
      }
    }
    if (moreOptions == 3) {
      if (_option5 != null) {
        String idResource =
            await Provider.of<ContentProvider>(context, listen: false)
                .uploadResource(
          _option5.path,
          'I',
          'PA',
        );
        pollAnswers.add({
          'text': serverSafe(_fifthController.text),
          'image': idResource,
        });
      } else {
        pollAnswers.add({
          'text': serverSafe(_fifthController.text),
          'image': null,
        });
      }
    }

    List<Map> images = [];
    for (int i = 0; i < pollImages.length; i++) {
      final element = pollImages[i];
      String idResource =
          await Provider.of<ContentProvider>(context, listen: false)
              .uploadResource(
        element.path,
        'I',
        'P',
      );
      images.add({"id": idResource});
    }
    if (_videoFile != null) {
      final idResource =
          await Provider.of<ContentProvider>(context, listen: false)
              .uploadResource(
        _videoFile.path,
        'V',
        'P',
      );
      images.add({"id": idResource});
    }

    List<Map> hashes = [];
    RegExp exp = new RegExp(r"\B#\S\S+");
    exp.allMatches(_titleController.text).forEach((match) {
      if (!hashes.contains(match.group(0))) {
        hashes.add({'text': removeDiacritics(match.group(0).toLowerCase())});
      }
    });
    exp.allMatches(_descriptionController.text).forEach((match) {
      if (!hashes.contains(match.group(0))) {
        String hashString = match.group(0).toLowerCase();
        String serverString = removeDiacritics(hashString);
        hashes.add({'text': serverString});
      }
    });

    List<Map> groups = [];
    _groups.forEach((element) {
      groups.add({
        'id': element.id,
      });
    });

    bool result = await Provider.of<ContentProvider>(context, listen: false)
        .newSecretPoll(
      name: '${_titleController.text} ',
      description: '${_descriptionController.text} ',
      groups: groups,
      resources: images,
      answers: pollAnswers,
      hashtag: hashes,
      taged: [],
    );

    setState(() {
      _isLoading = false;
    });
    if (result)
      _showAlert();
    else
      _showError();
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

  Iterable<Widget> get chipWidgets sync* {
    for (final GroupModel group in _groups) {
      yield Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Chip(
          backgroundColor: Theme.of(context).accentColor,
          label: Text(
            group.title,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          deleteIconColor: Colors.white,
          onDeleted: () {
            setState(() {
              _groups.removeWhere((entry) {
                return entry.title == group.title;
              });
            });
          },
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Encuesta Privada',
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
                    hintText: Translations.of(context).text('hint_poll_title'),
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
              SizedBox(height: 16),
              _title(Translations.of(context).text('label_media_poll')),
              SizedBox(height: 16),
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
                              ? DecorationImage(image: FileImage(pollImages[0]))
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _title(Translations.of(context).text('title_groups')),
                  FlatButton(
                    onPressed: _selectCategory,
                    textColor: Theme.of(context).primaryColor,
                    child: Text('+ Agregar'),
                  ),
                ],
              ),
              Wrap(
                children: chipWidgets.toList(),
              ),
              Text(
                'Esta encuesta solo podrá ser vista y contestada por los integrantes de los grupos que selecciones',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
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
              SizedBox(height: 16),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                      width: double.infinity,
                      height: 42,
                      child: RaisedButton(
                        textColor: Colors.white,
                        color: Color(0xFFA4175D),
                        child: Text(
                            Translations.of(context).text('button_publish')),
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
