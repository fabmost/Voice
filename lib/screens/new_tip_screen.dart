import 'dart:io';

import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:video_compress/video_compress.dart';
//import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:video_trimmer/video_trimmer.dart';

import 'gallery_screen.dart';
import 'trim_video_screen.dart';
import 'new_content_category_screen.dart';
import '../translations.dart';
import '../models/category_model.dart';
import '../providers/content_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/influencer_badge.dart';
import '../custom/suggestion_textfield.dart';
import '../custom/my_special_text_span_builder.dart';

class NewTipScreen extends StatefulWidget {
  static const routeName = '/new-tip';

  @override
  _NewTipScreenState createState() => _NewTipScreenState();
}

class _NewTipScreenState extends State<NewTipScreen> {
  final Trimmer _trimmer = Trimmer();
  bool _isLoading = false;
  bool _isVideo = false;
  bool _isSearching = false;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  FocusNode _descFocus = FocusNode();
  File _imageFile;
  File _videoFile;
  final MySpecialTextSpanBuilder _mySpecialTextSpanBuilder =
      MySpecialTextSpanBuilder();

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
              ListTile(
                onTap: () => _openCamera(),
                leading: Icon(
                  Icons.camera_alt,
                ),
                title: Text("Foto"),
              ),
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
        //final mFile = await FlutterVideoCompress().getThumbnailWithFile(
        final mFile = await VideoCompress.getFileThumbnail(
          value,
          //imageFormat: ImageFormat.JPEG,
          quality: 50,
        );
        setState(() {
          _isVideo = true;
          _imageFile = mFile;
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
    if (_titleController.text.isNotEmpty && category != null) {
      _validationAlert();
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
              _saveTip();
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
                'Tu tip se ha creado correctamente',
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
                'Ocurrió un error al guardar tu tip',
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

  void _saveTip() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });
    String idResource;
    if (_imageFile != null || _videoFile != null) {
      if (_isVideo) {
        idResource = await Provider.of<ContentProvider>(context, listen: false)
            .uploadResource(
          _videoFile.path,
          'V',
          'TIP',
        );
      } else {
        idResource = await Provider.of<ContentProvider>(context, listen: false)
            .uploadResource(
          _imageFile.path,
          'I',
          'TIP',
        );
      }
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
        hashes.add({'text': removeDiacritics(match.group(0).toLowerCase())});
      }
    });

    List<Map> tags = [];
    RegExp exps = new RegExp(r"\B@\[\S\S+\]\S\S+");

    exps.allMatches(_titleController.text).forEach((match) {
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
        await Provider.of<ContentProvider>(context, listen: false).newTip(
      name: _titleController.text,
      description: '${_descriptionController.text} ',
      category: category.id,
      resource: idResource,
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
        title: Text(
          'Tip',
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SuggestionField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _titleController,
                  spanBuilder: _mySpecialTextSpanBuilder,
                  autofocus: true,
                  autocorrect: true,
                  maxLines: null,
                  maxLength: 120,
                  decoration: InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    hintText: Translations.of(context).text('hint_tip_title'),
                  ),
                  style: TextStyle(fontSize: 22),
                ),
                suggestionsCallback: (pattern) {
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
                  int index = _titleController.text.lastIndexOf('@');
                  String subs = _titleController.text.substring(0, index);
                  _titleController.text =
                      '$subs@[${suggestion.userName}]${suggestion.userName} ';
                  _titleController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _titleController.text.length));
                },
                autoFlipDirection: true,
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
                          ? DecorationImage(
                              image: FileImage(_imageFile),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: Icon(Icons.camera_alt),
                  ),
                ),
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
                  focusNode: _descFocus,
                  maxLines: null,
                  autocorrect: true,
                  keyboardType: TextInputType.multiline,
                  maxLength: 2000,
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
                        color: Color(0xFF00B2E3),
                        textColor: Colors.white,
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
