import 'package:flutter/material.dart';

class CountriesScreen extends StatelessWidget {
  static const routeName = '/countries';

  final countries = ['México', 'USA'];

  void _selected(context, value) {
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecciona un país'),
      ),
      body: ListView.builder(
        itemCount: countries.length,
        itemBuilder: (ctx, i) => ListTile(
          onTap: () => _selected(context, countries[i]),
          title: Text(countries[i]),
        ),
      ),
    );
  }
}
