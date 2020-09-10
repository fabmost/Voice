import 'dart:io';

import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_trimmer/video_trimmer.dart';

import 'gallery_screen.dart';
import 'trim_video_screen.dart';
import 'new_content_category_screen.dart';
import '../translations.dart';
import '../models/category_model.dart';
import '../providers/user_provider.dart';
import '../providers/content_provider.dart';
import '../widgets/influencer_badge.dart';
import '../custom/suggestion_textfield.dart';
import '../custom/my_special_text_span_builder.dart';

class NewChallengeScreen extends StatefulWidget {
  static const routeName = '/new-challenge';

  @override
  _NewChallengeScreenState createState() => _NewChallengeScreenState();
}

class _NewChallengeScreenState extends State<NewChallengeScreen> {
  final Trimmer _trimmer = Trimmer();
  bool _isLoading = false;
  bool _isVideo = false;
  bool _isSearching = false;
  String metric = 'Likes';
  double goal = 0;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  FocusNode _descFocus = FocusNode();
  File _imageFile;
  File _videoFile;

  CategoryModel category;

  void _imageOptions() {
    FocusScope.of(context).requestFocus(FocusNode());
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return new Container(
          color: Colors.transparent,
          child: new Wrap(
            children: <Widget>[
              if (Platform.isIOS)
                ListTile(
                  onTap: () => _openCamera(),
                  leading: Icon(
                    Icons.camera_alt,
                  ),
                  title: Text("Cámara"),
                ),
              if (Platform.isAndroid)
                ListTile(
                  onTap: () => _openCamera(),
                  leading: Icon(
                    Icons.camera_alt,
                  ),
                  title: Text("Foto"),
                ),
              if (Platform.isAndroid)
                ListTile(
                  onTap: () => _takeVideo(),
                  leading: Icon(
                    Icons.videocam,
                  ),
                  title: Text("Video"),
                ),
              ListTile(
                onTap: () => _openGallery(),
                leading: Icon(
                  Icons.image,
                ),
                title: Text("Galería"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openCamera() {
    Navigator.of(context).pop();
    _takePicture();
  }

  void _openGallery() {
    Navigator.of(context).pop();
    if (Platform.isIOS)
      _getPicture();
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
            _cropImage(imgFile.path);
          }
        }
      });
    }
  }

  Future<void> _getPicture() async {
    final imageFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );
    if (imageFile != null) {
      _cropImage(imageFile.path);
    }
  }

  Future<void> _takePicture() async {
    final imageFile = await ImagePicker().getImage(
      source: ImageSource.camera,
    );
    if (imageFile != null) {
      _cropImage(imageFile.path);
    }
  }

  Future<void> _takeVideo() async {
    Navigator.of(context).pop();
    final videoFile = await ImagePicker().getVideo(
      source: ImageSource.camera,
      maxDuration: Duration(seconds: 60),
    );
    if (videoFile != null) {
      _trimVideo(File(videoFile.path));
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
        final mFile = await VideoThumbnail.thumbnailFile(
          video: value,
          //imageFormat: ImageFormat.JPEG,
          quality: 50,
        );
        setState(() {
          _isVideo = true;
          _imageFile = File(mFile);
          _videoFile = File(value);
        });
      }
    });
  }

  void _cropImage(pathFile) async {
    _isVideo = false;
    File cropped = await ImageCropper.cropImage(
      sourcePath: pathFile,
    );
    if (cropped != null) {
      setState(() {
        _imageFile = cropped;
      });
    }
  }

  void _metricSelected() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('Selecciona el tipo de meta'),
          children: <Widget>[
            SimpleDialogOption(
              child: Text(
                'Likes',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () => _optionSelected('Likes'),
            ),
            SimpleDialogOption(
              child: Text(
                'Comentarios',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () => _optionSelected('Comentarios'),
            ),
            SimpleDialogOption(
              child: Text(
                'Regalups',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () => _optionSelected('Regalups'),
            ),
          ],
        );
      },
    );
  }

  void _optionSelected(value) {
    Navigator.of(context).pop();
    setState(() {
      metric = value;
    });
  }

  void _selectCategory() {
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
    if (_titleController.text.isNotEmpty &&
        _imageFile != null &&
        goal > 0 &&
        category != null) {
      _saveChallenge();
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
                'Tu reto se ha creado correctamente',
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
                'Ocurrió un error al guardar tu reto',
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

  void _saveChallenge() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });
    String idResource;
    if (_isVideo) {
      idResource = await Provider.of<ContentProvider>(context, listen: false)
          .uploadResource(
        _videoFile.path,
        'V',
        'C',
      );
    } else {
      idResource = await Provider.of<ContentProvider>(context, listen: false)
          .uploadResource(
        _imageFile.path,
        'I',
        'C',
      );
    }

    String metricString;
    switch (metric) {
      case 'Likes':
        metricString = 'L';
        break;
      case 'Comentarios':
        metricString = 'C';
        break;
      case 'Regalups':
        metricString = 'R';
        break;
    }

    List<Map> hashes = [];
    RegExp exp = new RegExp(r"\B#\w\w+");
    exp.allMatches(_titleController.text).forEach((match) {
      if (!hashes.contains({'text': match.group(0)})) {
        hashes.add({'text': removeDiacritics(match.group(0).toLowerCase())});
      }
    });
    exp.allMatches(_descriptionController.text).forEach((match) {
      if (!hashes.contains({'text': match.group(0)})) {
        hashes.add({'text': removeDiacritics(match.group(0).toLowerCase())});
      }
    });

    List<Map> tags = [];
    RegExp exps = new RegExp(r"\B@\[\w\w+\]\w\w+");
    exps.allMatches(_descriptionController.text).forEach((match) {
      String toRemove;
      int start = match.group(0).indexOf('[');
      if (start != -1) {
        int finish = match.group(0).indexOf(']');
        toRemove = match.group(0).substring(start, finish + 1);
        toRemove = toRemove.replaceAll('[', '');
        toRemove = toRemove.replaceAll(']', '');
      }
      if (toRemove != null && !tags.contains({'user_name': toRemove})) {
        tags.add({'user_name': toRemove});
      }
    });

    bool result =
        await Provider.of<ContentProvider>(context, listen: false).newChallenge(
      name: _titleController.text,
      description: '${_descriptionController.text} ',
      category: category.id,
      resource: {'id': idResource},
      parameter: metricString,
      goal: goal,
      hashtag: hashes,
      taged: tags,
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
          InfluencerBadge(content.userName, content.certificate, 16),
        ],
      ),
      //subtitle: Text(doc['user_name']),
    );
  }

  Future<List> _getSuggestions(String query) async {
    if (query.endsWith(' ')) {
      _isSearching = false;
      return null;
    }
    int index = query.lastIndexOf('@');
    String realQuery = query.substring(index + 1);
    Map results = await Provider.of<UserProvider>(context, listen: false)
        .getAutocomplete(realQuery);
    return results['users'];
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _titleController,
                autofocus: true,
                autocorrect: true,
                maxLines: null,
                maxLength: 120,
                decoration: InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  hintText:
                      Translations.of(context).text('hint_challenge_title'),
                ),
                style: TextStyle(fontSize: 22),
              ),
              SizedBox(height: 16),
              _title(Translations.of(context).text('label_media_challenge')),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: _imageOptions,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black),
                      image: _imageFile != null
                          ? DecorationImage(image: FileImage(_imageFile))
                          : null,
                    ),
                    child: Icon(Icons.camera_alt),
                  ),
                ),
              ),
              SizedBox(height: 16),
              _title(Translations.of(context).text('label_goal')),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: Slider(
                  activeColor: Color(0xFFA4175D),
                  value: goal,
                  onChanged: (newValue) {
                    setState(() {
                      goal = newValue;
                    });
                  },
                  min: 0,
                  max: 5000,
                  divisions: 50,
                  label: '${NumberFormat.compact().format(goal)}',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '${goal.toInt()}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: _metricSelected,
                      child: Container(
                        height: 42,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Text(metric),
                            Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
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
                  spanBuilder: MySpecialTextSpanBuilder(),
                  controller: _descriptionController,
                  focusNode: _descFocus,
                  maxLines: null,
                  autocorrect: true,
                  keyboardType: TextInputType.multiline,
                  maxLength: 480,
                  decoration: InputDecoration(
                    labelText:
                        Translations.of(context).text('hint_description'),
                  ),
                ),
                suggestionsCallback: (pattern) {
                  //TextSelection selection = _descriptionController.selection;
                  //String toCheck = pattern.substring(0, selection.end);
                  if (_isSearching) {
                    return _getSuggestions(pattern);
                  }
                  if (pattern.endsWith('@')) {
                    _isSearching = true;
                  }
                  return null;
                },
                itemBuilder: (context, itemData) {
                  return _userTile(context, itemData);
                },
                onSuggestionSelected: (suggestion) {
                  _isSearching = false;
                  //TextSelection selection = _descriptionController.selection;
                  int index = _descriptionController.text.lastIndexOf('@');
                  String subs = _descriptionController.text.substring(0, index);
                  _descriptionController.text =
                      '$subs@[${suggestion.userName}]${suggestion.userName} ';
                  _descriptionController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _descriptionController.text.length));
                  //_descFocus.requestFocus();
                  //FocusScope.of(context).requestFocus(_descFocus);
                },
                autoFlipDirection: true,
              ),
              SizedBox(height: 16),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                      width: double.infinity,
                      height: 42,
                      child: RaisedButton(
                        color: Color(0xFFA4175D),
                        textColor: Colors.white,
                        child:
                            Text(Translations.of(context).text('button_save')),
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
