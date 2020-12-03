import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'new_promo_preview_screen.dart';
import '../translations.dart';

class NewPromoInfoScreen extends StatefulWidget {
  final String poll;
  final String category;
  final String description;
  final List options;
  final List optionImages;
  final List pollImages;
  final Map videoMap;
  final String videoThumb;
  final int optionsCount;
  final String audio;
  final int duration;

  NewPromoInfoScreen({
    this.poll,
    this.category,
    this.description,
    this.optionsCount,
    this.options,
    this.optionImages,
    this.pollImages,
    this.videoMap,
    this.videoThumb,
    this.audio,
    this.duration,
  });

  @override
  _NewPromoInfoScreenState createState() => _NewPromoInfoScreenState();
}

class _NewPromoInfoScreenState extends State<NewPromoInfoScreen> {
  TextEditingController _messageController = TextEditingController();
  TextEditingController _termsController = TextEditingController();
  bool _isLoading = false;
  File _promoImage;

  void _promoImageOptions() {
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
    _getPicture();
  }

  Future<void> _takePicture() async {
    final imageFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );
    if (imageFile != null) {
      _cropImage(imageFile.path);
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

  void _cropImage(pathFile) async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: pathFile,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
    );
    if (cropped != null) {
      setState(() {
        _promoImage = cropped;
      });
    }
  }

  void _validate() {
    if (_messageController.text.isNotEmpty &&
        _termsController.text.isNotEmpty &&
        _promoImage != null) {
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
        builder: (context) => NewPromoPreviewScreen(
          poll: widget.poll,
          category: widget.category,
          description: widget.description,
          optionsCount: widget.optionsCount,
          options: widget.options,
          optionImages: widget.optionImages,
          pollImages: widget.pollImages,
          videoMap: widget.videoMap,
          videoThumb: widget.videoThumb,
          promoImage: _promoImage.path,
          message: _messageController.text,
          terms: _termsController.text,
          audio: widget.audio,
          duration: widget.duration,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        title: Text(
          'Crea tu promoción',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 16),
              _title(Translations.of(context).text('label_media_promo')),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: _promoImageOptions,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black),
                      image: _promoImage != null
                          ? DecorationImage(
                              image: FileImage(_promoImage),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: Icon(Icons.camera_alt),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _messageController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: Translations.of(context).text('hint_promo'),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _termsController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: Translations.of(context).text('hint_terms'),
                ),
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
