import 'dart:io';

import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
//import 'package:video_compress/video_compress.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:video_trimmer/video_trimmer.dart';

import 'gallery_screen.dart';
import 'trim_video_screen.dart';
import 'new_content_category_screen.dart';
import '../translations.dart';
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
  Algolia algolia;
  AlgoliaQuery searchQuery;

  String category;

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
        //final mFile = await VideoCompress.getFileThumbnail(
        final mFile = await FlutterVideoCompress().getThumbnailWithFile(
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

  void _saveChallenge() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });
    final user = await FirebaseAuth.instance.currentUser();
    final userData =
        await Firestore.instance.collection('users').document(user.uid).get();

    WriteBatch batch = Firestore.instance.batch();
    String challengeId =
        Firestore.instance.collection('content').document().documentID;

    StorageReference ref;
    if (_isVideo) {
      ref = FirebaseStorage.instance
          .ref()
          .child('challenges')
          .child('$challengeId.mp4');

      await ref.putFile(_videoFile).onComplete;
    } else {
      ref = FirebaseStorage.instance
          .ref()
          .child('challenges')
          .child(challengeId + '.jpg');

      await ref.putFile(_imageFile).onComplete;
    }

    final url = await ref.getDownloadURL();
    batch.updateData(
      Firestore.instance.collection('users').document(user.uid),
      {
        'created': FieldValue.arrayUnion([challengeId])
      },
    );

    List<String> hashes = [];
    RegExp exp = new RegExp(r"\B#\w\w+");
    exp.allMatches(_titleController.text).forEach((match) {
      if (!hashes.contains(match.group(0))) {
        hashes.add(match.group(0));
      }
    });
    exp.allMatches(_descriptionController.text).forEach((match) {
      if (!hashes.contains(match.group(0))) {
        hashes.add(match.group(0));
      }
    });

    batch.setData(
        Firestore.instance.collection('content').document(challengeId), {
      'type': 'challenge',
      'title': _titleController.text,
      'description': _descriptionController.text,
      'user_name': userData['user_name'],
      'user_id': user.uid,
      'user_image': userData['image'],
      "influencer": userData['influencer'],
      'createdAt': Timestamp.now(),
      'images': [url],
      'is_video': _isVideo,
      'metric_type': metric.toLowerCase(),
      'metric_goal': goal,
      'comments': 0,
      'endDate': Timestamp.now(),
      'category': category,
      'tags': hashes,
      'interactions': 0,
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SuggestionField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _titleController,
                  spanBuilder: MySpecialTextSpanBuilder(),
                  autofocus: true,
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
                  int index = _titleController.text.lastIndexOf('@');
                  String subs = _titleController.text.substring(0, index);
                  _titleController.text =
                      '$subs@[${suggestion.objectID}]${suggestion.data['name']} ';
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
                    height: 120,
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
                  child: Text('${category ?? 'Selecciona una categoría'}'),
                ),
              ),
              SuggestionField(
                textFieldConfiguration: TextFieldConfiguration(
                  spanBuilder: MySpecialTextSpanBuilder(),
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
