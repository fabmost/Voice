import 'package:flutter/material.dart';

import '../custom/galup_font_icons.dart';

class NewPollScreen extends StatefulWidget {
  static const routeName = '/new-poll';

  @override
  _NewPollScreenState createState() => _NewPollScreenState();
}

class _NewPollScreenState extends State<NewPollScreen> {
  bool moreOptions = false;

  void _addOption() {
    setState(() {
      moreOptions = !moreOptions;
    });
  }

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

  Widget _optionField(text) {
    return TextField(
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
        Expanded(child: _optionField('Opción 1')),
        const SizedBox(width: 8),
        Container(
          width: 42,
          height: 42,
          margin: EdgeInsets.only(top: 10),
          child: RawMaterialButton(
            onPressed: () {},
            child: Icon(
              Icons.camera_alt,
            ),
            shape: CircleBorder(
              side: BorderSide(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _secondOption() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: _optionField('Opción 2')),
        const SizedBox(width: 8),
        Container(
          width: 42,
          height: 42,
          margin: EdgeInsets.only(top: 10),
          child: RawMaterialButton(
            onPressed: () {},
            child: Icon(
              Icons.camera_alt,
            ),
            shape: CircleBorder(
              side: BorderSide(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _thirdOption() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: _optionField('Opción 3')),
        const SizedBox(width: 8),
        Container(
          width: 42,
          height: 42,
          margin: EdgeInsets.only(top: 10),
          child: RawMaterialButton(
            onPressed: () {},
            child: Icon(
              Icons.camera_alt,
            ),
            shape: CircleBorder(
              side: BorderSide(color: Colors.black),
            ),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                maxLines: null,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Has una pregunta',
                ),
                style: TextStyle(fontSize: 22),
              ),
              SizedBox(height: 16),
              _title('Imágenes (opcional)'),
              SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Container(
                    width: 72,
                    height: 72,
                    child: RawMaterialButton(
                      onPressed: () {},
                      child: Icon(
                        Icons.camera_alt,
                      ),
                      shape: CircleBorder(
                        side: BorderSide(color: Colors.black),
                      ),
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
              _title('Duración'),
              ListTile(
                onTap: _selectDuration,
                title: Text('Infinito'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
