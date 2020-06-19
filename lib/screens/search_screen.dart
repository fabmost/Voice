import 'package:flutter/material.dart';

import '../widgets/appbar.dart';

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        Container(
          height: 42,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar',
              filled: true,
              fillColor: Color(0xFF8E8EAB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        true,
      ),
    );
  }
}
