import 'dart:io';

import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
//import 'package:video_compress/video_compress.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:video_trimmer/video_trimmer.dart';

import 'gallery_screen.dart';
import 'trim_video_screen.dart';
import 'new_content_category_screen.dart';
import '../translations.dart';
import '../models/category_model.dart';
import '../providers/content_provider.dart';
import '../custom/galup_font_icons.dart';
import '../custom/my_special_text_span_builder.dart';
import '../custom/suggestion_textfield.dart';
import '../widgets/influencer_badge.dart';

class NewPollScreen extends StatefulWidget {
  static const routeName = '/new-poll';

  @override
  _NewPollScreenState createState() => _NewPollScreenState();
}

class _NewPollScreenState extends State<NewPollScreen> {
  bool _isLoading = false;
  bool _isSearching = false;
  bool _isVideo = false;
  FocusNode _descFocus = FocusNode();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _firstController = TextEditingController();
  TextEditingController _secondController = TextEditingController();
  TextEditingController _thirdController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  final Trimmer _trimmer = Trimmer();
  final MySpecialTextSpanBuilder _mySpecialTextSpanBuilder =
      MySpecialTextSpanBuilder();
  Algolia algolia;
  AlgoliaQuery searchQuery;
  bool moreOptions = false;
  File _option1, _option2, _option3;
  List<File> pollImages = [];
  CategoryModel category;
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
          if (_option1 != null) showDelete = true;
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
        //final mFile = await VideoCompress.getFileThumbnail(
        final mFile = await FlutterVideoCompress().getThumbnailWithFile(
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

  void _addOption() {
    setState(() {
      moreOptions = !moreOptions;
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

/*
  void _selectDuration() {
    showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: Text('Selecciona una duración'),
          children: <Widget>[
            SimpleDialogOption(
              child: Text(
                'Infinito',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () => _optionSelected(0),
            ),
            SimpleDialogOption(
              child: Text(
                '1 mes',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () => _optionSelected(1),
            ),
            SimpleDialogOption(
              child: Text(
                '3 meses',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () => _optionSelected(2),
            ),
            SimpleDialogOption(
              child: Text(
                '6 meses',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () => _optionSelected(3),
            ),
          ],
        );
      },
    );
  }

  void _optionSelected(position) {
    Navigator.of(context).pop();
  }
  */

  void _validate() {
    if (_titleController.text.isNotEmpty &&
        _firstController.text.isNotEmpty &&
        _secondController.text.isNotEmpty &&
        category != null) {
      if (!moreOptions || (moreOptions && _thirdController.text.isNotEmpty)) {
        _savePoll();
        return;
      }
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
        'text': _firstController.text,
        'image': idResource,
      });
    } else {
      pollAnswers.add({
        'text': _firstController.text,
        'id_resource': null,
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
        'text': _secondController.text,
        'image': idResource,
      });
    } else {
      pollAnswers.add({
        'text': _secondController.text,
        'id_resource': null,
      });
    }
    if (moreOptions) {
      if (_option3 != null) {
        String idResource =
            await Provider.of<ContentProvider>(context, listen: false)
                .uploadResource(
          _option3.path,
          'I',
          'PA',
        );
        pollAnswers.add({
          'text': _thirdController.text,
          'image': idResource,
        });
      } else {
        pollAnswers.add({
          'text': _thirdController.text,
          'id_resource': null,
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

    await Provider.of<ContentProvider>(context, listen: false).newPoll(
      name: _titleController.text,
      description: _descriptionController.text,
      category: category.id,
      resources: images,
      answers: pollAnswers,
    );
    /*
    String videoUrl;
    String videoThumb;
    if (_isVideo && _videoFile != null && _videoThumb != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('polls')
          .child(pollId)
          .child('thumb.jpg');

      await ref.putFile(_videoThumb).onComplete;

      videoThumb = await ref.getDownloadURL();

      final ref2 = FirebaseStorage.instance
          .ref()
          .child('polls')
          .child(pollId)
          .child('video.mp4');

      await ref2.putFile(_videoFile).onComplete;

      videoUrl = await ref2.getDownloadURL();
    }

    List<String> hashes = [];
    RegExp exp = new RegExp(r"\B#\w\w+");
    exp.allMatches(_descriptionController.text).forEach((match) {
      hashes.add(match.group(0));
    });

    batch.setData(Firestore.instance.collection('content').document(pollId), {
      'type': 'poll',
      'title': _titleController.text,
      'user_name': userData['user_name'],
      'user_id': user.uid,
      'user_image': userData['image'],
      "influencer": userData['influencer'],
      'createdAt': Timestamp.now(),
      'options': pollOptions,
      'results': results,
      'comments': 0,
      'endDate': Timestamp.now(),
      'category': category,
      'description': _descriptionController.text,
      'tags': hashes,
      'interactions': 0,
      'images': images,
      'video': videoUrl,
      'video_thumb': videoThumb,
      'home': userData['followers'] ?? [],
    });
    hashes.forEach((element) {
      batch.setData(
        Firestore.instance.collection('hash').document(element),
        {
          'name': element,
          'interactions': FieldValue.increment(1),
        },
        merge: true,
      );
    });
    await batch.commit();
    */
    setState(() {
      _isLoading = false;
    });
    _showAlert();
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
      maxLength: 25,
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
            onPressed: _addOption,
          ),
        )
      ],
    );
  }

  Widget _userTile(context, id, doc) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(doc['user_image'] ?? ''),
      ),
      title: Row(
        children: <Widget>[
          Text(
            doc['name'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(width: 8),
          InfluencerBadge(doc['influencer'] ?? '', 16),
        ],
      ),
      subtitle: Text(doc['user_name']),
    );
  }

  Future<List> _getSuggestions(String query) async {
    if (query.endsWith(' ')) {
      _isSearching = false;
      return null;
    }
    searchQuery = algolia.instance.index('suggestions');
    int index = query.lastIndexOf('@');
    String realQuery = query.substring(index);
    searchQuery = searchQuery.search(realQuery);
    AlgoliaQuerySnapshot results = await searchQuery.getObjects();
    return results.hits;
  }

  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    algolia = Algolia.init(
      applicationId: 'J3C3F33D3S',
      apiKey: '70469e6182ac069696c17d836c210780',
    );
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _titleController,
                autofocus: true,
                maxLines: null,
                maxLength: 120,
                decoration: InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  hintText: Translations.of(context).text('hint_poll_title'),
                ),
                style: TextStyle(fontSize: 22),
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
              if (moreOptions) SizedBox(height: 8),
              if (moreOptions) _thirdOption(),
              if (!moreOptions)
                FlatButton.icon(
                  onPressed: _addOption,
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
                  focusNode: _descFocus,
                  maxLines: null,
                  maxLength: 240,
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
                  AlgoliaObjectSnapshot result = itemData;
                  if (result.data['interactions'] == null) {
                    return _userTile(context, result.objectID, result.data);
                  }
                  return Container();
                },
                onSuggestionSelected: (suggestion) {
                  _isSearching = false;
                  //TextSelection selection = _descriptionController.selection;
                  int index = _descriptionController.text.lastIndexOf('@');
                  String subs = _descriptionController.text.substring(0, index);
                  _descriptionController.text =
                      '$subs@[${suggestion.objectID}]${suggestion.data['name']} ';
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
