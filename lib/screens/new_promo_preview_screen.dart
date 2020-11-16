import 'dart:io';

import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'menu_screen.dart';
import '../translations.dart';
import '../providers/content_provider.dart';
import '../mixins/text_mixin.dart';

class NewPromoPreviewScreen extends StatefulWidget {
  final String poll;
  final String category;
  final String description;
  final List options;
  final List optionImages;
  final List pollImages;
  final String videoFile;
  final int optionsCount;
  final String promoImage;
  final String message;
  final String terms;
  final String audio;
  final int duration;

  NewPromoPreviewScreen({
    this.poll,
    this.category,
    this.description,
    this.optionsCount,
    this.options,
    this.optionImages,
    this.pollImages,
    this.videoFile,
    this.promoImage,
    this.message,
    this.terms,
    this.audio,
    this.duration,
  });

  @override
  _NewPromoPreviewScreenState createState() => _NewPromoPreviewScreenState();
}

class _NewPromoPreviewScreenState extends State<NewPromoPreviewScreen>
    with TextMixin {
  bool _isLoading = false;

  void _savePoll() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });
    var pollAnswers = [];
    for (int i = 0; i < widget.optionsCount; i++) {
      if (widget.optionImages[i] != null) {
        String idResource =
            await Provider.of<ContentProvider>(context, listen: false)
                .uploadResource(
          widget.optionImages[i],
          'I',
          'PA',
        );

        pollAnswers.add({
          'text': serverSafe(widget.options[i]),
          'image': idResource,
        });
      } else {
        pollAnswers.add({
          'text': serverSafe(widget.options[i]),
          'image': null,
        });
      }
    }

    List<Map> images = [];
    for (int i = 0; i < widget.pollImages.length; i++) {
      final element = widget.pollImages[i];
      String idResource =
          await Provider.of<ContentProvider>(context, listen: false)
              .uploadResource(
        element.path,
        'I',
        'P',
      );
      images.add({"id": idResource});
    }
    if (widget.videoFile != null) {
      final idResource =
          await Provider.of<ContentProvider>(context, listen: false)
              .uploadResource(
        widget.videoFile,
        'V',
        'P',
      );
      images.add({"id": idResource});
    }

    String idPromoResource =
        await Provider.of<ContentProvider>(context, listen: false)
            .uploadResource(
      widget.promoImage,
      'I',
      'P',
    );

    String idAudio;
    if (widget.audio != null && widget.duration != null) {
      Map videoMap = await Provider.of<ContentProvider>(context, listen: false)
          .uploadVideo(
        filePath: widget.audio,
        type: 'A',
        content: 'P',
        thumbId: 0,
        duration: widget.duration,
        ratio: 0,
      );
      idAudio = videoMap['id'];
    }

    List<Map> hashes = [];
    RegExp exp = new RegExp(r"\B#\S\S+");
    exp.allMatches(widget.poll).forEach((match) {
      if (!hashes.contains(match.group(0))) {
        hashes.add({'text': removeDiacritics(match.group(0).toLowerCase())});
      }
    });
    exp.allMatches(widget.description).forEach((match) {
      if (!hashes.contains(match.group(0))) {
        String hashString = match.group(0).toLowerCase();
        String serverString = removeDiacritics(hashString);
        hashes.add({'text': serverString});
      }
    });

    bool result =
        await Provider.of<ContentProvider>(context, listen: false).newPromoPoll(
      name: idAudio == null ? widget.poll : '',
      description: widget.description,
      category: widget.category,
      resources: images,
      answers: pollAnswers,
      hashtag: hashes,
      taged: [],
      message: widget.message,
      terms: widget.terms,
      image: idPromoResource,
      audio: idAudio,
    );

    setState(() {
      _isLoading = false;
    });
    if (result)
      _showAlert();
    else
      _showError();
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
    Navigator.of(context).pushNamedAndRemoveUntil(
            MenuScreen.routeName, (Route<dynamic> route) => false);
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
          'Previsualización',
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
              _title(Translations.of(context).text('label_promo')),
              SizedBox(height: 16),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Image.file(
                        File(widget.promoImage),
                        height: 120,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        '¡Gracias por responder nuestra encuesta!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        widget.message,
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        color: Theme.of(context).primaryColor,
                        child: Text(
                          'USERNAME: ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Términos y condiciones: ${widget.terms}',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
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
                            Text(Translations.of(context).text('button_publish')),
                        onPressed: _savePoll,
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
