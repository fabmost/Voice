import 'package:flutter/material.dart';

import '../widgets/appbar.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: 7);
    _controller.addListener(null);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        Container(
          height: 42,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Color(0xFF8E8EAB),
          ),
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Buscar',
              style: TextStyle(fontSize: 16, color: Colors.black26),
            ),
          ),
        ),
        true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            constraints: BoxConstraints(maxHeight: 150.0),
            child: Material(
              color: Colors.white,
              child: TabBar(
                controller: _controller,
                isScrollable: true,
                indicatorPadding: EdgeInsets.symmetric(horizontal: 16),
                labelColor: Theme.of(context).accentColor,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'Tendencia'),
                  Tab(text: 'Política'),
                  Tab(text: 'Deportes'),
                  Tab(text: 'Gaming'),
                  Tab(text: 'Educación'),
                  Tab(text: 'Comedia'),
                  Tab(text: 'Etc'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
