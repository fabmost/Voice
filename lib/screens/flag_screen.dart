import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../translations.dart';
import '../providers/content_provider.dart';

class FlagScreen extends StatelessWidget {
  static const routeName = '/flag';

  void _sendFlag(context, id, type, reason) async {
    final result =
        await Provider.of<ContentProvider>(context, listen: false).flagContent(
      id: id,
      action: reason,
      type: type,
    );
    if (result) {
      _showAlert(context);
    }
  }

  void _showAlert(context) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Translations.of(context).text('dialog_flag_title')),
        content: Text(Translations.of(context).text('dialog_flag_content')),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
    Navigator.of(context).pop();
  }

  Widget _flagCard(context, id, motive, type, motiveId) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.black, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _sendFlag(context, id, type, motiveId),
        child: Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: Text(motive),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map map = ModalRoute.of(context).settings.arguments;
    final id = map['id'];
    final type = map['type'];
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              Translations.of(context).text('title_flag'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            SizedBox(height: 16),
            Text(Translations.of(context).text('label_flag')),
            SizedBox(height: 16),
            _flagCard(
              context,
              id,
              Translations.of(context).text('flag_1'),
              type,
              'S',
            ),
            SizedBox(height: 16),
            _flagCard(
              context,
              id,
              Translations.of(context).text('flag_2'),
              type,
              'V',
            ),
            SizedBox(height: 16),
            _flagCard(
              context,
              id,
              Translations.of(context).text('flag_3'),
              type,
              'I',
            ),
          ],
        ),
      ),
    );
  }
}
