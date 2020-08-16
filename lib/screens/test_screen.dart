import 'package:flutter/material.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final _controller = TextEditingController();
  bool _isValid = false;
  RegExp regex = new RegExp(r"[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:_\+.~#?&//=]*)");

  void _test() {
    setState(() {
      _isValid = regex.hasMatch(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          TextField(controller: _controller),
          Text(_isValid ? 'Si es' : 'No es'),
          RaisedButton(
            onPressed: _test,
            child: Text('Prueba'),
          ),
        ],
      ),
    );
  }
}
