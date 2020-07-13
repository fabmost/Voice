import 'package:flutter/material.dart';

import '../translations.dart';
import '../custom/search_delegate.dart';
import '../widgets/appbar.dart';
import '../widgets/top_content.dart';
import '../widgets/filtered_content.dart';
import '../widgets/categories_list.dart';

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
    _controller = TabController(vsync: this, length: 6);
    _controller.addListener(null);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startSearch(ct) {
    showSearch(
      context: ct,
      delegate: CustomSearchDelegate(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: CustomAppBar(
          GestureDetector(
            onTap: () => _startSearch(context),
            child: Container(
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
                  Translations.of(context).text('hint_search'),
                  style: TextStyle(fontSize: 16, color: Colors.black26),
                ),
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
                  //controller: _controller,
                  isScrollable: true,
                  indicatorPadding: EdgeInsets.symmetric(horizontal: 16),
                  labelColor: Theme.of(context).accentColor,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(text: 'Tendencia'),
                    Tab(text: 'Salud'),
                    Tab(text: 'Tecnología'),
                    Tab(text: 'Deportes'),
                    Tab(text: 'Política'),
                    Tab(text: 'Más'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  TopContent(),
                  FilteredContent('Salud'),
                  FilteredContent('Tecnología'),
                  FilteredContent('Deportes'),
                  FilteredContent('Política'),
                  CategoriesList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
