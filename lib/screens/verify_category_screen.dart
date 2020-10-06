import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'verify_id_screen.dart';
import '../widgets/influencer_tile.dart';
import '../providers/database_provider.dart';

class VerifyCategoryScreen extends StatelessWidget {
  static const routeName = '/verify-category';

  void _setSelected(context, type, position) {
    Navigator.of(context).pushNamed(VerifyIdScreen.routeName, arguments: {
      "type": type,
      "category": position,
    });
  }

  @override
  Widget build(BuildContext context) {
    final type = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder(
          future: Provider.of<DatabaseProvider>(context, listen: false)
              .getInfluencerCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            final list = snapshot.data;
            return Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Selecciona una categoría',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Selecciona entre la lista la categoría que mejor describa lo que haces',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (ctx, i) => InfluencerTile(
                          list[i].id,
                          list[i].name,
                          list[i].icon,
                          type,
                          _setSelected,
                        ),
                      ),
                    ),
                  ],
                ));
          }),
    );
  }
}
