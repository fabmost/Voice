import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../widgets/top_content.dart';
import '../widgets/filtered_content.dart';
import '../widgets/categories_list.dart';

class SearchScreen extends StatefulWidget {
  final Function stopVideo;

  const SearchScreen({Key key, this.stopVideo}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController _controller;
  VideoPlayerController _videoController;

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

  @override
  bool get wantKeepAlive => true;

  void _playVideo(VideoPlayerController controller) {
    if (_videoController != null) {
      _videoController.pause();
    }
    _videoController = controller;
    widget.stopVideo(_videoController);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 7,
      child: Column(
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
                  Tab(text: 'Radio'),
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
                TopContent(_playVideo),
                FilteredContent('50', _playVideo),
                FilteredContent('1', _playVideo),
                FilteredContent('3', _playVideo),
                FilteredContent('5', _playVideo),
                FilteredContent('8', _playVideo),
                CategoriesList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
